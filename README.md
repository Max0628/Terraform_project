![專案架構](project_structure.png)

## 使用 Terraform 部署 AWS 機器

此 Terraform 腳本可用於在 AWS 上建立一個包含公網和私網的 VPC，並配置 Internet Gateway 和 NAT Gateway，以允許外部連接和跳板機連接到私網中的 EC2 實例。

### 建立 VPC

在 VPC 中，我們將創建以下子網：

- **VPC 網段**:10.0.0.0/16
- **公網子網**：10.0.0.0/24
- **私網子網**：10.0.1.0/24

### 使用 Terraform

在使用此腳本之前，請確保已執行以下步驟：

1. 安裝 Terraform
2. 配置 AWS 存取憑證

### 部署流程

1. 安裝 terraform cli：

   ```bash
   brew install terraform
   ```

1. 初始化 Terraform：

   ```bash
   terraform init
   ```

1. 檢視部署計畫：

   ```bash
   terraform plan
   ```

1. 執行部署：
   ```bash
   terraform apply
   ```

### 連接到 EC2 實例

在部署後，您可以通過以下步驟連接到私網中的 EC2 實例：

1. 更改私鑰檔案的權限：

   ```bash
   chmod 600 pub_subnet_private_key.pem
   chmod 600 pvt_subnet_private_key.pem
   ```

2. 使用 Terraform 輸出來檢視連接語法：

   ```bash
   terraform output
   ```

3. 更新系統套件確認功能正常：
   ```bash
   sudo apt update
   ```

### 附註

- 請確保您的 AWS 存取憑證正確配置，並具有足夠的權限來創建所需的 AWS 資源。
- 請仔細檢查 Terraform 輸出以獲取正確的連接語法和相關資訊。

希望這份 README 能幫助您順利部署 AWS 資源！
