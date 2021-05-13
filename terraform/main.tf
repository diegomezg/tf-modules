data "azurerm_resource_group" "rg-dg" {
  name = "diego-gomez"
}
provider "azurerm" {
  # tenant_id       = "${var.tenant_id}"
  # subscription_id = "${var.subscription_id}"
  # client_id       = "${var.client_id}"
  # client_secret   = "${var.client_secret}"
  features {}
}
# storage_account_name: storagetestdg
# container_name: tstate
# access_key: JRjk/BNJLObDCYgAU8UpufOvt9EQfwsudaLVH7b6C84DPlkYdfE4iwsL4+gwmebb5LVjZReRTaYoN5gN6Gr/PQ==

terraform {
  backend "azurerm" {
    resource_group_name  = "diego-gomez"
    storage_account_name = "storagetestdg"
    container_name       = "tstate"
    key                  = "terraform.tfstate"
    access_key           = "JRjk/BNJLObDCYgAU8UpufOvt9EQfwsudaLVH7b6C84DPlkYdfE4iwsL4+gwmebb5LVjZReRTaYoN5gN6Gr/PQ=="
  }
}


# module "resource_group" {
#   source               = "./modules/resource_group"
#   resource_group       = "${var.resource_group}"
#   location             = "${var.location}"
# }


module "network" {
  source               = "./modules/network"
  address_space        = var.address_space
  location             = var.location
  virtual_network_name = var.virtual_network_name
  application_type     = var.application_type
  resource_type        = "NET"
  resource_group       = data.azurerm_resource_group.rg-dg.name
  address_prefix_test  = var.address_prefix_test
}

module "nsg-test" {
  source              = "./modules/networksecuritygroup"
  location            = var.location
  application_type    = var.application_type
  resource_type       = "NSG"
  resource_group      = data.azurerm_resource_group.rg-dg.name
  subnet_id           = module.network.subnet_id_test
  address_prefix_test = var.address_prefix_test
}
module "appservice" {
  source           = "./modules/appservice"
  location         = var.location
  application_type = var.application_type
  resource_type    = "AppService"
  resource_group   = data.azurerm_resource_group.rg-dg.name
}
module "publicip" {
  source           = "./modules/publicip"
  location         = var.location
  application_type = var.application_type
  resource_type    = "publicip"
  resource_group   = data.azurerm_resource_group.rg-dg.name
}

module "vm" {
  source               = "./modules/vm"
  name                 = var.name
  location             = var.location
  size                 = "Standard_B1s"
  username             = "diegomezg"
  subnet_id            = module.network.subnet_id_test
  public_ip_address_id = module.publicip.public_ip_address_id
  #application_type     = var.application_type
  resource_type        = "virtualmachine"
  resource_group_name       = data.azurerm_resource_group.rg-dg.name
}