output "db_instance_address" {
  value = module.db.db_instance_address
}

output "db_name" {
  value = module.db.db_instance_name
}

output "rds_sg_id" {
  value = aws_security_group.sg_rds.id
}