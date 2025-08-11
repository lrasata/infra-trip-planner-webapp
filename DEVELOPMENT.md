# Instructions for Setting Up Infrastructure with Terraform

## Prerequisites

- Terraform >= 1.3 installed: https://www.terraform.io/downloads.html
- Access to AWS configured

## Getting Started

1. Clone the repository:

```bash
git clone https://github.com/lrasata/infra-trip-design-app.git
cd infra-trip-design-app
```

2. Initialize Terraform:

````bash
terraform init
````

3. Fromat configuration:

````bash
terraform fmt
````

4. Validate configuration:

````bash
terraform validate
````

4. Review changes:

````bash
terraform plan
````

5. Apply infrastructure:

````bash
terraform apply
````

## Important Files

````text
infra-trip-design-app/
├── cloudfront.tf                   
├── ecs.tf                    
├── nb.tf                 
├── rds.tf                  
├── s3.tf    
├── secrets-manager.tf     
├── vpc.tf                   
├── variables.tf                  # Input variables
├── outputs.tf                    # Output values
├── .terraform.lock.hcl           # provider dependency lock
````

## Notes

- Always review the output of terraform plan before applying changes.
- Keep .terraform.lock.hcl committed for consistent provider versions.

## Destroying Infrastructure

To tear down all resources managed by this project:

````bash
terraform destroy
````