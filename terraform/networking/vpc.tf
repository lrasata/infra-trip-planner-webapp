# This module creates a VPC with public and private subnets across 3 AZs in the eu-central-1 region (Frankfurt).
# It creates automatically an Internet Gateway (IGW) and attach it to the VPC. Create a route table for the public subnets with a 0.0.0.0/0 → igw-xxxx route.
# And associate that route table with your 3 public subnets. 
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "${var.environment}-vpc-trip-planner"
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets_ips
  public_subnets  = var.public_subnets_ips

  enable_nat_gateway = true  # allow ECS tasks to pull images from ECR/Docker Hub and install updates
  single_nat_gateway = false # NATGW are AZ resilient, to have Region resilience, we want 1 NATGW per AZ. (route table is handled by the module)
}

# Use gateway endpoint to allow private access to DynamoDB
resource "aws_vpc_endpoint" "dynamodb_gw_endpoint" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.vpc.private_route_table_ids

  tags = {
    Environment = var.environment
  }
}

# Use gateway endpoint to allow private access to s3
resource "aws_vpc_endpoint" "s3_gw_endpoint" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.vpc.private_route_table_ids

  tags = {
    Environment = var.environment
  }
}