locals {
  ssh-keys = fileexists("~/.ssh/id_ed25519.pub") ? file("~/.ssh/id_ed25519.pub") : var.ssh_public_key
  ssh-private-keys = fileexists("~/.ssh/id_ed25519") ? file("~/.ssh/id_ed25519") : var.ssh_private_key
}

data "template_file" "meta" {
 template = file("${path.module}/meta.yml")
 vars = {
   ssh_public_key = local.ssh-keys
   ssh_private_key = local.ssh-private-keys
 }
}


# instances
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}


#variable "yandex_compute_instance_control" {
#  type        = list(object({
#    vm_name = string
#    cores = number
#    memory = number
#    core_fraction = number
#    count_vms = number
#    platform_id = string
#  }))

#  default = [{
#      vm_name = "control"
#      cores         = 2
#      memory        = 2
#      core_fraction = 5
#      count_vms = 1
#      platform_id = "standard-v1"
#    }]
#}

#variable "boot_disk_control" {
#  type        = list(object({
#    size = number
#    type = string
#    }))
#    default = [ {
#    size = 10
#    type = "network-hdd"
#  }]
#}

#variable "control_count" {
#  type    = number
#  default = 1
#}


#resource "yandex_compute_instance" "control" {
#  name        = "${var.yandex_compute_instance_control[0].vm_name}"
#  platform_id = var.yandex_compute_instance_control[0].platform_id
#  allow_stopping_for_update = true
#  count = var.yandex_compute_instance_control[0].count_vms
#  zone = "ru-central1-a"
#  resources {
#    cores         = var.yandex_compute_instance_control[0].cores
#    memory        = var.yandex_compute_instance_control[0].memory
#    core_fraction = var.yandex_compute_instance_control[0].core_fraction
#  }

#  boot_disk {
#    initialize_params {
#      image_id = data.yandex_compute_image.ubuntu.image_id
#      type     = var.boot_disk_control[0].type
#      size     = var.boot_disk_control[0].size
#    }
#  }



resource "yandex_compute_instance" "control" {
  name = "control"
  zone = "ru-central1-a"
  hostname = "control"
  allow_stopping_for_update = true

  resources {
    core_fraction = var.core_fraction
    cores = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size = 20
      type = var.disk_type
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-a.id
    ip_address = "10.10.10.10"
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh-keys}"
    serial-port-enable = "1"
    user-data          = data.template_file.meta.rendered
  }

  scheduling_policy {
    preemptible = var.preemptible
  }
}

resource "yandex_compute_instance" "node1" {
  name = "node1"
  zone = "ru-central1-b"
  hostname = "node1"
  allow_stopping_for_update = true

  resources {
    core_fraction = var.core_fraction
    cores = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size = 20
      type = var.disk_type
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-b.id
    ip_address = "10.10.20.11"
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh-keys}"
    serial-port-enable = "1"
    user-data          = data.template_file.meta.rendered
  }

  scheduling_policy {
    preemptible = var.preemptible
  }
}

resource "yandex_compute_instance" "node2" {
  name = "node2"
  zone = "ru-central1-b"
  hostname = "node2"
  allow_stopping_for_update = true

  resources {
    core_fraction = var.core_fraction
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size = 20
      type = var.disk_type
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet-b.id
    ip_address = "10.10.20.12"
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh-keys}"
    serial-port-enable = "1"
    user-data          = data.template_file.meta.rendered
  }

  scheduling_policy {
    preemptible = var.preemptible
  }
}
