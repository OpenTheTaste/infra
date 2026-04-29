output "vpc_id" {
  description = "VPC ID."
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block."
  value       = aws_vpc.this.cidr_block
}

output "internet_gateway_id" {
  description = "Internet gateway ID."
  value       = aws_internet_gateway.this.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs ordered by input AZ list."
  value       = [for i in range(length(var.availability_zones)) : aws_subnet.public[tostring(i)].id]
}

output "private_subnet_ids" {
  description = "Private subnet IDs ordered by input AZ list."
  value       = [for i in range(length(var.availability_zones)) : aws_subnet.private[tostring(i)].id]
}

output "nat_gateway_ids" {
  description = "NAT gateway IDs."
  value       = aws_nat_gateway.this[*].id
}

output "public_route_table_id" {
  description = "Public route table ID."
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "Private route table IDs."
  value       = aws_route_table.private[*].id
}
