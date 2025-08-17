module "db" {
  source     = "terraform-aws-modules/rds/aws"
  identifier = "${var.environment}-db-trip-planner"

  engine            = "postgres"
  engine_version    = "15.7"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = var.database_name
  username = local.datasource_username
  password = local.datasource_password
  port     = 5432

  vpc_security_group_ids = [aws_security_group.sg_rds.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name

  publicly_accessible = false
  skip_final_snapshot = true

  family = "postgres15"
}


resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.environment}-trip-planner-rds-subnet-group"
  subnet_ids = module.vpc.private_subnets # At least two subnets in different AZs
}

resource "aws_security_group" "sg_rds" {
  name        = "${var.environment}-rds-sg"
  description = "Allow ECS tasks access to database and internet"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}