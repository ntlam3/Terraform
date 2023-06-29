variable location {
    type=string
}
variable vm{
    type=string
    validation {
        condition=length(var.vm) <=10 && startswith(var.vm,"vm-")
        error_message = "Invalid VM name"
    }
}