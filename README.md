
# Serpent Surge - The browser based Snake game

This is a browser based game what is about the old Snake game, what you probably played on your old Nokia.

This game is using an AWS infrustructure, what you can build with this repository. I will walk through in the building process.

**This guide does not show all the little things that go into deploy the game, it only gives a superficial overview!**

**Follow my guide at your own risk!**




## What techonologies are this game using?

 - Ansible
 - Docker
 - Terraform


## The game

<img width="853" alt="game" src="https://github.com/Sanya0321/serpent-surge-ssd/blob/1c10b41f62373d2a7a280cd306214c787f275e94/img/Screenshot%20from%202025-08-17%2015-07-23.png">


## Preparation

**Check all the configs what the repository has, because some parts can be different then what you needs!** 

Firstly if you use Linux, you need to pull the repository where you want. Open the terminal and copy this in:

```bash
  git pull https://github.com/Sanya0321/serpent-surge-ssd.git
```

If you are using Windows or MacOS, just download as a zip, what you can find in green "Code" icon, and then at the bottom you will find a button which says "Download ZIP".

## AWS setup

You need to sign up to AWS if you don't have an account. This will be cost 1$ what you got back after approximately 1 months. If you have done this, you need to create an IAM user what is will be for Terraform. This requires several policies, what I give for you. There is it:

```bash
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
Then when you created, you need to create an access key, to be able to use AWS cli. To do that, you need to click on your newly created user and then you need to choose **"Security credentials"**, then if you scroll down a little you will find an **"Access keys"** named field where you need to click on  **"Create access key"**, then you need to choose the first one what is **"Command Line Interface (CLI)"**, then you need to tick confirmation, what you find the bottom of the field. After that you need to click on "Next" (the naming part doesn't effect the setup, so that's not really important). After you go through, you will see your access key with your secret access key. **These are really important for the AWS cli, so save it to yourself!**

When you have done this, you need to install AWS cli to your computer. On Linux you need to use ```sudo snap install aws-cli --classic``` on Windows, you need to download this: https://awscli.amazonaws.com/AWSCLIV2.msi and then install it. You need to also do this on MacOS, https://awscli.amazonaws.com/AWSCLIV2.pkg  these setups are walk you through the installation processes. When you installed it whenever what OS are you using, you need to type to the terminal or the PowerShell this: ```aws configure```
this will requires your access key, your secret access key, region what you use (like us-east-1) and the file format (use json).
You can check what you did with: ```
                              aws sts get-caller-identity
                                           ```                        

## Terraform installation

You need to download Terraform to your local computer, what can be different based on the os what you use (this can helps you: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

## Building infrastructure with Terraform

If you are using Linux (if you are not, you need to unzip it first), you just need to navigate to your folder where you download the repository and then you need to go in "terraform" folder then you need to type this to your terminal or PowerShell:

```bash
  terraform init
```

This initialize your Terraform.

**You need to create an SSH pem file what your EC2 will be using!** This is really important, because if you don't do it, you will be have no access outside the AWS control panel. You can do this in different ways. This is a very useful guide for this: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html

You can check what will Terraform done when you apply the things what the configs has: 
```
terraform plan --auto-apply
```
This shows everything what Terraform will do. **"--auto-apply"** is not required, it just skip a question part of the running process.

If the config is right for, you can run it with:
```
terraform apply --auto-approve
```

## Ansible setup and usage

Ansible is copy all the required files to EC2 and set it up all the things properly, like Docker, database, database backup script and so on.

**In inventory.ini file what is in the Ansible directory, you need to change the IP address and the pem file to your EC2 public IP address and you pem file!**

**Then check all the configurations what my Ansible playbook has, because it can be different what you need!** If you are lazy and you are using Linux, and don't want to browse all the folders, where you find what, you can use tree for it. It shows every file what you have in the subfolders too! You can install with:

On Debian based Linux:
```
sudo apt install tree -y
```
On RHEL based Linux:
```
sudo yum install tree -y
```

If everything is all right, you can run it with:

```
ansible-playbook -i inventory.ini main.yml
```

This will do everything what is required for the game. If you are add your EC2 IP to your machine with your domain name on Linux and on MacOS in ```/etc/hosts``` file, or on Windows in ```C:\Windows\System32\drivers\etc\hosts``` you can play with your game! 
 
**CONGRATULATIONS!!!**

You have now a fully properly working secure browser based game with a full AWS infrastructure!





    
