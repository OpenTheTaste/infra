output "id" {
  description = "Selected AMI ID."
  value       = data.aws_ami.selected.id
}

output "name" {
  description = "Selected AMI name."
  value       = data.aws_ami.selected.name
}

output "owner_id" {
  description = "Owner account ID of the selected AMI."
  value       = data.aws_ami.selected.owner_id
}
