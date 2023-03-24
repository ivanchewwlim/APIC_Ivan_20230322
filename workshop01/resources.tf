
#pull the image from docker
resource "docker_image" "bgg-database-image" {
    name = var.db_image_name
}
resource "docker_image" "bgg-backend-image" {
    name = var.backend_image_name
}

resource "docker_network" "bgg-net-res" {
  name = "${var.app_namespace}-bgg-net"
}

resource "docker_volume" "bgg-database-vol-01-res" {
  name = "${var.app_namespace}-bgg-database-vol-01"
}
#run container
resource "docker_container" "bgg-database-res"{
    name ="${var.app_namespace}-bgg-database"
    image = docker_image.bgg-database-image.image_id
    restart = "always"
    networks_advanced {
      name = docker_network.bgg-net-res.id
    }
    ports {
        internal = 3306
        external = 3306
    }
    volumes {
      container_path = "/var/lib/mysql"
      volume_name  = docker_volume.bgg-database-vol-01-res.name

    }

}
resource "docker_container" "bgg-backend"{
    count = var.backend_instance_count
    name ="${var.app_namespace}-bgg-backend-${count.index}"
    image = docker_image.bgg-backend-image.image_id
    restart = "always"
    networks_advanced {
      name = docker_network.bgg-net-res.id
    }
    ports {
        internal = 3000
        external = 8080 + count.index
    }

    env = [
        "BGG_DB_USER=root",
        "BGG_DB_PASSWORD=changeit",
        "BGG_DB_HOST=${docker_container.bgg-database-res.name}"
    ]
}

resource "local_file" "nginx-conf-res" {
    filename = "nginx-conf"
    content = templatefile("nginx.conf.tftpl",{
    docker_host = "206.189.153.102",
    ports = docker_container.bgg-backend[*].ports[0].external
    })
}
resource "digitalocean_droplet" "bgg-web-res" {
  image  = "ubuntu-20-04-x64"
  name   = "bgg-web"
  region = "sgp1"
  size   = "s-1vcpu-512mb-10gb"
  ssh_keys = ["f7:eb:3a:fe:54:cb:fc:95:b4:ad:49:6d:a6:a7:4d:17"]
    connection {
        host = self.ipv4_address
        user = "root"
        type = "ssh"
        private_key = file("id_rsa_iacproj")
        timeout = "2m"
      
    }

    provisioner "remote-exec" {
      inline = [
        "/usr/bin/apt update -y",
        "/usr/bin/apt upgrade -y",
        "/usr/bin/apt install nginx -y",
        "/usr/bin/systemctl start nginx",
        "/usr/bin/systemctl enable nginx"
      ]
    }
    provisioner "file" {
        source = "nginx-conf"
        destination = "/etc/nginx/nginx.conf"
      
    }
        provisioner "remote-exec" {
      inline = [
        "/usr/bin/systemctl restart nginx"
      ]
    }
}

data digitalocean_ssh_key "IaCProject" {
    name = "IaCProject"
}

output IaCProject_fingerprint {
    description ="IaCProject_fingerprint"
    value = data.digitalocean_ssh_key.IaCProject.fingerprint
}
output "backend_ports" {
    value = docker_container.bgg-backend[*].ports[*].external
}