resource "local_file" "hosts_cfg_kubespray" {
#  count = var.exclude_ansible ? 0 : 1 # Если exclude_ansible true, ресурс не создается

  content  = templatefile("${path.module}/hosts.tftpl", {
    management_ext_ip = yandex_compute_instance.management.network_interface.0.nat_ip_address
    management_int_ip = yandex_compute_instance.management.network_interface.0.ip_address
    worker1_ext_ip   = yandex_compute_instance.worker1.network_interface.0.nat_ip_address
    worker1_int_ip   = yandex_compute_instance.worker1.network_interface.0.ip_address
    worker2_ext_ip   = yandex_compute_instance.worker2.network_interface.0.nat_ip_address
    worker2_int_ip   = yandex_compute_instance.worker2.network_interface.0.ip_address
  })
  filename = "../../kubespray/inventory/mycluster/hosts.yaml"
#  filename = "${path.module}/hosts.yaml"
}
