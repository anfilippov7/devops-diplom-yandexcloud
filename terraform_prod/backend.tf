terraform {
  backend "s3" {
    endpoint = "storage.yandexcloud.net"
    bucket = "diplom-state"
    region = "ru-central1"
    key = "diplom-state/terraform.tfstate"
    skip_region_validation = true
    skip_credentials_validation = true
  }
}
