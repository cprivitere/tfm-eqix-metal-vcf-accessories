locals {
  project_id      = var.create_project ? element(equinix_metal_project.vcf[*].id, 0) : element(data.equinix_metal_project.vcf[*].id, 0)
  vlan_id         = var.create_vlan ? element(equinix_metal_vlan.vm-mgmt[*].id, 0) : element(data.equinix_metal_vlan.vm-mgmt[*].id, 0)
  vxlan           = var.create_vlan ? element(equinix_metal_vlan.vm-mgmt[*].vxlan, 0) : element(data.equinix_metal_vlan.vm-mgmt[*].vxlan, 0)
  cluster_gateway = var.cluster_gateway == "" ? cidrhost(var.esx_mgmt_subnet, 1) : var.cluster_gateway
}
resource "equinix_metal_device" "bastion" {
  project_id = local.project_id
  hostname   = "bastion"

  user_data = templatefile("${path.module}/templates/bastion-userdata.tmpl", {
    metal_vlan_id   = local.vxlan,
    address         = cidrhost(var.esx_mgmt_subnet, 2),
    netmask         = cidrnetmask(cidrsubnet(var.esx_mgmt_subnet, -1, -1)),
    gateway_address = local.cluster_gateway,
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

resource "equinix_metal_project" "vcf" {
  count           = var.create_project ? 1 : 0
  name            = var.metal_project_name
  organization_id = var.metal_organization_id
}

data "equinix_metal_project" "vcf" {
  count      = var.create_project ? 0 : 1
  name       = var.metal_project_name != "" ? var.metal_project_name : null
  project_id = var.metal_project_id != "" ? var.metal_project_id : null
}

resource "equinix_metal_vlan" "vm-mgmt" {
  count       = var.create_vlan ? 1 : 0
  project_id  = local.project_id
  description = var.metal_vlan_description
  metro       = var.metal_metro
}

data "equinix_metal_vlan" "vm-mgmt" {
  count      = var.create_vlan ? 0 : 1
  project_id = local.project_id
  vxlan      = var.metal_vlan_id
}

module "ssh" {
  source     = "./modules/ssh/"
  project_id = local.project_id
}
