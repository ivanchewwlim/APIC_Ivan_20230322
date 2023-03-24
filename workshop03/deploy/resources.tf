
resource "digitalocean_droplet" "code_server_01" {
  image  = data.digitalocean_image.ic-ubuntu-code-server-snap-res.id 
  name   = "${var.app_namespace}-code-server-01"
  region = "sgp1"
  size   = "s-1vcpu-2gb"
  ssh_keys = [data.digitalocean_ssh_key.IacClass.id]#public key
    connection {
        host = self.ipv4_address
        user = "root"
        type = "ssh"
        private_key = file("id_rsa")
        timeout = "2m"
      
    }
    provisioner "remote-exec" {
      inline = [
        "sed -i 's/__codeserver_domain/codeserver-${digitalocean_droplet.code_server_01.ipv4_address}.nip.io/' /etc/nginx/sites-available/code-server.conf",
        "sed -i 's/__codeserver_password/changeit/' /lib/systemd/system/code-server.service",
        "/usr/bin/systemctl restart code-server",
        "/usr/bin/systemctl restart nginx"
      ]
    }


}
data "digitalocean_image" "ic-ubuntu-code-server-snap-res" {
    name = "ic-ubuntu-code-server-snap"
}

data digitalocean_ssh_key "IacClass" {
    name = "IacClass"
}

output nginx_ip {
    value = digitalocean_droplet.code_server_01.ipv4_address
}
