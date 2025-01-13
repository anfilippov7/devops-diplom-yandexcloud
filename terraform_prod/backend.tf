terraform {
  backend "s3" {
    endpoint = "storage.yandexcloud.net"
    bucket = "cicd-state"
    region = "ru-central1"
    key = "cicd-state/terraform.tfstate"
    skip_region_validation = true
    skip_credentials_validation = true
  }
}
