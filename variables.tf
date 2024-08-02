variable "metal_auth_token" {
  type        = string
  sensitive   = true
  description = "Equinix Metal API token."
}

variable "metal_project_name" {
  type        = string
  default     = ""
  description = <<EOT
  The name of the Metal project in which to deploy the cluster. If `create_project` is false and
  you do not specify a project ID, the project will be looked up by name. One (and only one) of
  `metal_project_name` or `metal_project_id` is required or `metal_project_id` must be set.
  Required if `create_project` is true.
  EOT
}

variable "metal_project_id" {
  type        = string
  default     = ""
  description = <<EOT
  The ID of the Metal project in which to deploy to cluster. If `create_project` is false and
  you do not specify a project name, the project will be looked up by ID. One (and only one) of
  `metal_project_name` or `metal_project_id` is required or `metal_project_id` must be set.
  EOT
}

variable "esx_mgmt_subnet" {
  type        = string
  default     = "172.16.11.0/24"
  description = "esx mgmt subnet"
}

variable "metal_organization_id" {
  type        = string
  default     = null
  description = "The ID of the Metal organization in which to create the project if `create_project` is true."
}

variable "metal_metro" {
  type        = string
  description = "The metro to create the cluster in."
}

variable "create_project" {
  type        = bool
  default     = true
  description = "(Optional) to use an existing project matching `metal_project_name`, set this to false."
}

variable "metal_bastion_plan" {
  type        = string
  default     = "m3.small.x86"
  description = "Which plan to use for the bastion host."
}

variable "vm_mgmt_vlan_id" {
  type        = number
  default     = null
  description = "ID of the VLAN you wish to use."
}
variable "skip_cluster_creation" {
  type        = bool
  default     = false
  description = "Skip the creation of the Nutanix cluster."
}

variable "create_vrf" {
  type        = bool
  default     = true
  description = "Whether to create a new VRF for this project."
}

variable "vrf_id" {
  type        = string
  default     = null
  description = "ID of the VRF you wish to use."
}

variable "vm_mgmt_gateway" {
  description = "The cluster gateway IP address"
  type        = string
  default     = ""
}
