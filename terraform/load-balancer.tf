resource "yandex_lb_target_group" "target_group" {
  name      = "target-group"
  region_id = "ru-central1"

  # TODO возможно переписать это через циклы? чтобы автоматически заносились все рабочие ноды
  target {
    address   = yandex_compute_instance.management.network_interface.0.ip_address
    subnet_id = yandex_compute_instance.management.network_interface.0.subnet_id
  }

  target {
    address   = yandex_compute_instance.worker1.network_interface.0.ip_address
    subnet_id = yandex_compute_instance.worker1.network_interface.0.subnet_id
  }

  target {
    address   = yandex_compute_instance.worker2.network_interface.0.ip_address
    subnet_id = yandex_compute_instance.worker2.network_interface.0.subnet_id
  }


  depends_on = [
    yandex_compute_instance.management,
    yandex_compute_instance.worker1,
    yandex_compute_instance.worker2,
    yandex_vpc_network.net
  ]
}


resource "yandex_lb_network_load_balancer" "network_balancer" {
  name                = "network-balancer"
  listener {
    name        = "app-listener"
    port        = 80
    target_port = 30081
    protocol    = "tcp"
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  ## alertmanager
  listener {
    name        = "alert-manager-listener-diploma"
    port        = 9093
    target_port = 30903
    protocol    = "tcp"
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  ## graphana
  listener {
    name        = "graphana-listener-diploma"
    port        = 8080
    target_port = 30680
    protocol    = "tcp"
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  ## prometheus
  listener {
    name        = "prometheus-listener-diploma"
    port        = 9090
    target_port = 30090
    protocol    = "tcp"
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.target_group.id

    healthcheck {
      name = "tcp"
      tcp_options {
        port = 30081
      }
    }
  }

  depends_on = [
    yandex_compute_instance.management,
    yandex_compute_instance.worker1,
    yandex_compute_instance.worker2,
    yandex_vpc_network.net
  ]
}
