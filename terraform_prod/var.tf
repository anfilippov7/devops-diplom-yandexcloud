# variables

variable "core_fraction" {
  type = string
  # 5, 20, 100
  default = "100"
}

variable "disk_type" {
  type = string
  # network-hdd , network-nvme
  default = "network-hdd"
}

variable "preemptible" {
  type = string
  #true , false
  default = "true"
}

#TF_VAR_
variable "YC_TOKEN" {
  description = "Yandex Cloud token"
  type        = string
  default     = ""
  sensitive = true
}

variable "CLOUD_ID" {
  description = "Yandex Cloud ID"
  type        = string
  default     = ""
  sensitive = true
}

variable "FOLDER_ID" {
  description = "Yandex Cloud Folder ID"
  type        = string
  default     = ""
  sensitive = true
}

variable "ssh_public_key" {
  description = "SSH public key"
  type        = string
  default     = ""
}

variable "ssh_private_key" {
  description = "SSH private key"
  type        = string
  default     = ""
}

variable "bucket_name" {
  type        = string
  default     = "diplom-state"
  description = "VPC network&subnet name"
}

variable "account_name" {
  type        = string
  default     = "service"
  description = "VPC network&subnet name"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "subnet-a" {
  type        = string
  default     = "service"
  description = ""
}

variable "subnet-b" {
  type        = string
  default     = "service"
  description = ""
}
