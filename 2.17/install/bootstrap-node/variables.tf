variable "nutanix_user" {
  description = "Prism Central username"
  type        = string
  default     = "admin"
}

variable "nutanix_password" {
  description = "Prism Central password"
  type        = string
  sensitive   = true
}

variable "nutanix_endpoint" {
  description = "Prism Central IP address or hostname"
  type        = string
}

variable "nutanix_port" {
  description = "Prism Central HTTPS port"
  type        = number
  default     = 9440
}

variable "nutanix_insecure" {
  description = "Skip TLS certificate verification"
  type        = bool
  default     = false
}

variable "prism_element_cluster_name" {
  description = "Prism Element cluster where the VM is created"
  type        = string
}

variable "subnet_name" {
  description = "Subnet attached to the bootstrap VM"
  type        = string
}

variable "image_name" {
  description = "Ubuntu 24.04 cloud image in Prism Central"
  type        = string
}

variable "vm_name" {
  description = "Bootstrap VM name"
  type        = string
  default     = "nkp-bootstrap"
}

variable "num_vcpus" {
  description = "Number of vCPUs"
  type        = number
  default     = 4
}

variable "memory_gb" {
  description = "Memory in GiB"
  type        = number
  default     = 8
}

variable "disk_size_gb" {
  description = "Boot disk size in GiB"
  type        = number
  default     = 100
}

variable "ssh_public_key" {
  description = "SSH public key for the nutanix user"
  type        = string

  validation {
    condition     = length(trimspace(var.ssh_public_key)) > 0
    error_message = "ssh_public_key must contain a public SSH key."
  }
}
