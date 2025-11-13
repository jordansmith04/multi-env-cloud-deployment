# Multi-Environment Cloud Deployment with Governance

This repository houses the Infrastructure as Code (IaC) and CI/CD pipelines for deploying a containerized application to AWS across three isolated environments: Dev, Stage, and Prod. The project emphasizes strong Cloud Governance practices, including cost control via Budgets and granular access control via IAM.

## 1. Architectural Overview - AWS Fargate

The application infrastructure for each environment is provisioned by Terraform and is fully segregated. The core deployment utilizes AWS ECS Fargate, providing a serverless container solution running within private subnets for enhanced security.

| Component | Function | Implementation Detail | 
| --------- | -------- | --------------------- | 
| Compute | AWS ECS Fargate | Tasks run in Private Subnets. Sizing is scaled based on environment criticality (Dev < Stage < Prod). |
| Networking | Shared VPC (Root Network) | A single VPC is provisioned, with dedicated Public and Private Subnets explicitly tagged (Environment=dev, Environment=stage, etc.).  |
| Ingress | Application Load Balancer (ALB) | Deployed in Public Subnets. Handles Layer 7 routing to Fargate tasks via port 80/443.  |
| Governance | AWS Budgets/IAM | Budgets are tagged per environment for cost monitoring. Custom IAM Roles enforce access only to resources with matching environment tags.  |

## 2. Tools and Technologies

Tool | Purpose | Key Strategy Implemented |
| --------- | -------- | --------------------- |
|Terraform | Infrastructure as Code (IaC) | Utilizes a Modular Structure (e.g., app-service, governance) and S3 Backend with DynamoDB for state locking. |
| GitLab CI | CI/CD Pipeline Orchestration | Enforces a controlled Promotion Model with manual gates for Stage and Prod deployments. |
| Docker | Application Containerization | Standardized container builds ensure application immutability from local development to Production. |
| AWS ECR | Container Registry | Secured registry for storing and versioning application images, triggered by the build stage in CI. |

## 3. Environment and Configuration Strategy

- Environment separation is managed primarily by Terraform variables and resource tagging:

- Network Centralization: A base root-network layer defines the core VPC and all subnets (Dev, Stage, Prod) to ensure consistent addressing.

- Environment Variables: Each environment configuration (dev, stage, prod) injects specific variables into the shared modules:

1. Dev: Small Fargate size, lowest budget_limit ($50).

2. Stage: Medium Fargate size, higher budget_limit ($150).

3. Prod: Largest Fargate size, highest budget_limit ($500).

- IAM Least Privilege: The governance module creates environment-specific IAM roles that are explicitly restricted to managing only resources bearing that Environment tag.

## 4. CI/CD Pipeline Flow (.gitlab-ci.yml)

The GitLab CI pipeline manages the entire deployment lifecycle, ensuring controlled promotion across environments.| 

| Stage | Job | Purpose | Gate/Constraint| 
| --------- | -------- | --------------------- | --------- |
| build | build_image | Builds Docker image and pushes it to ECR, tagged by the commit SHA. | Runs automatically on push to main.| 
| plan | *_plan | Generates and caches the tfplan artifact for infrastructure changes. | Runs automatically for all environments on push to main.| 
| apply | dev_apply | Provisions or updates the Dev environment infrastructure. | Runs automatically after successful dev_plan.| 
| apply | stage_apply | Provisions or updates the Stage environment infrastructure. | Requires a manual trigger (gate) after successful QA verification in Dev.| 
| apply | prod_apply | Provisions or updates the Prod environment infrastructure. | Set to run automatically on merge to main (but typically protected by manual approval in live systems).| 

## 5. Key Takeaways

This project successfully implements a robust cloud architecture by enforcing:

- Environment Isolation: Complete resource separation using network segmentation and resource tagging.

- Infrastructure as Code (IaC): 100% of infrastructure is managed by modular Terraform.

- Security and Cost Governance: Integrated AWS Budgets and tag-based IAM roles into the deployment process.