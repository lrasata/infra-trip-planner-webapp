# Instructions for Setting Up Infrastructure with Terraform

## Prerequisites

- Terraform >= 1.3 installed: https://www.terraform.io/downloads.html
- Access to AWS configured
- Secret values are configured saved in Secrets Manager:
  - secrets : `${var.environment}/trip-planner-app/secrets`
    - JWT_SECRET_KEY : TripPlannerAPI JWT secret
    - SPRING_DATASOURCE_USERNAME : RDS database username
    - SPRING_DATASOURCE_PASSWORD : RDS database password
    - SUPER_ADMIN_EMAIL : Email of the super admin user for TripPlannerAPI
    - SUPER_ADMIN_PASSWORD : Password of the super admin user for TripPlannerAPI
    - GEO_DB_RAPID_API_KEY : RapidAPI key for GeoDB
    - CUSTOM_AUTH_SECRET : Secret value of header X-Custom-Auth to request data from LocationsAPI
  - Build folder `dist/` is copied in the root of the project, it contains the compiled frontend application (trip-planner-web-app).
    - Trip-planner-web-app has been built with correct environment variables set:
      - VITE_API_URL : e.g. `VITE_API_URL=https://alb.epic-trip-planner.com`
      - VITE_API_LOCATIONS : e.g. `VITE_API_LOCATIONS=https://epic-trip-planner.com/locations`


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

5. Choose your environment and plan/apply:

This project uses .tfvars files to handle multiple environments (e.g., dev, staging, prod). Environment-specific values like ALB names, domains, and certificates are defined in these files.

Example .tfvars files:

````text
# staging.tfvars
region = "eu-central-1"

environment               = "staging"
api_locations_domain_name = "staging-api-locations.epic-trip-planner.com"
alb_domain_name           = "staging-alb.epic-trip-planner.com"

cloudfront_domain_name = "staging.epic-trip-planner.com"
allowed_origins        = "https://staging.epic-trip-planner.com" # this cannot be * if allowCredentials is true - rejected by Spring

container_image      = "lrasata/trip-planner-backend-app:1.0.0"
super_admin_fullname = "admin"

API_CITIES_GEO_DB_URL    = "https://wft-geo-db.p.rapidapi.com/v1/geo/cities"
API_COUNTRIES_GEO_DB_URL = "https://wft-geo-db.p.rapidapi.com/v1/geo/countries"
GEO_DB_RAPID_API_HOST    = "wft-geo-db.p.rapidapi.com"

bucket_name = "trip-planner-app-bucket"

backend_certificate_arn    = 
cloudfront_certificate_arn = 

hosted_zone_id = 
````

````text
# prod.tfvars
region = "eu-central-1"

environment               = "prod"
api_locations_domain_name = "api-locations.epic-trip-planner.com"
alb_domain_name           = "alb.epic-trip-planner.com"

cloudfront_domain_name = "epic-trip-planner.com"
allowed_origins        = "https://epic-trip-planner.com" # this cannot be * if allowCredentials is true - rejected by Spring


container_image      = "lrasata/trip-planner-backend-app:1.0.0"
super_admin_fullname = "admin"

API_CITIES_GEO_DB_URL    = "https://wft-geo-db.p.rapidapi.com/v1/geo/cities"
API_COUNTRIES_GEO_DB_URL = "https://wft-geo-db.p.rapidapi.com/v1/geo/countries"
GEO_DB_RAPID_API_HOST    = "wft-geo-db.p.rapidapi.com"

bucket_name = "trip-planner-app-bucket"

backend_certificate_arn    = 
cloudfront_certificate_arn = 

hosted_zone_id = 
````

Plan and apply for a specific environment:

````text
terraform plan -var-file="staging.tfvars"
terraform apply -var-file="staging.tfvars"
````

## Important Files

````text
infra-trip-design-app/
├── cloudfront.tf                   
├── ecs.tf  
├── api-gateway.tf                    
├── alb.tf 
├── lambda.tf
├── lambda/handler.js              # Lambda function handler  
├── lambda_edge.tf
├── spa_fallback/index.html  # SPA fallback for CloudFront                 
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
terraform destroy -var-file="staging.tfvars"
````

Replace staging.tfvars with the appropriate tfvars environment file.