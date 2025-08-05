vpc_cidr              = "10.0.0.0/16"
public_subnet_cidr    = "10.0.1.0/24"
private_subnet_cidr_1 = "10.0.2.0/24"
private_subnet_cidr_2 = "10.0.3.0/24"
everything_through_cidr = "0.0.0.0/0"
sg_ingress_ports      = [80, 443, 22]
ec2_ami               = "ami-084568db4383264d4"
ec2_type              = "t3.small"
ssh_key_name          = "final-pem"

// Important: Replace these placeholder values with your actual secrets.
ssh_public_key        = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzi9P3jeMa/bvkWZQVKNjOAnGiMkbHbKzwgUta7tQlvgbMCdPEXgpO+gPenW1/5JyPhBUIyw7dQcCGEyUldy51L6q6b7Cf+HdS0QtIMe3keVD5ubFWqCb01m28Dwv/5uVa3vz7zkDr7B+P7GDny836beUXk8tKWMqeKM3m94+sZTI4KnO+F19ca8oLuso1mfOJi4+7Tkd56vPChfR59v4KtnHglKT0mrfI9SntFy6IT7G6wM0p+Qx2s90NV7SRd+pCbtyvhCcQwZfrkNz6LT889nBQF9wHrhArXdoGHMVf4hrxnLB8GsBzyilyBsuy1vuIu6IaJIC5ZhAJcoKghgMb"
mysql_db_user         = "admin"
mysql_db_password     = "Strongpassword"

rds_instance_type     = "db.t3.micro"
