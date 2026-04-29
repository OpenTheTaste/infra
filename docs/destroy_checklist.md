# Destroy 체크리스트 (dev 전용)

## 안전한 삭제 순서

1. `environments/dev` 스택 삭제
2. 마지막에 `global/backend` 삭제

## dev 환경 삭제

```powershell
terraform -chdir=environments/dev init -backend-config=backend.hcl
terraform -chdir=environments/dev plan -destroy -out destroy.tfplan
terraform -chdir=environments/dev apply destroy.tfplan
```

## 최종 backend 삭제

```powershell
terraform -chdir=global/backend init
terraform -chdir=global/backend plan -destroy -out destroy.tfplan
terraform -chdir=global/backend apply destroy.tfplan
```

## S3 버킷 삭제 실패 시

- 객체 버전(Object Version)과 삭제 마커(Delete Marker)를 먼저 비움
- 이후 `terraform apply destroy.tfplan` 재실행

## 금지 사항

- dev 스택 삭제 전에 backend 버킷/테이블을 먼저 삭제하지 말 것