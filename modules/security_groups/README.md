# security_groups module

Centralized security groups:
- ALB SG (80/443 from internet)
- Admin SG (admin port from ALB SG)
- User SG (user port from ALB SG)
- RDS SG (db port from admin/user SG)
