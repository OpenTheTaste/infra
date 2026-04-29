# app 스택 (상위 오케스트레이터 + 내부 레이어 구조)

`stacks/app`은 상위에서 한 번만 호출하는 오케스트레이터 스택입니다.
`environments/dev`는 이 스택 하나를 호출하고, Terraform이 내부 의존성 그래프에 따라 전체 리소스를 생성합니다.

## 내부 레이어 구성

- `network.tf`: 기반 네트워크 리소스 (`ami`, `vpc`, `security_groups`)
- `platform.tf`: 공용 플랫폼 리소스 (S3, ECS cluster/service, RDS, Secrets, IAM)
- `workloads.tf`: 워크로드 실행 리소스 (admin/user EC2, RabbitMQ, monitoring, Lambda, EventBridge)
- `edge.tf`: 외부 인입/노출 리소스 (Route53, ACM, ALB, CloudFront)
- `main.tf`: 공통 `provider`/`data`/`locals`

## 패턴 요약

- 외부 구조: Top-down 오케스트레이션 (`environments/dev` -> `stacks/app`)
- 내부 구조: 레이어 분리(가독성, 변경 영향도 관리, 책임 분리)