locals {
  trip_secrets = jsondecode(data.aws_secretsmanager_secret_version.trip_design_secrets_value.secret_string)
}


module "db" {
  source     = "terraform-aws-modules/rds/aws"
  identifier = "db-trip-design"

  engine            = "postgres"
  engine_version    = "15.3"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = var.database_name
  username = local.trip_secrets["SPRING_DATASOURCE_USERNAME"]
  password = local.trip_secrets["SPRING_DATASOURCE_PASSWORD"]
  port     = 5432

  vpc_security_group_ids = [aws_security_group.sg_rds.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name

  publicly_accessible = false
  skip_final_snapshot = true

  family = "postgres15"
}
