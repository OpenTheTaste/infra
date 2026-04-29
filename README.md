# Terraform 작업 구조

이 저장소는 `dev` 환경 중심의 AWS 인프라 학습/실습용 Terraform 코드입니다.

구성 범위:
- VPC, 퍼블릭/프라이빗 서브넷, NAT, ALB
- EC2 서비스(User / Admin)
- ECS 트랜스코더 워크로드
- RDS, RabbitMQ, Lambda, EventBridge
- 모니터링 스택(Grafana / Prometheus / Loki)
- S3 + CloudFront + Route53

## 디렉터리 구조
- `environments/dev`: dev 환경 루트 모듈
- `modules`: 재사용 가능한 인프라 모듈
- `stacks`: 상위 조합(컴포지션) 스택
- `global`: 전역 공통 스택(원격 상태 저장소용 backend 포함)
- `docs`: 아키텍처/운영 문서

## 권장 작업 흐름
1. `modules/*`에 재사용 컴포넌트 구현
2. `stacks/app`에서 모듈 조합
3. `environments/dev`에서 변수/환경값 관리

## 문서
- `docs/backend_guide.md`: 원격 상태 저장소 초기 구성
- `docs/first_run_checklist.md`: 최초 실행 체크리스트
- `docs/ops_checklist.md`: 이후 운영/재배포 체크리스트
- `docs/destroy_checklist.md`: 리소스 삭제 체크리스트
- `docs/cloudfront_signed_cookie_mapping.md`: CloudFront 서명 쿠키 ID 매핑
- `docs/TODO_cloudfront_signed_cookie_manual.md`: 수동 키 운영 TODO