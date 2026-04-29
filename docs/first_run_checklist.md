# 최초 실행 체크리스트 (dev)

## 0) 로컬 준비
- [ ] Terraform 버전 확인 (`terraform -version`)
- [ ] AWS CLI 인증 확인 (`aws sts get-caller-identity`)
- [ ] 작업 디렉터리 확인 (`environments/dev` 기준)

## 1) 코드/설정 확인
- [ ] `environments/dev/terraform.tfvars` 필수 값 확인
- [ ] `lambda_package_file` 경로 확인
- [ ] `rabbitmq_rotation_lambda_package_file` 경로 확인
- [ ] `cloudfront_signed_cookie_public_key_id`를 실제 값으로 교체

## 2) 원격 상태(backend) 준비
- [ ] `global/backend` apply 완료
- [ ] `environments/dev/backend.hcl` 작성 완료
- [ ] `terraform -chdir=environments/dev init -backend-config=backend.hcl -migrate-state` 실행

## 3) 사전 검증
- [ ] `terraform -chdir=environments/dev fmt -check` 실행
- [ ] `terraform -chdir=environments/dev validate` 실행
- [ ] `terraform -chdir=environments/dev plan -out tfplan` 결과 검토

## 4) 최초 배포
- [ ] `terraform -chdir=environments/dev apply tfplan` 실행
- [ ] Route53/ACM/CloudFront 생성 대기 상태 확인
- [ ] ALB DNS, CloudFront 도메인, 모니터링 인스턴스 출력값 확인

## 5) 배포 직후 점검
- [ ] Admin/User 대상 ALB 라우팅 확인
- [ ] HTTPS 인증서 연결 확인
- [ ] S3 업로드/CloudFront 조회 확인
- [ ] Lambda 스케줄 트리거 및 로그 동작 확인
- [ ] RabbitMQ 접속/권한/비밀번호 동기화 확인