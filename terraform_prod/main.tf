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
