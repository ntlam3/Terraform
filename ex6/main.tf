resource "random_string" "random" {
    length=6
    special = true
    override_special = "/@!&"
}
resource "azurerm_resource_group" "rg" {
    name="ex6-${random_string.random.result}"
    location=var.location
}


