terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  default_scrape_targets = [
    {
      target       = "localhost:9090"
      metrics_path = "/metrics"
    }
  ]

  scrape_target_map = {
    for t in concat(local.default_scrape_targets, var.prometheus_scrape_targets) :
    "${t.target}|${t.metrics_path}" => t
  }

  scrape_jobs_yaml = join("\n", [
    for t in values(local.scrape_target_map) :
    "  - job_name: \"${replace(replace(replace(t.target, ":", "-"), ".", "-"), "/", "-")}\"\n    metrics_path: \"${t.metrics_path}\"\n    static_configs:\n      - targets: [\"${t.target}\"]"
  ])

  grafana_admin_password_safe = var.grafana_admin_password != null ? var.grafana_admin_password : ""

  generated_user_data = <<-EOT
    #!/bin/bash
    set -euo pipefail

    dnf -y update
    dnf -y install docker jq awscli
    systemctl enable --now docker

    REGION=$(curl -sS http://169.254.169.254/latest/meta-data/placement/region || true)
    if [ -z "$REGION" ]; then
      REGION=ap-northeast-2
    fi

    if [ -n "${var.grafana_admin_secret_arn}" ]; then
      SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id '${var.grafana_admin_secret_arn}' --region "$REGION" --query SecretString --output text)
      GRAFANA_ADMIN_USER=$(echo "$SECRET_JSON" | jq -r '.username')
      GRAFANA_ADMIN_PASSWORD=$(echo "$SECRET_JSON" | jq -r '.password')
    else
      GRAFANA_ADMIN_USER='${var.grafana_admin_user}'
      GRAFANA_ADMIN_PASSWORD='${local.grafana_admin_password_safe}'
    fi

    mkdir -p /opt/monitoring/prometheus /opt/monitoring/loki /opt/monitoring/grafana/provisioning/datasources

    cat >/opt/monitoring/loki/local-config.yaml <<'LOKI'
    auth_enabled: false

    server:
      http_listen_port: 3100

    common:
      path_prefix: /loki
      storage:
        filesystem:
          chunks_directory: /loki/chunks
          rules_directory: /loki/rules
      replication_factor: 1
      ring:
        kvstore:
          store: inmemory

    schema_config:
      configs:
        - from: 2024-01-01
          store: tsdb
          object_store: filesystem
          schema: v13
          index:
            prefix: index_
            period: 24h

    ruler:
      alertmanager_url: http://localhost:9093
    LOKI

    cat >/opt/monitoring/prometheus/prometheus.yml <<'PROM'
    global:
      scrape_interval: 15s

    scrape_configs:
    ${local.scrape_jobs_yaml}
    PROM

    cat >/opt/monitoring/grafana/provisioning/datasources/datasources.yml <<'GRAFANA_DS'
    apiVersion: 1

    datasources:
      - name: Prometheus
        type: prometheus
        access: proxy
        url: http://prometheus:9090
        isDefault: true
      - name: Loki
        type: loki
        access: proxy
        url: http://loki:3100
    GRAFANA_DS

    docker rm -f loki prometheus grafana || true
    docker network create monitoring || true

    docker run -d \
      --name loki \
      --network monitoring \
      --restart unless-stopped \
      -p 3100:3100 \
      -v /opt/monitoring/loki:/loki \
      -v /opt/monitoring/loki/local-config.yaml:/etc/loki/local-config.yaml:ro \
      grafana/loki:3.0.0 \
      -config.file=/etc/loki/local-config.yaml

    docker run -d \
      --name prometheus \
      --network monitoring \
      --restart unless-stopped \
      -p 9090:9090 \
      -v /opt/monitoring/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro \
      prom/prometheus:v2.54.1 \
      --config.file=/etc/prometheus/prometheus.yml

    docker run -d \
      --name grafana \
      --network monitoring \
      --restart unless-stopped \
      -p 3000:3000 \
      -e GF_SECURITY_ADMIN_USER="$GRAFANA_ADMIN_USER" \
      -e GF_SECURITY_ADMIN_PASSWORD="$GRAFANA_ADMIN_PASSWORD" \
      -v /opt/monitoring/grafana:/var/lib/grafana \
      -v /opt/monitoring/grafana/provisioning/datasources:/etc/grafana/provisioning/datasources:ro \
      grafana/grafana:11.1.0
  EOT

  common_tags = merge(
    {
      Name      = var.name
      ManagedBy = "terraform"
      Component = "monitoring"
    },
    var.tags
  )

  resolved_user_data = var.user_data != null ? var.user_data : local.generated_user_data
}

resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  iam_instance_profile        = var.iam_instance_profile_name
  associate_public_ip_address = var.associate_public_ip
  monitoring                  = var.enable_detailed_monitoring
  vpc_security_group_ids      = [var.security_group_id]

  user_data = local.resolved_user_data

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    encrypted             = var.root_volume_encrypted
    delete_on_termination = true
  }

  tags = local.common_tags

  lifecycle {
    precondition {
      condition     = var.grafana_admin_secret_arn != null || var.grafana_admin_password != null
      error_message = "Set grafana_admin_secret_arn or grafana_admin_password for monitoring module."
    }
  }
}
