# outputs

output "master-internal-ip" {
  value = yandex_compute_instance.management.network_interface.0.ip_address
}

output "master-external-ip" {
  value = yandex_compute_instance.management.network_interface.0.nat_ip_address
}

output "worker1-internal-ip" {
  value = yandex_compute_instance.worker1.network_interface.0.ip_address
}

output "worker1-external-ip" {
  value = yandex_compute_instance.worker1.network_interface.0.nat_ip_address
}

output "worker2-internal-ip" {
  value = yandex_compute_instance.worker2.network_interface.0.ip_address
}

output "worker2-external-ip" {
  value = yandex_compute_instance.worker2.network_interface.0.nat_ip_address
}
