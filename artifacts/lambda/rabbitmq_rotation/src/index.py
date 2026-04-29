import base64
import json
import logging
import os
import urllib.error
import urllib.parse
import urllib.request

import boto3


logger = logging.getLogger()
logger.setLevel(logging.INFO)

secretsmanager = boto3.client("secretsmanager")


def _get_env(name, required=False, default=None):
    value = os.getenv(name, default)
    if required and (value is None or str(value).strip() == ""):
        raise ValueError(f"Missing required environment variable: {name}")
    return value


def _load_secret_json(secret_id, version_stage=None, version_id=None):
    kwargs = {"SecretId": secret_id}
    if version_stage is not None:
        kwargs["VersionStage"] = version_stage
    if version_id is not None:
        kwargs["VersionId"] = version_id

    response = secretsmanager.get_secret_value(**kwargs)
    secret_text = response.get("SecretString")
    if not secret_text:
        raise RuntimeError(f"Secret is empty: {secret_id}")

    payload = json.loads(secret_text)
    if not payload.get("username") or not payload.get("password"):
        raise RuntimeError(f"Secret must contain username/password: {secret_id}")

    return payload


def _rabbitmq_request(method, url, auth_username, auth_password, body=None):
    auth = base64.b64encode(f"{auth_username}:{auth_password}".encode("utf-8")).decode("utf-8")
    headers = {
        "Authorization": f"Basic {auth}",
        "Accept": "application/json",
    }

    data = None
    if body is not None:
        headers["Content-Type"] = "application/json"
        data = json.dumps(body).encode("utf-8")

    req = urllib.request.Request(url=url, headers=headers, data=data, method=method)
    with urllib.request.urlopen(req, timeout=10) as response:
        text = response.read().decode("utf-8")
        return {} if not text else json.loads(text)


def _get_admin_credentials():
    admin_secret_arn = _get_env("RABBITMQ_ADMIN_CREDENTIALS_SECRET_ARN", required=True)
    return _load_secret_json(admin_secret_arn)


def _describe_and_validate_rotation(secret_arn, token):
    metadata = secretsmanager.describe_secret(SecretId=secret_arn)

    if not metadata.get("RotationEnabled"):
        raise RuntimeError(f"Secret rotation is not enabled for {secret_arn}")

    versions = metadata.get("VersionIdsToStages", {})
    if token not in versions:
        raise RuntimeError(f"Rotation token {token} is not valid for secret {secret_arn}")

    if "AWSCURRENT" in versions[token]:
        return metadata, "already_current"

    if "AWSPENDING" not in versions[token]:
        raise RuntimeError(f"Rotation token {token} is not set as AWSPENDING for secret {secret_arn}")

    return metadata, "pending"


def _create_secret(secret_arn, token):
    try:
        _load_secret_json(secret_arn, version_stage="AWSPENDING", version_id=token)
        return
    except secretsmanager.exceptions.ResourceNotFoundException:
        pass

    current = _load_secret_json(secret_arn, version_stage="AWSCURRENT")
    random_password = secretsmanager.get_random_password(PasswordLength=24, ExcludeCharacters='"@/\\')
    pending = {
        "username": current["username"],
        "password": random_password["RandomPassword"],
    }

    secretsmanager.put_secret_value(
        SecretId=secret_arn,
        ClientRequestToken=token,
        SecretString=json.dumps(pending),
        VersionStages=["AWSPENDING"],
    )


def _set_secret(secret_arn, token):
    api_base = _get_env("RABBITMQ_API_BASE_URL", required=True).rstrip("/")
    pending = _load_secret_json(secret_arn, version_stage="AWSPENDING", version_id=token)
    admin = _get_admin_credentials()

    encoded_user = urllib.parse.quote(pending["username"], safe="")
    user_url = f"{api_base}/api/users/{encoded_user}"

    tags = _get_env("RABBITMQ_TARGET_USER_TAGS", default="management")
    try:
        existing = _rabbitmq_request("GET", user_url, admin["username"], admin["password"])
        if isinstance(existing, dict) and existing.get("tags") is not None:
            tags = existing.get("tags")
    except urllib.error.HTTPError as error:
        if error.code != 404:
            raise

    _rabbitmq_request(
        "PUT",
        user_url,
        admin["username"],
        admin["password"],
        body={"password": pending["password"], "tags": tags},
    )


def _test_secret(secret_arn, token):
    api_base = _get_env("RABBITMQ_API_BASE_URL", required=True).rstrip("/")
    pending = _load_secret_json(secret_arn, version_stage="AWSPENDING", version_id=token)

    whoami_url = f"{api_base}/api/whoami"
    response = _rabbitmq_request("GET", whoami_url, pending["username"], pending["password"])
    if response.get("name") != pending["username"]:
        raise RuntimeError("RabbitMQ credential validation failed during testSecret step")


def _finish_secret(secret_arn, token, metadata):
    current_version = None
    for version_id, stages in metadata.get("VersionIdsToStages", {}).items():
        if "AWSCURRENT" in stages:
            current_version = version_id
            break

    if current_version == token:
        return

    secretsmanager.update_secret_version_stage(
        SecretId=secret_arn,
        VersionStage="AWSCURRENT",
        MoveToVersionId=token,
        RemoveFromVersionId=current_version,
    )


def lambda_handler(event, context):
    secret_arn = event["SecretId"]
    token = event["ClientRequestToken"]
    step = event["Step"]

    metadata, state = _describe_and_validate_rotation(secret_arn, token)
    if state == "already_current":
        logger.info("Secret version already current")
        return

    if step == "createSecret":
        _create_secret(secret_arn, token)
    elif step == "setSecret":
        _set_secret(secret_arn, token)
    elif step == "testSecret":
        _test_secret(secret_arn, token)
    elif step == "finishSecret":
        _finish_secret(secret_arn, token, metadata)
    else:
        raise RuntimeError(f"Unknown rotation step: {step}")
