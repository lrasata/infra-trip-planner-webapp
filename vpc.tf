# This module creates a VPC with public and private subnets across 3 AZs in the eu-central-1 region (Frankfurt).
# It creates automaticallyan Internet Gateway (IGW) and attach it to the VPC. Create a route table for the public subnets with a 0.0.0.0/0 → igw-xxxx route. 
# And associate that route table with your 3 public subnets. 
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "${var.environment}-vpc-trip-planner"
  cidr = "10.0.0.0/16"

  azs             = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true  # allow ECS tasks to pull images from ECR/Docker Hub and install updates
  single_nat_gateway = false # NATGW are AZ resilient, to have Region resilience, we want 1 NATGW per AZ. (route table is handled by the module)
}