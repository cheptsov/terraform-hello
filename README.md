## Getting Started

1. Set up an AWS account
2. Go to the AWS console and create an S3 bucket to store the terraform state (see `environment.tf`)
3. Go to the AWS console  and request a certificate for your domain (see `dns.tf`)
4. Install the AWS command line

```bash
brew install awscli
```

5. Configure the AWS command line

```bash
aws configure
```

6. Install the Terraform command line

```bash
brew install terraform
```

7. Initialize Terraform

```bash
terraform init
```

8. Deploy

```bash
terraform apply
```
