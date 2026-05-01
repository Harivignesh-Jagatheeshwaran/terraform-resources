variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster (private subnets recommended)"
  type        = list(string)
}

variable "cluster_endpoint_public_access" {
  description = "Whether the EKS API server endpoint is publicly accessible"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR blocks allowed to access the public API endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_endpoint_private_access" {
  description = "Whether the EKS API server endpoint is accessible within the VPC"
  type        = bool
  default     = true
}

variable "cluster_log_types" {
  description = "List of EKS cluster control plane log types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cluster_log_retention_days" {
  description = "Number of days to retain EKS control plane logs in CloudWatch"
  type        = number
  default     = 1
}

variable "node_groups" {
  description = "Map of EKS managed node group configurations"
  type = map(object({
    instance_types  = list(string)
    capacity_type   = string           # ON_DEMAND or SPOT
    min_size        = number
    max_size        = number
    desired_size    = number
    disk_size_gb    = number
    ami_type        = string 
    labels          = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string                  # NO_SCHEDULE, NO_EXECUTE, PREFER_NO_SCHEDULE
    }))
  }))
  default = {
    general = {
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      disk_size_gb   = 20
      ami_type       = "AL2_x86_64"
      labels         = {}
      taints         = []
    }
  }
}

variable "enable_irsa" {
  description = "Enable IAM Roles for Service Accounts (OIDC provider)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
