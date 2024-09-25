resource "local_file" "ansible_inventory" {
  content = templatefile("${var.GITHUB_WORKSPACE}/kubespray/inventory/k8s_cluster/hosts.tftpl", {
    control_ext_ip = yandex_compute_instance.control.network_interface.0.nat_ip_address
    control_int_ip = yandex_compute_instance.control.network_interface.0.ip_address
    node1_ext_ip   = yandex_compute_instance.node1.network_interface.0.nat_ip_address
    node1_int_ip   = yandex_compute_instance.node1.network_interface.0.ip_address
    node2_ext_ip   = yandex_compute_instance.node2.network_interface.0.nat_ip_address
    node2_int_ip   = yandex_compute_instance.node2.network_interface.0.ip_address
    
#    control = yandex_compute_instance.control
#    nodes = yandex_compute_instance.node
    
  })
  filename = "${var.GITHUB_WORKSPACE}/kubespray/inventory/k8s_cluster/hosts.yaml"
}

resource "null_resource" "show_env" {
  depends_on = [
    local_file.ansible_inventory
  ]

  provisioner "local-exec" {
    command = "echo -e \"\\n========================= HOSTS.YAML START =========================\\n\" && cat ${var.GITHUB_WORKSPACE}/kubespray/inventory/k8s_cluster/hosts.yaml && echo -e \"\\n========================== HOSTS.YAML END ==========================\\n\""
  }
}

# хотел перенести в ./kubespray/cluster.yml, но не "завелось"
resource "null_resource" "wait_for_port_22_control" {
  depends_on = [
    local_file.ansible_inventory
  ]

  provisioner "local-exec" {
    command = "while ! nc -z ${yandex_compute_instance.control.network_interface.0.nat_ip_address}   22; do sleep   5; done"
  }
}

resource "null_resource" "wait_for_port_22_node1" {
  depends_on = [
    local_file.ansible_inventory
  ]

  provisioner "local-exec" {
    command = "while ! nc -z ${yandex_compute_instance.node1.network_interface.0.nat_ip_address}   22; do sleep   5; done"
  }
}

resource "null_resource" "wait_for_port_22_node2" {
  depends_on = [
    local_file.ansible_inventory
  ]

  provisioner "local-exec" {
    command = "while ! nc -z ${yandex_compute_instance.node2.network_interface.0.nat_ip_address}   22; do sleep   5; done"
  }
}

#resource "null_resource" "wait_for_port_22_nodes" {
#  depends_on = [
#    local_file.ansible_inventory
#  ]
#
#  provisioner "local-exec" {
#    command = "while ! nc -z ${yandex_compute_instance.nodes.network_interface.0.nat_ip_address}   22; do sleep   5; done"
#  }
#}

resource "null_resource" "ansible_provisioner" {
  depends_on = [
    local_file.ansible_inventory,
    null_resource.wait_for_port_22_control,
#    null_resource.wait_for_port_22_nodes,
    null_resource.wait_for_port_22_node1,
    null_resource.wait_for_port_22_node2
  ]

  provisioner "local-exec" {
    command = "cd ${var.GITHUB_WORKSPACE}/kubespray && ansible-playbook -i inventory/k8s_cluster/hosts.yaml cluster.yml -b --become-user=root"
  }
}
