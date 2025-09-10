#!/bin/bash

# Variables 
CLUSTER_NAME="image-processing-cluster"
REGION="us-east-1"
LAMBDA_FUNCTION_NAME="s3-to-sns"
S3_BUCKET_NAME="task-sprints-1755009377"
SNS_TOPIC_ARN="arn:aws:sns:us-east-1:769566606308:image-processor-topic"
SQS_QUEUE_URL="https://sqs.us-east-1.amazonaws.com/769566606308/image-processor-queue"
ECR_REPO_NAME="image-processor"
AWS_ACCOUNT_ID="769566606308"

echo "Deleting EKS cluster: $CLUSTER_NAME"
eksctl delete cluster --name $CLUSTER_NAME --region $REGION

echo "Deleting Lambda function: $LAMBDA_FUNCTION_NAME"
aws lambda delete-function --function-name $LAMBDA_FUNCTION_NAME --region $REGION

echo "Emptying and deleting S3 bucket: $S3_BUCKET_NAME"
aws s3 rm s3://$S3_BUCKET_NAME --recursive
aws s3api delete-bucket --bucket $S3_BUCKET_NAME --region $REGION

echo "Deleting SNS topic: $SNS_TOPIC_ARN"
aws sns delete-topic --topic-arn $SNS_TOPIC_ARN --region $REGION

echo "Deleting SQS queue: $SQS_QUEUE_URL"
aws sqs delete-queue --queue-url $SQS_QUEUE_URL --region $REGION

echo "Deleting all images in ECR repository: $ECR_REPO_NAME"
aws ecr list-images --repository-name $ECR_REPO_NAME --region $REGION --query 'imageIds[*]' > image_ids.json

if [ -s image_ids.json ]; then
  aws ecr batch-delete-image --repository-name $ECR_REPO_NAME --region $REGION --image-ids file://image_ids.json
else
  echo "No images found in ECR repository."
fi

rm -f image_ids.json

echo "Deleting ECR repository: $ECR_REPO_NAME"
aws ecr delete-repository --repository-name $ECR_REPO_NAME --region $REGION --force

echo "Cleanup complete!"
