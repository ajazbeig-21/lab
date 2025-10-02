# AWS ECR Docker Deployment Lab

This repository contains a sample FastAPI application with Docker containerization and AWS Elastic Container Registry (ECR) deployment instructions.

## Project Structure

```
├── Dockerfile          # Docker configuration for the FastAPI app
├── README.md           # This file
└── main.py            # FastAPI application (to be created)
```

## Prerequisites

Before you begin, ensure you have the following installed:

- [Docker](https://docs.docker.com/get-docker/)
- [AWS CLI](https://aws.amazon.com/cli/) (latest version)
- AWS account with ECR access
- Proper AWS credentials configured

## Application Overview

This is a lightweight FastAPI application containerized using Docker. The application:
- Uses Python 3.11 slim base image
- Runs on port 8000
- Uses Uvicorn as the ASGI server

## Local Development

### Building the Docker Image

```bash
docker build -t your-app-name .
```

### Running Locally

```bash
docker run -p 8000:8000 your-app-name
```

The application will be available at `http://localhost:8000`

## AWS ECR Deployment

### Step 1: Create ECR Repository

First, create an ECR repository in your AWS account:

```bash
aws ecr create-repository --repository-name your-app-name --region your-region
```

### Step 2: Authenticate Docker to ECR

Retrieve an authentication token and authenticate your Docker client to your registry:

```bash
aws ecr get-login-password --region your-region | docker login --username AWS --password-stdin your-account-id.dkr.ecr.your-region.amazonaws.com
```

**Note:** If you receive an error using the AWS CLI, make sure that you have the latest version of the AWS CLI and Docker installed.

### Step 3: Build Docker Image

Build your Docker image using the following command:

```bash
docker build -t your-app-name .
```

**Note:** You can skip this step if your image has already been built.

### Step 4: Tag Your Image

After the build is completed, tag your image so you can push it to the ECR repository:

```bash
docker tag your-app-name:latest your-account-id.dkr.ecr.your-region.amazonaws.com/your-app-name:latest
```

### Step 5: Push to ECR

Run the following command to push this image to your ECR repository:

```bash
docker push your-account-id.dkr.ecr.your-region.amazonaws.com/your-app-name:latest
```

## Environment Variables

Replace the following placeholders with your actual values:

- `your-app-name`: Your application/repository name
- `your-region`: Your AWS region (e.g., `us-east-1`, `us-west-2`)
- `your-account-id`: Your AWS account ID (12-digit number)

## Security Best Practices

- Never commit AWS credentials to version control
- Use IAM roles when possible
- Regularly rotate access keys
- Follow the principle of least privilege for ECR permissions

## Troubleshooting

### Common Issues

1. **Authentication Failed**: Ensure your AWS credentials are properly configured
2. **Docker Login Issues**: Verify you have the latest AWS CLI and Docker versions
3. **Permission Denied**: Check your IAM policies for ECR permissions

### Required IAM Permissions

Your AWS user/role needs the following ECR permissions:
- `ecr:GetAuthorizationToken`
- `ecr:BatchCheckLayerAvailability`
- `ecr:GetDownloadUrlForLayer`
- `ecr:BatchGetImage`
- `ecr:InitiateLayerUpload`
- `ecr:UploadLayerPart`
- `ecr:CompleteLayerUpload`
- `ecr:PutImage`

## Additional Resources

- [AWS ECR Documentation](https://docs.aws.amazon.com/ecr/)
- [Docker Documentation](https://docs.docker.com/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)

## License

This project is for educational purposes and demonstration of AWS ECR integration with Docker.
