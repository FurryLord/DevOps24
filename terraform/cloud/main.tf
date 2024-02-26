terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone  = "ru-central1-a"
  token = "t1.9euelZqci47Kl5qQi4zMzJHHi4-Rie3rnpWamJWTlszJl4vHnczIipCQiovl8_dFahNR-e8mUgpV_d3z9wUZEVH57yZSClX9zef1656VmsaMjYnMlouTzc6bypOPzMea7_zN5_XrnpWazcuVmZiVksaZk4-Pi4uZyZvv_cXrnpWaxoyNicyWi5PNzpvKk4_Mx5o.-Xly9g-SDYvNNSS7GSu_DmKy15GIV6jEBxmXHuHWOogk5NNwc3Iez2lpa15NqF2dq7j5kQqfCzi3LfJ_DZuwBg"
}

resource "yandex_compute_disk" "boot-disk-1" {
  name      = "boot-disk-1"
  type      = "network-hdd"
  zone      = "ru-central1-a"
  size      = "20"
  image_id  = "fd87ap2ld09bjiotu5v0"
  folder_id = "b1gvup3s47j516kd9hdh"
}

resource "yandex_compute_disk" "boot-disk-2" {
  name      = "boot-disk-2"
  type      = "network-hdd"
  zone      = "ru-central1-a"
  size      = "20"
  image_id  = "fd87ap2ld09bjiotu5v0"
  folder_id = "b1gvup3s47j516kd9hdh"
}

resource "yandex_compute_instance" "vm-1" {
  name = "terraform1"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-1.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

   metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
  folder_id = "b1gvup3s47j516kd9hdh"
}

resource "yandex_compute_instance" "vm-2" {
  name = "terraform2"

  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-2.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
  folder_id = "b1gvup3s47j516kd9hdh"
}

resource "yandex_vpc_network" "network-1" {
  name      = "network1"
  folder_id = "b1gvup3s47j516kd9hdh"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
  folder_id = "b1gvup3s47j516kd9hdh"
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}

output "internal_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface.0.ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}

output "external_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface.0.nat_ip_address
}

