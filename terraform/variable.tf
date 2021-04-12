variable "resource_group_name" {
  type        = string
  default     = "demo"
  description = "Resource group name"
}

variable "azure_region" {
  type        = string
  default     = "eastus"
  description = "Azure region"
}

variable "vnet_name" {
  type        = string
  default     = "demo"
  description = "Virtual network name"
}

variable "vnet_cidr" {
  type        = list(any)
  default     = ["10.0.0.0/12"]
  description = "CIDR block for virtual network"
}

variable "private_subnet_name" {
  type        = string
  default     = "private_demo"
  description = "Private subnet name"
}

variable "private_subnet_cidr" {
  type        = list(any)
  default     = ["10.1.0.0/16"]
  description = "CIDR block for private subnet"
}

variable "public_subnet_name" {
  type        = string
  default     = "public_demo"
  description = "Public subnet name"
}

variable "public_subnet_cidr" {
  type        = list(any)
  default     = ["10.2.0.0/24"]
  description = "CIDR block for public subnet"
}

variable "acr_name" {
  type        = string
  default     = "demomdstechinc"
  description = "Contrainer Regisry name"
}

variable "acr_ip_range" {
  type        = list(any)
  default     = ["0.0.0.0/0"]
  description = "List of IP cidr blocks to allow access ACR"
}

variable "public_ip_name" {
  type        = string
  default     = "demo_agw_ip"
  description = "Public ip name to associate with Azure Gateway"
}

variable "aks_admin_group_name" {
  type        = string
  default     = "aks_cluster_admins"
  description = "AKS managed cluster admins group"
}

variable "cluster_name" {
  type        = string
  default     = "aks-demo"
  description = "AKS Cluster name"
}

variable "dns_name" {
  type        = string
  default     = "demoaks"
  description = "AKS Cluster DNS name"
}

variable "auth_ip_range" {
  type        = list(any)
  default     = ["0.0.0.0/0"]
  description = "List of IP cidr blocks to allow access AKS Api server"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.18.14"
  description = "Kubernetes version"
}

variable "min_user_np_count" {
  type        = number
  default     = 1
  description = "Minimu nodes for user nodepool"
}

variable "max_user_np_count" {
  type        = number
  default     = 3
  description = "Minimu nodes for user nodepool"
}

variable "log_analytics_workspace_sku" {
  type = string
  description = "Log analytics workspace SKU"
  default = "PerGB2018"
}

variable "agw_name" {
  type = string
  description = "Application gateway name"
  default = "demo-agw"
}
variable "cert_password" {
  type = string
  description = "Cerificate password file"
}

variable "cert_file" {
  type = string
  description = "PFX certificate file path"
  default = "./mycert.pfx"
}
variable "postgres_service_name" {
  type = string
  description = "Postgresql Server name"
  default = "demo-pg-server"
}
variable "postgresql_sku_name" {
  type = string
  description = "Postgresql SKU name"
  default = "GP_Gen5_2"
}

variable "postgresql_storage" {
  type = string
  description = "Postgresql storage in MB"
  default = "5120"
}

variable "postgresql_admin_login" {
  type = string
  description = "Postgresql admin username"
  default = "user"
}

variable "postgresql_version" {
  type = string
  description = "Postgresql version"
  default = "11"
}

variable "postgresql_db_name" {
  type = string
  description = "Postgresql database name"
  default = "demo-db"
}
