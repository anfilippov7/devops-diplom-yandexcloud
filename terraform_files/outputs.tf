# outputs


#output "all_vms" {
#  value = flatten([
#    [for i in yandex_compute_instance.control : {
#      name = i.name
#      ip_external   = i.network_interface[0].nat_ip_address
#      ip_internal = i.network_interface[0].ip_address
#    }],
#    [for i in yandex_compute_instance.node : {
#      name = i.name
#      ip_external   = i.network_interface[0].nat_ip_address
#      ip_internal = i.network_interface[0].ip_address
#    }]
#  ])
#}



output "control-internal-ip" {
  value = yandex_compute_instance.control.network_interface.0.ip_address
}

output "control-external-ip" {
  value = yandex_compute_instance.control.network_interface.0.nat_ip_address
}

output "node1-internal-ip" {
  value = yandex_compute_instance.node1.network_interface.0.ip_address
}

output "node1-external-ip" {
  value = yandex_compute_instance.node1.network_interface.0.nat_ip_address
}

output "node2-internal-ip" {
  value = yandex_compute_instance.node2.network_interface.0.ip_address
}

output "node2-external-ip" {
  value = yandex_compute_instance.node2.network_interface.0.nat_ip_address
}
