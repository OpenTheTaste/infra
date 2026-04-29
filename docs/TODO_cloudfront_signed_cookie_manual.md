# TODO: CloudFront Signed Cookie 키 운영 (현재 수동)

상태: 보류(수동 운영)
작성일: 2026-04-28

## 현재 운영 정책
- 당분간 키 관리는 수동 유지
- 키 변경 반영은 앱 재배포로 처리

## 수동 운영 절차
1. 신규 키 페어 생성/준비
2. CloudFront에 공개키 등록 후 Trusted Key Group에 포함
3. 백엔드 값 갱신
   - Public Key ID (`CloudFront-Key-Pair-Id`)
   - Private Key (백엔드가 참조하는 Secrets Manager/환경 경로)
4. 무중단 방식으로 백엔드(admin/user) 재배포
5. 기존 쿠키 TTL 만료 대기
6. 구 키를 Key Group에서 제거

## apply 전 확인 변수
- `media_cloudfront_trusted_key_group_ids` = Key Group ID 목록
- `cloudfront_signed_cookie_public_key_id` = Public Key ID

## 향후 자동화 TODO
- 옵션 A: 런타임 조회 + 짧은 캐시(1~5분)
- 옵션 B: 승인 단계를 둔 반자동 로테이션 파이프라인