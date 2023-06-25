variable resource_group_name {
  type        = string
  #default     = ""
  description = "Resource Group Name"
  validation{
    condition=length(var.resource_group_name)<=5 && startswith(var.resource_group_name,"ex")
    error_message="Invalid name"
  }
}
variable location{
    type=string
    default="eastus"
}