resource "equinix_metal_device" "bastion" {
  project_id = var.metal_project_id
  hostname   = "bastion"

  user_data = templatefile("${path.module}/templates/bastion-userdata.tmpl", {
    vm_mgmt_vlan_id = var.vm_mgmt_vlan_id,
    address         = cidrhost(var.esx_mgmt_subnet, 2),
    netmask         = cidrnetmask(var.esx_mgmt_subnet),
    gateway_address = var.vm_mgmt_gateway,
  })

  operating_system    = "ubuntu_24_04"
  plan                = var.metal_bastion_plan
  metro               = var.metal_metro
  project_ssh_key_ids = [module.ssh.equinix_metal_ssh_key_id]

}

resource "equinix_metal_port" "bastion_bond0" {
  depends_on      = [equinix_metal_device.bastion]
  port_id         = [for p in equinix_metal_device.bastion.ports : p.id if p.name == "bond0"][0]
  layer2          = false
  bonded          = true
  vlan_ids        = [data.equinix_metal_vlan.vm-mgmt.vlan_id]
  reset_on_delete = true
}


resource "equinix_metal_project" "vcf" {
  count           = var.create_project ? 1 : 0
  name            = var.metal_project_name
  organization_id = var.metal_organization_id
}

data "equinix_metal_vlan" "vm-mgmt" {
  project_id = var.metal_project_id
  vxlan      = var.vm_mgmt_vlan_id
}

module "ssh" {
  source     = "./modules/ssh/"
  project_id = var.metal_project_id
}

resource "equinix_metal_bgp_session" "bastion_bgp" {
  device_id      = equinix_metal_device.bastion.id
  address_family = "ipv4"
}
