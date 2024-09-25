# variables

variable "core_fraction" {
  type = string
  # 5, 20, 100
  default = "5"
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
}

variable "CLOUD_ID" {
  description = "Yandex Cloud ID"
  type        = string
  default     = ""
}

variable "FOLDER_ID" {
  description = "Yandex Cloud Folder ID"
  type        = string
  default     = ""
}

variable "access_key" {
  description = "Yandex access_key"
  type        = string
  default     = ""
}

# variable "META" {
#   description = "User data for instances"
#   type        = string
# }

variable "GITHUB_WORKSPACE" {
  description = "GitHub workspace path"
  type        = string
    default     = "/home/aleksander/devops-diplom-yandexcloud"
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
