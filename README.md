## Getting Started

1. Set up an AWS account
2. Go to the AWS console and create an S3 bucket to store the terraform state (see `environment.tf`)
3. Install the AWS command line

```bash
brew install awscli
```

4. Configure the AWS command line

```bash
aws configure
```

5. Install the Terraform command line

```bash
brew install terraform
```

6. Initialize Terraform

```bash
terraform init
```

5. Deploy

```bash
terraform apply
```
