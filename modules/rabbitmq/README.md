# rabbitmq module

Infrastructure-only RabbitMQ host module:
- Creates EC2 instance for RabbitMQ host
- Networking/security is provided via input SG
- RabbitMQ runtime/bootstrap is managed outside Terraform (optional user_data only)
