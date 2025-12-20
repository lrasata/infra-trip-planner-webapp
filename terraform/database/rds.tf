module "db" {
  source     = "terraform-aws-modules/rds/aws"
  identifier = "${var.environment}-db-trip-planner"

  # Restore from snapshot if provided, else create new DB
  snapshot_identifier = var.restore_db_snapshot_id != "" ? var.restore_db_snapshot_id : null

  engine                  = "postgres"
  engine_version          = "15"
  instance_class          = var.environment == "prod" ? "db.t3.medium" : "db.t3.micro"
  allocated_storage       = var.environment == "prod" ? 50 : 20 # GB
  storage_encrypted       = var.environment == "prod" ? true : false
  multi_az                = true
  backup_retention_period = var.environment == "prod" ? 7 : 0 # number of days

  db_name  = var.database_name
  username = data.terraform_remote_state.security.outputs.datasource_username
  password = data.terraform_remote_state.security.outputs.datasource_password
  port     = 5432

  vpc_security_group_ids = [aws_security_group.sg_rds.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name

  family = "postgres15"

  publicly_accessible = false
  skip_final_snapshot = false # take snapshot before destroy, only restorable if the networking layer did not change
  deletion_protection = true  # prevent accidental deletion
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.environment}-trip-planner-rds-subnet-group"
  subnet_ids = data.terraform_remote_state.networking.outputs.private_subnets # At least two subnets in different AZs
}

resource "aws_security_group" "sg_rds" {
  name        = "${var.environment}-rds-sg"
  description = "Allow ECS tasks access to database and internet"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = []
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}