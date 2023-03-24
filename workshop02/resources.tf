

resource "digitalocean_droplet" "code_server_01" {
  image  = "ubuntu-20-04-x64"
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

}
resource "local_file" "nginx-conf-res" {
    filename = "${var.app_namespace}-code-server.inventory.yaml"
    content = templatefile("${var.app_namespace}-code-server.inventory.yaml.tftpl",{
    codeserver_ip = digitalocean_droplet.code_server_01.ipv4_address,
    codeserver = digitalocean_droplet.code_server_01.name,
    PRIVATE_KEY_FILE = "id_rsa"
    codeserver_domain = "codeserver-${digitalocean_droplet.code_server_01.ipv4_address}.nip.io"
    codeserver_password="changeit"
    })
}
data digitalocean_ssh_key "IacClass" {
    name = "IacClass"
}

output IacClass_fingerprint {
    description ="IacClass_fingerprint"
    value = data.digitalocean_ssh_key.IacClass.fingerprint
}
