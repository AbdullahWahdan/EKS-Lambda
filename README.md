# Image Processing App

## Overview
This project implements an image processing pipeline on AWS using S3, Lambda, SNS, SQS, and EKS. When an image is uploaded to the S3 bucket, a Lambda function triggers and sends the image URL via SNS and SQS to an EKS-hosted microservice, which processes the image.

---

## Setup

### Prerequisites
- [AWS CLI](https://aws.amazon.com/cli/) (configured with your AWS credentials)  
- [kubectl](https://kubernetes.io/docs/tasks/tools/)  
- [eksctl](https://eksctl.io/)  
- [Node.js](https://nodejs.org/) (v16 or later)  
- [Docker](https://www.docker.com/get-started)  

---

### IAM Roles Setup
- Create IAM roles with appropriate permissions for:  
  - EKS worker nodes  
  - Lambda function (access to S3 and SNS)  
  - Your AWS user (permissions to create/manage EKS, Lambda, S3, SNS, and SQS resources)  

---

### Infrastructure Deployment
Using Terraform:

terraform init
terraform apply
Or using Bash scripts:

Create EKS cluster and node groups

Create S3 bucket for images

Create SNS topic and SQS queue

Create IAM roles and policies

Deploy Lambda function

### Deployment
Build Docker Image
```bash
docker build -t image-processor .
```
### Push Docker Image to AWS ECR
Create ECR repository (if not exists):
```bash
aws ecr create-repository --repository-name image-processor --region us-east-1
```
### Authenticate Docker with ECR:
```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
```
Tag and push the Docker image:
```bash
docker tag image-processor:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/image-processor:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/image-processor:latest
```
### Deploy Kubernetes Resources to EKS
```bash
kubectl apply -f deployment.yaml
```
Check pods status:
```bash
kubectl get pods
```
Get external service URL:
```bash
kubectl get svc image-processor-service
```
### Deploy Lambda Function
- Package Lambda code

- Deploy using AWS CLI or Console

- Set S3 upload trigger

- Configure Lambda to publish to SNS topic

### Testing
Upload Image to S3
```bash
aws s3 cp ./test-image.jpg s3://your-s3-bucket-name/
```
### Monitor Logs
Lambda logs (CloudWatch):

- AWS Console > CloudWatch > Logs > Lambda function logs

EKS pod logs:
```bash
kubectl logs <pod-name>
```

### cleanup
```bash
eksctl delete cluster --name image-processing-cluster --region us-east-1

aws lambda delete-function --function-name your-lambda-function-name --region us-east-1

aws s3 rm s3://your-s3-bucket-name --recursive
aws s3api delete-bucket --bucket your-s3-bucket-name --region us-east-1

aws sns delete-topic --topic-arn arn:aws:sns:us-east-1:<account-id>:image-processor-topic

aws sqs delete-queue --queue-url https://sqs.us-east-1.amazonaws.com/<account-id>/image-processor-queue

aws ecr batch-delete-image --repository-name image-processor --image-ids imageTag=latest --region us-east-1
aws ecr delete-repository --repository-name image-processor --force --region us-eas
```
