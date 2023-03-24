source digitalocean ic-ubuntu-code-server {
    api_token = var.do_token
    image = var.do_image
    region = var.do_region
    size = var.do_size
    ssh_username = var.do_username
    snapshot_name = "ic-ubuntu-code-server-snap"
}

build {
    sources = [
        "source.digitalocean.ic-ubuntu-code-server"
    ]

    provisioner ansible {
        playbook_file = "playbook.yaml"
        ansible_ssh_extra_args = [
          "-oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedKeyTypes=+ssh-rsa"
        ]
    }
}
