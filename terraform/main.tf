##--Описание коннектора Облачного Провайдера (в дс. Yandex.Cloud)
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.84.0" # версию необходимо указать только при первичной инициализации Terraform
    }
  }
}

##--Локальные переменные:
##  *iam токен авторизации;
##  *id Облака;
##  *id Каталога;
##  *зона доступности;
##  *public ssh-ключ для авторизации по ключу на серверах;
##
variable "yc_token" { type= string }

locals {
  ## token-created: 2023.03.03 11:07
  ## $ export TF_VAR_yc_token=$(yc iam create-token) && echo $TF_VAR_yc_token
  ## $ export TF_VAR_yc_token="TOKEN_STRING"
  #
  iam_token       = "${var.yc_token}"
  cloud_id        = "b1g0u201bri5ljle0qi2"
  folder_id       = "b1gqi8ai4isl93o0qkuj"
  access_zone     = "ru-central1-b"
  vm1_user        = "ubuntu"                   # Ubuntu image default username;
  vm_pubkey_path  = "~/.ssh/id_ed25519.pub"    # Set a full path to the SSH public key for VM;
  ##
  ## current "acme" net and subnet ids for test hosts
  #acme_net_name = "acme-net"
  #acme_subnet_name = "acme-net-sub1"
  #acme_net1_id = "enp87o91cs7r12jjk8ef"
  #acme_subnet1_id = "e2lg9ight6chsfkcm8tj"     # предполагается что сеть и подсеть созданы 1 раз
}

##--Авторизация на стороне провайдера и указание Ресурсов с которыми будет работать Terraform
provider "yandex" {
  token     = local.iam_token
  cloud_id  = local.cloud_id
  folder_id = local.folder_id
  zone      = local.access_zone
}

##--Создаем VM1 (Ubuntu 20.04, x2 vCPU, x2 GB RAM, x20 GB HDD)
resource "yandex_compute_instance" "host1" {
  name        = "ubuntu1"          # имя ВМ;
  hostname    = "ubuntu1"          # сетевоем имя ВМ (имя хоста);
  platform_id = "standard-v2"      # семейство облачной платформы ВМ (влияет на тип и параметры доступного для выбора CPU);
  zone        = local.access_zone  # зона доступности (размещение ВМ в конкретном датацентре);

  resources {
    cores         = 2 # колво виртуальных ядер vCPU;
    memory        = 2 # размер оперативной памяти, ГБ;
    core_fraction = 5 # % гарантированной доли CPU (самый дешевый вариант, при 100% вся процессорная мощность резервируется для клиента);
  }

  ## Делаем ВМ прерываемой (делает ВМ дешевле на 50% но ее в любой момент могут вырубить что происходит не часто)
  scheduling_policy {
    preemptible = true
  }

  ## Загрузочный образ на основе которого создается ВМ (из Yandex)
  boot_disk {
    initialize_params {
      image_id    = "fd8snjpoq85qqv0mk9gi"    # версия ОС: Ubuntu 20.04 LTS (family_id: ubuntu-2004-lts, image_id: fd8snjpoq85qqv0mk9gi);
      type        = "network-hdd"             # тип загрузочного носителя (network-hdd | network-ssd);
      size        = 20                        # размер диска, ГБ (меньше 5 ГБ выбрать нельзя);
      description = "Ubuntu 20.04 LTS"
    }
  }

  ## Параметры локального сетевого интерфейса
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet1.id   # идентификатор подсети в которую будет смотреть интерфейс;
    #subnet_id  = local.acme_subnet1_id
    ip_address = "10.0.10.10"                   # указываем явно какой внутренний IPv4 адрес назначить ВМ;
    nat        = true                           # создаем интерфейс смотрящий в публичную сеть;
  }

  ## Данные авторизации пользователей на создаваемых ВМ
  metadata = {
    serial-port-enable = 1                                 # активация серийной консоли чтоб можно было подключиться к ВМ через веб-интерфейс;
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"   # самый простой и работающий вариант передачи publick ключа в ВМ;
  }
}


##--В Сервисе "Virtual Private Cloud" (vpc) Создаем Сеть "acme-net" и подсеть "acme-net-sub1"
resource "yandex_vpc_network" "net1" {
  name = "acme-net" # имя сети так она будет отображаться в веб-консоли (чуть выше "net1" - это псевдоним ресурса);
}

resource "yandex_vpc_subnet" "subnet1" {
  name           = "acme-net-sub1"            # имя подсети;
  zone           = local.access_zone          # зона доступности (из локальной переменной);
  network_id     = yandex_vpc_network.net1.id # связь подсети с сетью по id (net1 - это созданный псевдоним Ресурса);
  v4_cidr_blocks = ["10.0.10.0/28"]           # адресное IPv4 пространство подсети;
}

/**
  Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

  Outputs:
    vm1_name_external_ip = "ubuntu1: 130.193.40.23"

*/
