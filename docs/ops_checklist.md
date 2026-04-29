# 운영 체크리스트 (dev 반복 작업)

## A) 변경 전
- [ ] 현재 브랜치/변경사항 확인 (`git status`)
- [ ] 민감정보 하드코딩 여부 확인
- [ ] 변경 모듈 영향 범위 확인

## B) 변경 검증
- [ ] `terraform -chdir=environments/dev fmt -check`
- [ ] `terraform -chdir=environments/dev validate`
- [ ] `terraform -chdir=environments/dev plan -out tfplan` 결과 검토
- [ ] replace/destroy 리소스가 의도된 항목인지 확인

## C) 적용
- [ ] `terraform -chdir=environments/dev apply tfplan`
- [ ] 오류 발생 시 원인 리소스와 의존성 즉시 확인

## D) 적용 후 점검
- [ ] ALB 라우팅 및 대상 헬스체크 확인
- [ ] CloudFront 배포 상태(Deployed) 확인
- [ ] Lambda 실행/권한 오류 여부 확인
- [ ] RabbitMQ 메시지/스케일 동작 확인
- [ ] 모니터링(Grafana/Prometheus) 수집 확인

## E) 정기 점검
- [ ] RabbitMQ 자격증명 로테이션 성공 여부 확인
- [ ] 수동 TODO(서명키 운영) 상태 확인
- [ ] 불필요 리소스/비용 발생 여부 점검

## F) 삭제 전
- [ ] `docs/destroy_checklist.md` 순서 확인
- [ ] 필요한 데이터 백업 여부 확인
- [ ] `media_force_destroy=true` 설정 여부 확인