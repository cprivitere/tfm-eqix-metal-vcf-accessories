locals {
  project_id      = var.create_project ? element(equinix_metal_project.nutanix[*].id, 0) : element(data.equinix_metal_project.nutanix[*].id, 0)
  vlan_id         = var.create_vlan ? element(equinix_metal_vlan.nutanix[*].id, 0) : element(data.equinix_metal_vlan.nutanix[*].id, 0)
  vxlan           = var.create_vlan ? element(equinix_metal_vlan.nutanix[*].vxlan, 0) : element(data.equinix_metal_vlan.nutanix[*].vxlan, 0)
  vrf_id          = var.create_vrf ? element(equinix_metal_vrf.nutanix[*].id, 0) : element(data.equinix_metal_vrf.nutanix[*].id, 0)
  cluster_gateway = var.cluster_gateway == "" ? cidrhost(var.cluster_subnet, 1) : var.cluster_gateway
}
resource "equinix_metal_device" "bastion" {
  project_id = local.project_id
  hostname   = "bastion"

  user_data = templatefile("${path.module}/templates/bastion-userdata.tmpl", {
    metal_vlan_id   = local.vxlan,
    address         = cidrhost(var.cluster_subnet, 2),
    netmask         = cidrnetmask(cidrsubnet(var.cluster_subnet, -1, -1)),
    gateway_address = local.cluster_gateway,
    host_dhcp_start = cidrhost(var.cluster_subnet, 3),
    host_dhcp_end   = cidrhost(var.cluster_subnet, 15),
    vm_dhcp_start   = cidrhost(var.cluster_subnet, 16),
    vm_dhcp_end     = cidrhost(var.cluster_subnet, -5),
    lease_time      = "infinite",
    nutanix_mac     = "50:6b:8d:*:*:*",
    set             = "nutanix"
  })

  operating_system    = "ubuntu_22_04"
  plan                = var.metal_bastion_plan
  metro               = var.metal_metro
  project_ssh_key_ids = [module.ssh.equinix_metal_ssh_key_id]
}

resource "equinix_metal_port" "bastion_bond0" {
  port_id  = [for p in equinix_metal_device.bastion.ports : p.id if p.name == "bond0"][0]
  layer2   = false
  bonded   = true
  vlan_ids = [local.vlan_id]
}
