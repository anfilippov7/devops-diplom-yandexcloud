terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.75.0"
    }
  }
}

provider "yandex" {
  token     = var.YC_TOKEN
  cloud_id  = var.CLOUD_ID
  folder_id = var.FOLDER_ID
  zone      = var.default_zone
}
