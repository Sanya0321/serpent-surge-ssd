# Serpent Surge - Browser-Based Snake Game

This is a browser-based game inspired by the classic Snake game that you probably played on your old Nokia phone.

The game runs on AWS infrastructure, which you can build using this repository. I will walk you through the setup process.

**Note:** This guide does not cover every small detail required to deploy the game. It only provides a high-level overview.

**Follow this guide at your own risk!**

---

## Technologies Used

- Ansible
- Docker
- Terraform

## The Game

![App Screenshot](https://github.com/Sanya0321/serpent-surge-ssd/blob/1c10b41f62373d2a7a280cd306214c787f275e94/img/Screenshot%20from%202025-08-17%2015-07-23.png)

---

## Preparation

**Check all the configuration files in this repository, because some parts may need to be adjusted for your environment!**

If you are using Linux, clone the repository where you want by running:

```bash
git pull https://github.com/Sanya0321/serpent-surge-ssd.git
```

If you are using Windows or macOS, download the repository as a ZIP file. Click the green **"Code"** button, then select **"Download ZIP"**.

---

## AWS Setup

1. Sign up for an AWS account if you don’t already have one. The signup process costs **$1**, which will be refunded after about one month.  
2. Create an **IAM user** for Terraform. This user requires several policies, which are provided below:

```json
 {
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "AllowVPCAndNetworkManagement",
			"Effect": "Allow",
			"Action": [
				"ec2:CreateVpc",
				"ec2:DeleteVpc",
				"ec2:CreateSubnet",
				"ec2:DeleteSubnet",
				"ec2:CreateInternetGateway",
				"ec2:DeleteInternetGateway",
				"ec2:AttachInternetGateway",
				"ec2:DetachInternetGateway",
				"ec2:CreateRouteTable",
				"ec2:DeleteRouteTable",
				"ec2:AssociateRouteTable",
				"ec2:DisassociateRouteTable",
				"ec2:CreateRoute",
				"ec2:DeleteRoute",
				"ec2:CreateNetworkAcl",
				"ec2:DeleteNetworkAcl",
				"ec2:CreateNetworkAclEntry",
				"ec2:DeleteNetworkAclEntry",
				"ec2:ReplaceNetworkAclEntry",
				"ec2:CreateSecurityGroup",
				"ec2:DeleteSecurityGroup",
				"ec2:AuthorizeSecurityGroupIngress",
				"ec2:AuthorizeSecurityGroupEgress",
				"ec2:RevokeSecurityGroupIngress",
				"ec2:RevokeSecurityGroupEgress",
				"ec2:Describe*",
				"ec2:ModifySubnetAttribute"
			],
			"Resource": "*"
		},
		{
			"Sid": "AllowEC2InstanceManagement",
			"Effect": "Allow",
			"Action": [
				"ec2:RunInstances",
				"ec2:StopInstances",
				"ec2:StartInstances",
				"ec2:RebootInstances",
				"ec2:TerminateInstances",
				"ec2:CreateVolume",
				"ec2:DeleteVolume",
				"ec2:AttachVolume",
				"ec2:DetachVolume",
				"ec2:CreateKeyPair",
				"ec2:ImportKeyPair"
			],
			"Resource": "*"
		},
		{
			"Sid": "AllowRDSManagement",
			"Effect": "Allow",
			"Action": [
				"rds:CreateDBInstance",
				"rds:DeleteDBInstance",
				"rds:ModifyDBInstance",
				"rds:RebootDBInstance",
				"rds:Describe*",
				"rds:DescribeDBSubnetGroups",
				"rds:DescribeDBSecurityGroups",
				"rds:CreateDBSubnetGroup",
				"rds:ListTagsForResource",
				"rds:DeleteDBSubnetGroup"
			],
			"Resource": "*"
		},
		{
			"Sid": "AllowS3Management",
			"Effect": "Allow",
			"Action": [
				"s3:*"
			],
			"Resource": "*"
		},
		{
			"Sid": "AllowECRManagement",
			"Effect": "Allow",
			"Action": [
				"ecr:CreateRepository",
				"ecr:DeleteRepository",
				"ecr:DescribeRepositories",
				"ecr:GetAuthorizationToken",
				"ecr:GetDownloadUrlForLayer",
				"ecr:BatchGetImage",
				"ecr:BatchCheckLayerAvailability",
				"ecr:InitiateLayerUpload",
				"ecr:UploadLayerPart",
				"ecr:CompleteLayerUpload",
				"ecr:PutImage",
				"ecr:ListTagsForResource"
			],
			"Resource": "*"
		},
		{
			"Sid": "AllowIAMManagement",
			"Effect": "Allow",
			"Action": [
				"iam:CreateServiceLinkedRole"
			],
			"Resource": "*"
		},
		{
			"Sid": "AllowTagsAndAllDescribePermissions",
			"Effect": "Allow",
			"Action": [
				"ec2:CreateTags",
				"ec2:DeleteTags",
				"rds:AddTagsToResource",
				"rds:RemoveTagsFromResource",
				"s3:PutBucketTagging",
				"s3:GetBucketTagging",
				"s3:PutObjectTagging",
				"s3:GetObjectTagging",
				"s3:PutObject",
				"ecr:TagResource",
				"ecr:UntagResource"
			],
			"Resource": "*"
		}
	]
}
```

3. After creating the user, generate an **access key** for CLI usage:  
   - Go to **Security credentials**.  
   - Scroll down to **Access keys**.  
   - Click **Create access key**.  
   - Choose **Command Line Interface (CLI)**.  
   - Confirm and continue.  
   - Save both the **Access Key ID** and **Secret Access Key**.  

4. Install AWS CLI:  
   - On Linux:  
     ```bash
     sudo snap install aws-cli --classic
     ```  
   - On Windows: [Download here](https://awscli.amazonaws.com/AWSCLIV2.msi)  
   - On macOS: [Download here](https://awscli.amazonaws.com/AWSCLIV2.pkg)  

5. Configure AWS CLI:  
   ```bash
   aws configure
   ```  
   Provide your **Access Key**, **Secret Key**, **Region** (e.g., `us-east-1`), and set the output format to **JSON**.

6. Verify setup:  
   ```bash
   aws sts get-caller-identity
   ```

---

## Terraform Installation

Download and install Terraform on your local machine. The installation method depends on your operating system. Follow this guide: [Terraform Installation](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

---

## Building Infrastructure with Terraform

1. Navigate to the repository folder and enter the `terraform` directory.  
2. Initialize Terraform:  
   ```bash
   terraform init
   ```  
3. **Create an SSH key pair** (.pem file) for EC2 access. Without this, you will only have access from the AWS control panel. Guide: [Create key pairs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html).  
4. Preview changes:  
   ```bash
   terraform plan
   ```  
5. Apply changes:  
   ```bash
   terraform apply --auto-approve
   ```

---

## SSL creation

First, you need a domain name to run the Ansible setup without errors. You can get a free one by registering at [nic](https://nic.ua/). This may require a credit card for a nominal verification fee. After that, you need to add two A records in your domain's dashboard: one for the root domain (without ```www.```) and one with ```www.```. Both records must point to your EC2 instance's public IP address. **Disclaimer! If you stop your EC2 instance, the public IP address will change when you start again, and your domain will no longer work!** After that, you need to follow this tutorial: [Create a Certificate Using Certbot and Docker](https://www.willianantunes.com/blog/2022/08/create-a-certificate-using-certbot-through-docker/)! When you are done, place the generated certificate files into the roles/app-deployment/files directory in your Ansible playbook.

## Ansible Setup and Usage

Ansible copies all required files to your EC2 instance and sets up everything (Docker, database, backup scripts, etc.).

First, you need to install Ansible on your local machine! There is a guide for it: [Ansible installation](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

Second, you need to create a pem file on AWS! There is a guide for it: [AWS pem file creation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html)


- In the `inventory.ini` file inside the `ansible` directory, update the **IP address** and **.pem file path** with your EC2 details.  
- Review all playbook configurations, as you may need to adapt them to your needs.  
- If you’re on Linux, you can use the `tree` command to quickly see the repository structure:  

  - On Debian/Ubuntu:  
    ```bash
    sudo apt install tree -y
    ```  
  - On RHEL/CentOS:  
    ```bash
    sudo yum install tree -y
    ```  

- Run Ansible:  
  ```bash
  ansible-playbook -i inventory.ini main.yml
  ```
---

## Congratulations!

You now have a fully working, secure, browser-based Snake game running on AWS infrastructure!
