terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "> 0.92" # provider version
    }
  }
}

terraform {
  backend "s3" {
    endpoint = "storage.yandexcloud.net"
    bucket = "cicd-state"
    region = "ru-central1"
    key = "cicd-state/terraform.tfstate"
    access_key = "" 
    secret_key = ""
    skip_region_validation = true
    skip_credentials_validation = true
  }
  required_version = "= 1.5.5" # terraform version
}

provider "yandex" {
  token     = var.YC_TOKEN
  cloud_id  = var.CLOUD_ID
  folder_id = var.FOLDER_ID
  zone      = var.default_zone
}
