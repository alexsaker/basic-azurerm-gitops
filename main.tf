locals {
  tags = {
    "env" = "dev"
  }
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${var.project}"
  location = var.location
  tags     = local.tags
}
