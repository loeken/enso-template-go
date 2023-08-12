variable "hostname" {
    type = string
    default = "localhost"
    description = "The address of the server to connect to via SSH."
    validation {
        condition     = var.hostname != ""
        error_message = "The hostname must not be an empty string."
    }
}
variable "port" {
    type = number
    default = 22
    description = "The port of the server to connect to via SSH."
    validation {
        condition     = var.port != ""
        error_message = "The hostname must not be an empty string."
    }
}
variable "user_name" {
    type = string
    default = "user"
    description = "The username to use when connecting to the server via SSH."
    validation {
        condition     = var.user_name != ""
        error_message = "The hostname must not be an empty string."
    }
}