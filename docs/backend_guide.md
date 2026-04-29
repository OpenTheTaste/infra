# Backend 가이드 (dev 전용)

## 1) 백엔드 리소스 1회 생성

```powershell
terraform -chdir=global/backend init
terraform -chdir=global/backend plan -out tfplan
terraform -chdir=global/backend apply tfplan
```

## 2) 생성된 백엔드 값 확인

```powershell
terraform -chdir=global/backend output backend_hcl_values
```

## 3) dev 환경 backend 설정

1. `environments/dev/backend.hcl.example`를 `backend.hcl`로 복사
2. 출력값으로 bucket/region/dynamodb table 값을 교체
3. `key`는 dev 전용으로 유지 (`oplust/dev/terraform.tfstate`)

## 4) 로컬 상태를 원격 백엔드로 마이그레이션

```powershell
terraform -chdir=environments/dev init -backend-config=backend.hcl -migrate-state
```