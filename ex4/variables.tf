variable "location"{
    type=string
    default="westeurope"
}

variable "vm_name" {
    type=string
}
variable "vm_password" {
    type=string
    nullable=false
    sensitive = true
    validation {
      condition=length(var.vm_password)>=8
      error_message = "Password must be at least 8 characters"
    }
}