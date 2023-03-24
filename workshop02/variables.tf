variable do_token {
    type = string
    sensitive = true
}

variable db_image_name {
    type = string
    default = "chukmunnlee/bgg-database:v3.1"
}

variable backend_image_name {
    type = string
    default = "chukmunnlee/bgg-backend:v3"
}
variable app_namespace {
    type = string
    default = "ic"
}
variable backend_instance_count {
    type = number
    #default is to put the nax for index counting
    default = 3 
}
variable ssh_private_key {
    type = string
}