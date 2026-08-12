# devops-simple-app-eks-deployment

A simple DevOps example project demonstrating cloud infrastructure provisioning on AWS using Terraform, containerizing a simple Node.js web app with Docker, hosting in AWS ECR, and deploying to Amazon EKS using Helm.

Last revision:  08/12/2026
Author:  Dan Fereday

---

AI Disclosure

This project was developed with the assistance of generative AI (Google Gemini 1.5 Pro). AI tools were used during development to assist with:

- Writing and refactoring Terraform infrastructure configurations (dynamic AZ lookup).
- Debugging Kubernetes deployment and service manifest port bindings.
- Authoring technical documentation and project guides.

Note on Code Quality & Governance:  All AI-assisted code, infrastructure definitions, and manifests were manually reviewed, validated, and tested end-to-end on AWS EKS before being committed to this repository.

---

Project Architecture & Tech Stack

- Infrastructure as Code: Terraform/AWS Provider
- Cloud Platform:  Amazon Web Services (AWS)
- Compute & Orchestration: Amazon EKS
- Networking: AWS VPC (Multi-AZ with public & private subnets, NAT Gateway)
- Container Registry: Amazon Elastic Container Registry (ECR)
- Ingress / Service: AWS Elastic Load Balancer (Classic/NLB)
- Packaging & Deployment: Docker, Helm Charts
- Application: Basic Node.js Web Server (listening on port 3000)

---

Prerequisites

The following are required to run through this project:
-AWS CLI set up and connected to an account with sufficient IAM privilges 

* [Terraform v1.5+](https://developer.hashicorp.com/terraform/downloads)
* [Docker Desktop / Engine](https://docs.docker.com/get-docker/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/)
* [Helm v3](https://helm.sh/docs/intro/install/)

---
#######################################################################################################################################################
#######################################################################################################################################################


Quick Start & Deployment Guide

Step 1: Provision Infrastructure with Terraform

Initialize and apply the Terraform configuration in project-files/day3-terraform-eks to build the VPC, EKS cluster, and ECR repository in your target AWS region (default: us-west-2).

Navigate to the directory:
cd project-files/day3-terraform-eks

Initialize modules:
terraform init

Apply infrastructure:
terraform apply -auto-approve

Note: Infrastructure provisioning typically takes 10–15 minutes while the EKS control plane and node groups initialize.

---

Step 2: Build & Push Application Container to ECR

Set environment variables, authenticate Docker to ECR, build the application image inside project-files/day1-docker, and push it to your repository.

Set variables (replace 123456789012 with your AWS Account ID):
export AWS_REGION="us-west-2"
export AWS_ACCOUNT_ID="123456789012"
export ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}[.amazonaws.com/day1-app](https://www.google.com/search?q=https%3A%2F%2F.amazonaws.com%2Fday1-app)"

Authenticate Docker to ECR:
aws ecr get-login-password --region $AWS_REGION \vert{} docker login --username AWS --password-stdin$ECR_URI

Build image:
cd ../day1-docker
docker build -t day1-app:v3 .

Tag and push to ECR:
docker tag day1-app:v3 ${ECR_URI}:v3
docker push ${ECR_URI}:v3

---

Step 3: Deploy Application via Helm

Configure your local kubectl context to point to the EKS cluster and deploy using Helm.

Update local kubeconfig:
aws eks update-kubeconfig --region $AWS_REGION --name devops-lab-eks

Navigate to Helm directory:
cd ../day2-chart

Ensure project-files/day2-chart/values.yaml reflects your ECR URI:
image:
repository: <YOUR_AWS_ACCOUNT_ID>[.dkr.ecr.us-west-2.amazonaws.com/day1-app](https://www.google.com/search?q=https%3A%2F%2F.dkr.ecr.us-west-2.amazonaws.com%2Fday1-app)
tag: v3
pullPolicy: IfNotPresent

service:
type: LoadBalancer
port: 80

Deploy the release:
helm upgrade --install eks-release .

---

Step 4: Verify Deployment & Test Endpoint

Check pod status and retrieve the public LoadBalancer DNS name:

kubectl get pods
kubectl get svc eks-release-service

Test application response:
curl http://

---

Teardown & Resource Cleanup

To avoid ongoing AWS charges, destroy resources in reverse order:

1. Uninstall Helm release (releases AWS Load Balancer):
helm uninstall eks-release
2. Force-delete ECR repository contents:
aws ecr delete-repository --repository-name day1-app --region us-west-2 --force
3. Destroy Terraform infrastructure:
cd ../day3-terraform-eks
terraform destroy -auto-approve
4. Clean up local kubeconfig context:
kubectl config delete-context arn:aws:eks:us-west-2:<ACCOUNT_ID>:cluster/devops-lab-eks
