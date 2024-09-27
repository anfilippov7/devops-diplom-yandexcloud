# variables

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

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
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
