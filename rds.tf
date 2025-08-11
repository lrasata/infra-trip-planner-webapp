module "db" {
  source     = "terraform-aws-modules/rds/aws"
  identifier = "db-trip-design"

  engine            = "postgres"
  engine_version    = "15.7"
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


resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "trip-design-rds-subnet-group"
  subnet_ids = [module.vpc.private_subnets[1], module.vpc.private_subnets[2]] # At least two subnets in different AZs
}

resource "aws_security_group" "sg_rds" {
  name        = "rds-sg"
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