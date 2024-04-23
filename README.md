![project structure](project_structure.png)

## Use Terraform to deploy AWS machine

This Terraform script can build a bastion host, public and private subnets in a VPC, set up an Internet Gateway and a NAT Gateway, and allow internet connectivity with EC2 instances in the private subnet.

### Build VPC

we will build subnet in the VPC:

- **VPC subnet**:10.0.0.0/16
- **public subnet**：10.0.0.0/24
- **private subnet**：10.0.1.0/24

### Use Terraform

before use this script,make sure to do the following steps:

### deployment flow

1. install terraform cli

   ```bash
   brew install terraform
   ```

1. initial Terraform：

   to initialize tf.state

   ```bash
   terraform init
   ```

1. to preview the infrastructure changes：

   ```bash
   terraform plan
   ```

1. deploy machine：
   ```bash
   terraform apply
   ```

### connect to EC2 instance by SSL

After deployment,get connect to EC2 by the follow steps

1. Change the permissions of the private key file(only user can read and write):

   ```bash
   chmod 600 pub_subnet_private_key.pem
   chmod 600 pvt_subnet_private_key.pem
   ```

2. Inspect the connection(use this output for connection):

   ```bash
   terraform output
   ```

3. Update system plugin to make sure it work:
   ```bash
   sudo apt update
   ```
