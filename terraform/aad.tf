resource "azuread_group" "aks_admin_group" {
  display_name = var.aks_admin_group_name
}
