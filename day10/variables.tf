variable "environment" {
  type        = string
  description = "the env type"
  default     = "staging"
}

variable "storage_disk" {
  type        = number
  description = "the size of the storage disk"
  default     = 30
}

variable "is_delete" {
  type        = bool
  description = "whether to delete the os disk or not"
  default     = true
}

variable "allowed_location" {
  type        = list(string)
  description = "the allowed locations for resources"
  default     = ["West Europe", "East US", "North Europe"]
}

variable "resource_tags" {
  type        = map(string)
  description = "the tags for the resources"
  default = {
    environment = "staging"
    managed_by  = "terraform"
    department  = "devops"
  }
}

variable "location" {
  type        = string
  description = "the location for resources"
  default     = "North Europe"
}

variable "network_config" {
  type        = tuple([string, string, number])
  description = "the network configuration values"
  default     = ["10.0.0.0/16", "10.0.2.0", 24]
}

#only unique elements
variable "allowed_vm_sizes" {
  type        = list(string)
  description = "Allowed VM sizes"
  default     = ["Standard_DS1_v2", "Standard_DS2_v2", "Standard_DS3_v2"]
}

# Object type
variable "vm_config" {
  type = object({
    size      = string
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  description = "Virtual machine configuration"
  default = {
    size      = "Standard_DS1_v2"
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}








variable "storage_account_name" {
  type    = set(string)
  default = ["tfazurestorageacct01", "tfazurestorageacct02"]

}