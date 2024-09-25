# networks

resource "yandex_vpc_network" "net" {
  name = "net"
}

resource "yandex_vpc_subnet" "subnet-a" {
  name           = "subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = ["10.10.10.0/24"]
}

resource "yandex_vpc_subnet" "subnet-b" {
  name           = "subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = ["10.10.20.0/24"]
}

# Зону ru-central1-c выводят из эксплуатации и присутствуют квоты на выделение адресов,
# в зоне ru-central1-d нет платформы standard-v1
# resource "yandex_vpc_subnet" "subnet-d" {
#   name           = "subnet-d"
#   zone           = "ru-central1-d"
#   network_id     = yandex_vpc_network.net.id
#   v4_cidr_blocks = ["10.10.30.0/24"]
# }
