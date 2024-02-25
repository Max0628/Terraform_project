使用 Terraform 部署 Aws 機器
建立一個 VPC 10.0.0.0/16
內部有公網 10.0.0.0/24
與私網 10.0.1.0/24

使用 internet gateway 與 nat gateway，連接到外部網路
外部使用者可以使用跳板機連線到私網 Ec2

![以下是架構圖](project_strucutre.png)

使用流程
terraform init
terraform plan
terrafomr apply
