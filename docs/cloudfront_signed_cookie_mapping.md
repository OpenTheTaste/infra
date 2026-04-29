# CloudFront Signed Cookie ID 매핑 가이드

## 목적
CloudFront Signed Cookie에서 사용하는 ID를 혼동하지 않기 위함입니다.

## ID 종류
- Key Group ID
  - CloudFront 배포의 `trusted_key_group_ids`에 사용
  - Terraform 변수: `media_cloudfront_trusted_key_group_ids`
- Public Key ID
  - 백엔드가 `CloudFront-Key-Pair-Id` 쿠키를 발급할 때 사용
  - Terraform 변수: `cloudfront_signed_cookie_public_key_id`
- Private Key
  - 백엔드에서 정책/서명 생성 시에만 사용
  - Secrets Manager 저장 권장

## 현재 SSM 파라미터(app stack 생성)
프리픽스:
- `/${project}/${environment}/cloudfront/auth`

키:
- `distribution_domain_name`
- `trusted_key_group_ids`
- `signed_cookie_public_key_id`

## apply 전 점검
1. `media_cloudfront_trusted_key_group_ids`에는 Key Group ID만 입력
2. `cloudfront_signed_cookie_public_key_id`는 백엔드 사용 Public Key ID와 일치
3. 백엔드 `resource-url` 도메인이 실제 CloudFront 도메인/별칭과 일치