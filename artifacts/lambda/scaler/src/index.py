import base64
import json
import logging
import math
import os
import time
import urllib.parse
import urllib.request

import boto3


logger = logging.getLogger()
logger.setLevel(logging.INFO)

ecs = boto3.client("ecs")
ssm = boto3.client("ssm")
secretsmanager = boto3.client("secretsmanager")


def _get_env(name, default=None, required=False):
    value = os.getenv(name, default)
    if required and (value is None or str(value).strip() == ""):
        raise ValueError(f"Missing required environment variable: {name}")
    return value


def _get_ssm_value_from_env(param_env_name, default=None, required=False):
    param_name = _get_env(param_env_name, default=None, required=required)
    if param_name is None or str(param_name).strip() == "":
        return default

    response = ssm.get_parameter(Name=param_name, WithDecryption=False)
    return response["Parameter"]["Value"]


def _put_ssm_value_from_env(param_env_name, value):
    param_name = _get_env(param_env_name, required=True)
    ssm.put_parameter(Name=param_name, Value=str(value), Type="String", Overwrite=True)


def _get_rabbitmq_credentials():
    secret_arn = _get_env("RABBITMQ_CREDENTIALS_SECRET_ARN", required=True)
    response = secretsmanager.get_secret_value(SecretId=secret_arn)
    secret_text = response.get("SecretString")

    if not secret_text:
        raise RuntimeError("RabbitMQ credentials secret is empty")

    try:
        payload = json.loads(secret_text)
    except json.JSONDecodeError as error:
        raise RuntimeError("RabbitMQ credentials secret must be valid JSON") from error

    username = payload.get("username")
    password = payload.get("password")

    if not username or not password:
        raise RuntimeError("RabbitMQ credentials secret must include username/password")

    return username, password


def _load_runtime_config():
    config = {
        "rabbitmq_api_base_url": _get_ssm_value_from_env("RABBITMQ_API_BASE_URL_PARAM", required=True).rstrip("/"),
        "rabbitmq_vhost": _get_ssm_value_from_env("RABBITMQ_VHOST_PARAM", default="/", required=True),
        "rabbitmq_queue_name": _get_ssm_value_from_env("RABBITMQ_QUEUE_NAME_PARAM", required=True),
        "rabbitmq_api_timeout_sec": float(
            _get_ssm_value_from_env("RABBITMQ_API_TIMEOUT_SEC_PARAM", default="5", required=True)
        ),
        "ecs_cluster_name": _get_ssm_value_from_env("ECS_CLUSTER_NAME_PARAM", required=True),
        "ecs_service_name": _get_ssm_value_from_env("ECS_SERVICE_NAME_PARAM", required=True),
        "messages_per_instance": int(
            _get_ssm_value_from_env("MESSAGES_PER_INSTANCE_PARAM", default="5", required=True)
        ),
        "min_desired_count": int(
            _get_ssm_value_from_env("MIN_DESIRED_COUNT_PARAM", default="0", required=True)
        ),
        "scale_cooldown_seconds": int(
            _get_ssm_value_from_env("SCALE_COOLDOWN_SECONDS_PARAM", default="120", required=True)
        ),
        "max_scale_step": int(
            _get_ssm_value_from_env("MAX_SCALE_STEP_PARAM", default="1", required=True)
        ),
        "last_scale_epoch": int(
            _get_ssm_value_from_env("LAST_SCALE_EPOCH_PARAM", default="0", required=True)
        ),
    }

    max_desired_count_param_name = _get_env("MAX_DESIRED_COUNT_PARAM", default="")
    if max_desired_count_param_name.strip() == "":
        config["max_desired_count"] = None
    else:
        config["max_desired_count"] = int(_get_ssm_value_from_env("MAX_DESIRED_COUNT_PARAM", required=True))

    if config["messages_per_instance"] <= 0:
        raise ValueError("messages_per_instance must be > 0")
    if config["max_scale_step"] <= 0:
        raise ValueError("max_scale_step must be > 0")

    return config


def _get_rabbitmq_queue_messages(config, username, password):
    encoded_vhost = urllib.parse.quote(config["rabbitmq_vhost"], safe="")
    encoded_queue = urllib.parse.quote(config["rabbitmq_queue_name"], safe="")
    url = f"{config['rabbitmq_api_base_url']}/api/queues/{encoded_vhost}/{encoded_queue}"

    auth_token = base64.b64encode(f"{username}:{password}".encode("utf-8")).decode("utf-8")
    request = urllib.request.Request(
        url=url,
        headers={
            "Authorization": f"Basic {auth_token}",
            "Accept": "application/json",
        },
        method="GET",
    )

    with urllib.request.urlopen(request, timeout=config["rabbitmq_api_timeout_sec"]) as response:
        payload = json.loads(response.read().decode("utf-8"))
    return int(payload.get("messages", 0))


def _get_current_desired_count(cluster_name, service_name):
    response = ecs.describe_services(cluster=cluster_name, services=[service_name])
    failures = response.get("failures", [])
    if failures:
        raise RuntimeError(f"ECS describe_services failure: {failures}")

    services = response.get("services", [])
    if not services:
        raise RuntimeError("ECS service not found")

    return int(services[0]["desiredCount"])


def _calculate_target_count(message_count, config):
    if message_count <= 0:
        target = 0
    else:
        target = math.ceil(message_count / config["messages_per_instance"])

    target = max(target, config["min_desired_count"])

    if config["max_desired_count"] is not None:
        target = min(target, config["max_desired_count"])

    return target


def _apply_step_limit(current_desired, target_desired, max_step):
    if target_desired > current_desired:
        return min(target_desired, current_desired + max_step)
    if target_desired < current_desired:
        return max(target_desired, current_desired - max_step)
    return current_desired


def handler(event, context):
    try:
        config = _load_runtime_config()
        rabbitmq_username, rabbitmq_password = _get_rabbitmq_credentials()

        message_count = _get_rabbitmq_queue_messages(config, rabbitmq_username, rabbitmq_password)
        current_desired = _get_current_desired_count(config["ecs_cluster_name"], config["ecs_service_name"])
        target_desired = _calculate_target_count(message_count, config)

        if target_desired == current_desired:
            return {
                "statusCode": 200,
                "status": "no_change",
                "queue_messages": message_count,
                "desired_count": current_desired,
            }

        now_epoch = int(time.time())
        elapsed = now_epoch - config["last_scale_epoch"]
        if elapsed < config["scale_cooldown_seconds"]:
            return {
                "statusCode": 200,
                "status": "cooldown_skip",
                "queue_messages": message_count,
                "current_desired": current_desired,
                "target_desired": target_desired,
                "cooldown_remaining": config["scale_cooldown_seconds"] - elapsed,
            }

        adjusted_target = _apply_step_limit(current_desired, target_desired, config["max_scale_step"])
        if adjusted_target == current_desired:
            return {
                "statusCode": 200,
                "status": "step_limited_no_change",
                "queue_messages": message_count,
                "current_desired": current_desired,
                "target_desired": target_desired,
            }

        ecs.update_service(
            cluster=config["ecs_cluster_name"],
            service=config["ecs_service_name"],
            desiredCount=adjusted_target,
        )
        _put_ssm_value_from_env("LAST_SCALE_EPOCH_PARAM", now_epoch)

        logger.info(
            json.dumps(
                {
                    "action": "scaled",
                    "cluster": config["ecs_cluster_name"],
                    "service": config["ecs_service_name"],
                    "queue_messages": message_count,
                    "before_desired": current_desired,
                    "requested_target": target_desired,
                    "applied_target": adjusted_target,
                    "cooldown_seconds": config["scale_cooldown_seconds"],
                    "max_scale_step": config["max_scale_step"],
                },
                ensure_ascii=True,
            )
        )

        return {
            "statusCode": 200,
            "status": "scaled",
            "queue_messages": message_count,
            "before_desired": current_desired,
            "requested_target": target_desired,
            "applied_target": adjusted_target,
        }
    except Exception as error:
        logger.error(str(error), exc_info=True)
        return {
            "statusCode": 500,
            "status": "error",
            "message": str(error),
        }
