output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}


output "private_subnet_cidrs" {
  value = module.vpc.private_subnets_cidr_blocks
}

output "public_subnet_cidrs" {
  value = module.vpc.public_subnets_cidr_blocks
}