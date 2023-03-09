# sf-pr07-terraform-ansible-docker-postgresql-python-webapp
For Skill Factory study project (PR07 or PR04?)


--КРАТКАЯ ИНСТРУКЦИЯ

1 Управляющий хост (Ubuntu 22.04) - primary host (U22)
- условно локальный хост с которого происходит создание ресурсов в Облаке с помощью Terraform 
  и применение к ним Ansible конфигурации с Ролями "postgresql" и "docker" (IaC конфигурация);
2 Управляемый хост (Ubuntu 20.04) - secondary host (U20)
  - удаленный хост в Облаке к которому применяется IaC конфигурация;


01. На U22
- клонируем репозиторий в рабочий каталог

$ cd work_dir
$ git clone https://github.com/VictorNuzhdin/sf-pr07-terraform-ansible-docker-postgresql-python-webapp.git


02. На U22
- настраиваем Terraform и Ansible окружение
- описание вне рамок текущего проекта


03. На U22
- с помощью Terraform создаем виртуальную машину в Yandex.Cloud
- в результате получаем Terraform output переменную с публичным ip-адресом ВМ

cd terraform
terraform validate
terraform plan
terraform apply

=
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
Outputs:
vm1_name_external_ip = "ubuntu1: 158.160.14.119"


04. На U22
- подключаемся к U20 по ssh:
- ВМ на SH создается со встроенной учетной записью "ubuntu"
  настроена авторизация по ssh-ключу
  который должен быть расположен по пути
  ~/.ssh/id_ed25519

$ ssh -i ~/.ssh/id_ed25519 ubuntu@158.160.14.119


05. На U20
- создаем учетную запись "devops" и настравиваем авторизацию по ssh ключу

$ sudo -i
# useradd -m -G sudo -s /bin/bash devops
# passwd devops
# echo "devops  ALL=(ALL)  NOPASSWD: ALL" > /etc/sudoers.d/devops
# exit
$ ssh-keygen -t ed25519 -C "devops@acme.local"


06. На U22
- копируем public часть pivate ключа учетной записи "devops" на U20 в список разрешенных известных хостов
  для возможности авторизации по ключу
- подключаемся по ssh к U20 (подключение должно пройти сразу без запроса пароля и выходим из ssh сессии)
	
$ ssh-copy-id -i ~/.ssh/id_ed25519 devops@158.160.14.119
$ ssh devops@158.160.14.119
$ exit


07. На U22
- выполняем Ansible тест ssh ответа от U20 (ping-pong тест)
  при этом пароль запрашиваться не должен если все настроено правильно;
- применяем Ansiblе Роли "postgresql" и "docker" к U20

$ ansible --version | grep "ansible 2"
=OUTPUT:
  ansible 2.10.8


$ ansible all -m ping
=OUTPUT:
158.160.14.119 | SUCCESS => {
	"ansible_facts": {
		"discovered_interpreter_python": "/usr/bin/python3"
	},
	"changed": false,
	"ping": "pong"
}


$ ansible-playbook /etc/ansible/playbooks/postgresql.yml --syntax-check
=OUTPUT:
playbook: /etc/ansible/playbooks/postgresql.yml


$ ansible-playbook /etc/ansible/playbooks/postgresql.yml --limit "ubuntu_server_vm1"
=OUTPUT:
PLAY [app_servers] *********************************************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************************************
ok: [158.160.14.119]

TASK [postgresql : fail] ***************************************************************************************************************************
skipping: [158.160.14.119]

TASK [postgresql : Print test vars from inventory] *************************************************************************************************
ok: [158.160.14.119] => {
	"msg": [
		"INFO: PostgreSQL version to be installed..: 13",
		"INFO: PostgreSQL custom database name.....: acme_db",
		"INFO: PostgreSQL custom database user.....: acme_db_admin",
		"INFO: PostgreSQL custom database password.: pass1234"
	]
}

TASK [postgresql : Ubuntu(20) - Import the GPG signing key for the postgresql repository] **********************************************************
ok: [158.160.14.119]

TASK [postgresql : Ubuntu(20) - Add postgresql repository to local apt db] *************************************************************************
ok: [158.160.14.119]

TASK [postgresql : Ubuntu(20) - Update local packages cache before install] ************************************************************************
changed: [158.160.14.119]

TASK [postgresql : Ubuntu(20) - Install PostgreSQL 13] *********************************************************************************************
ok: [158.160.14.119]

TASK [postgresql : Ubuntu(20) - Install dependencies for Python3 PostgreSQL adapter] ***************************************************************
ok: [158.160.14.119]

TASK [postgresql : Ubuntu(20) - Install dependencies to fix permission issue for access to temp files] *********************************************
ok: [158.160.14.119]

TASK [postgresql : Ubuntu(20) - Open firewall port 5432 tcp] ***************************************************************************************
changed: [158.160.14.119]

TASK [postgresql : System - Check if PostgreSQL Service Exists] ************************************************************************************
ok: [158.160.14.119]

TASK [postgresql : PostgreSQL - Generate md5 password sequence from username and string password] **************************************************
changed: [158.160.14.119]

TASK [postgresql : PostgreSQL - Generate md5 hashed password by formula] ***************************************************************************
ok: [158.160.14.119] => {
	"msg": {
		"pg_pass_user_md5": "md5aab7c1d0e745607bbf5446bd9024144f"
	}
}

TASK [postgresql : PostgreSQL - Create custom database] ********************************************************************************************
ok: [158.160.14.119]

TASK [postgresql : PostgreSQL - Create custom database user] ***************************************************************************************
ok: [158.160.14.119]

TASK [postgresql : PostgreSQL - Allow connection for custom user to custom database using md5 authentication] **************************************
ok: [158.160.14.119]

TASK [postgresql : PostgreSQL - Allow connection for custom user to custom database using md5 authentication from Docker Container Network] ********
changed: [158.160.14.119]

TASK [postgresql : PostgreSQL - Set new configuration using config template (Jinja2)] **************************************************************
ok: [158.160.14.119]

TASK [postgresql : PostgreSQL - Set file permissions for PostgreSQL conf file (pg_ident.conf)] *****************************************************
ok: [158.160.14.119]

TASK [postgresql : PostgreSQL - Set conf param (listen_addresses)] *********************************************************************************
ok: [158.160.14.119]

TASK [postgresql : Debug - Get OS version (Debian like)] *******************************************************************************************
changed: [158.160.14.119]

TASK [postgresql : Debug - Get PostgreSQL service status] ******************************************************************************************
changed: [158.160.14.119]

TASK [postgresql : Debug - Get PostgreSQL installed version (from file)] ***************************************************************************
changed: [158.160.14.119]

TASK [postgresql : Debug - Get PostgreSQL installed version (from bin)] ****************************************************************************
changed: [158.160.14.119]

TASK [postgresql : Debug - Show PostgreSQL current database path] **********************************************************************************
ok: [158.160.14.119] => {
	"msg": [
		"INFO: PostgreSQL current database path is: /var/lib/postgresql/13/main"
	]
}

TASK [postgresql : debug] **************************************************************************************************************************
ok: [158.160.14.119] => {
	"os_version.stdout_lines": [
		"Ubuntu 20.04.5 LTS"
	]
}

TASK [postgresql : debug] **************************************************************************************************************************
ok: [158.160.14.119] => {
	"pg_service_status.stdout_lines": [
		"     Active: active (exited) since Wed 2023-03-08 17:36:10 UTC; 3min 33s ago"
	]
}

TASK [postgresql : debug] **************************************************************************************************************************
ok: [158.160.14.119] => {
	"pg_installed_version_from_file.stdout_lines": [
		"13"
	]
}

TASK [postgresql : debug] **************************************************************************************************************************
ok: [158.160.14.119] => {
	"pg_installed_version_from_bin.stdout_lines": [
		"postgres (PostgreSQL) 13.10 (Ubuntu 13.10-1.pgdg20.04+1)"
	]
}

RUNNING HANDLER [postgresql : postgresql_reloadconf] ***********************************************************************************************
changed: [158.160.14.119]

PLAY RECAP *****************************************************************************************************************************************
158.160.14.119             : ok=29   changed=9    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0


---
$ ansible-playbook /etc/ansible/playbooks/docker.yml --syntax-check
=OUTPUT:
  playbook: /etc/ansible/playbooks/docker.yml

$ ansible-playbook /etc/ansible/playbooks/docker.yml --limit "ubuntu_server_vm1"
=OUTPUT:
PLAY [app_servers] *********************************************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************************************
Enter passphrase for key '/home/devops/.ssh/id_ed25519':
ok: [158.160.14.119]

TASK [docker : Ubuntu(20) - Install aptitude] ******************************************************************************************************
changed: [158.160.14.119]

TASK [docker : Ubuntu(20) - Install required system packages] **************************************************************************************
changed: [158.160.14.119]

TASK [docker : Ubuntu(20) - Add Docker GPG apt Key] ************************************************************************************************
changed: [158.160.14.119]

TASK [docker : Ubuntu(20) - Add Docker Repository] *************************************************************************************************
changed: [158.160.14.119]

TASK [docker : Ubuntu(20) - Update apt and install docker-ce] **************************************************************************************
changed: [158.160.14.119]

TASK [docker : Ubuntu(20) - Install Docker Module for Python] **************************************************************************************
changed: [158.160.14.119]

TASK [docker : Ubuntu(20) - Add devops user to docker group] ***************************************************************************************
changed: [158.160.14.119]

TASK [docker : Ubuntu(20) - Enable and restart Docker service] *************************************************************************************
changed: [158.160.14.119]

TASK [docker : Debug - Get OS version] *************************************************************************************************************
changed: [158.160.14.119]

TASK [docker : Debug - Docker get version to stdout] ***********************************************************************************************
changed: [158.160.14.119]

TASK [docker : Debug - Docker run hello-world] *****************************************************************************************************
changed: [158.160.14.119]

TASK [docker : debug] ******************************************************************************************************************************
ok: [158.160.14.119] => {
	"os_version.stdout_lines": [
		"Ubuntu 20.04.5 LTS"
	]
}

TASK [docker : debug] ******************************************************************************************************************************
ok: [158.160.14.119] => {
	"docker_out1.stdout_lines": [
		"Docker version 23.0.1, build a5ee5b1"
	]
}

TASK [docker : debug] ******************************************************************************************************************************
ok: [158.160.14.119] => {
	"docker_out2.stdout_lines": [
		"Hello from Docker!"
	]
}

PLAY RECAP *****************************************************************************************************************************************
158.160.14.119             : ok=15   changed=11   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0


---
08. На U22 (после успешного применение Ansible ролей к U20)
- подключаемся к U20 по ssh
- проверяем работу PostgreSQL и Docker
- также проверяем созданную БД PostgreSQL "acme_db" и пользователя для работы с БД "acme_db_admin"
	
$ docker --version							##=OUTPUT: Docker version 23.0.1, build a5ee5b1
$ systemctl status docker | grep Active					##=OUTPUT: Active: active (running) since Wed 2023-03-08 17:46:03 UTC; 7min ago
$ systemctl status postgresql | grep Active				##=OUTPUT: Active: active (exited) since Wed 2023-03-08 17:36:10 UTC; 17min ago
$ sudo -u postgres psql -c "SELECT version();" | grep PostgreSQL	##=OUTPUT: PostgreSQL 13.10 (Ubuntu 13.10-1.pgdg20.04+1) on x86_64-pc-linux-gnu ..

$ sudo -u postgres psql -t -c "SELECT usename FROM pg_catalog.pg_user;"
=OUTPUT:							
postgres
acme_db_admin		## пользователь существует

$ sudo -u postgres psql -t -c "SELECT datname FROM pg_catalog.pg_database;"
=OUTPUT:
postgres
template1
template0
acme_db				## БД существует


09. На U20
	- эта часть не автоматризирована и ее нужно выполнять вручную (возможно не установлен git клиент на U20)
	- клонируем репозиторий с кодом приложения в произвольный каталог (например в ~/projects)
	- копируем каталог "app" из ~/projects в "/srv/app"
	- переходим в /srv/app и запускаем скрипт сборки Docker Образа и запуска Контейнера

$ mkdir ~/projects && cd ~/projects
$ git clone https://github.com/VictorNuzhdin/sf-pr07-terraform-ansible-docker-postgresql-python-webapp.git
$ cd sf-pr07-terraform-ansible-docker-postgresql-python-webapp
$ cp -r ~/project/app /srv/app

$ cd /srv/app
$ ./docker_build_run.sh
=OUTPUT:
=Build and Run Docker Image:
[+] Building 1.9s (11/11) FINISHED
 => [internal] load build definition from Dockerfile                                                                                 0.1s
 => => transferring dockerfile: 1.00kB                                                                                               0.0s
 => [internal] load .dockerignore                                                                                                    0.1s
 => => transferring context: 2B                                                                                                      0.0s
 => [internal] load metadata for docker.io/library/python:3.8-alpine                                                                 1.2s
 => [1/6] FROM docker.io/library/python:3.8-alpine@sha256:8518dd6657131d938f283ea97385b1db6724e35d45ddab6cd1c583796e35566a           0.0s
 => [internal] load build context                                                                                                    0.0s
 => => transferring context: 300B                                                                                                    0.0s
 => CACHED [2/6] WORKDIR /opt/app                                                                                                    0.0s
 => CACHED [3/6] COPY ./requirements.txt /opt/app/requirements.txt                                                                   0.0s
 => CACHED [4/6] RUN   apk add --no-cache postgresql-libs &&   apk add --no-cache --virtual .build-deps gcc musl-dev postgresql-dev  0.0s
 => CACHED [5/6] COPY ./web.py /opt/app/web.py                                                                                       0.0s
 => [6/6] COPY ./conf/web.conf /opt/app/conf/web.conf                                                                                0.3s
 => exporting to image                                                                                                               0.2s
 => => exporting layers                                                                                                              0.2s
 => => writing image sha256:c3d6bfcd1749acd5f9bd3f7d415920a9c7f47025afbf626041433131e0845baf                                         0.0s
 => => naming to docker.io/library/webapp                                                                                            0.0s

=Create named Docker Volume
vol-webapp

=Run Docker Container from Image
e2796b119fbf4b3e2660883a7cd2dffd84df3df58fdddbe8fad59d477402a0fe

=Check is Docker Image, Container and Volume is exists
REPOSITORY    TAG       IMAGE ID       CREATED         SIZE
webapp        latest    c3d6bfcd1749   2 seconds ago   71.6MB

CONTAINER ID   IMAGE         COMMAND           CREATED          STATUS                      PORTS                                   NAMES
e2796b119fbf   webapp        "python web.py"   1 second ago     Up Less than a second       0.0.0.0:80->5000/tcp, :::80->5000/tcp   webapp

DRIVER    VOLUME NAME
local     vol-webapp

=Docker volumes root directory content:
backingFsBlockDev  metadata.db  vol-webapp

=Docker app volume directory content:
conf  requirements.txt  web.py

---
10. С любого хоста у которого есть доступ в интернет с помощью веб-браузера проверяем
	
chrome: http://51.250.111.210
=OUTPUT:
  Hello there!
  Everything is OK! DB Query was completed by 'acme_db_admin' user.
  ---
  PostgreSQL Application start time: 2023-03-08 23:33:39.461503


11. Скриншоты на различных этапах создания проекта

11.1 Дашборд Каталога
_screens/01_dashboard.png

11.2 Сети
_screens/02_networks.png

11.3 Подсети
_screens/03_subnetworks.png

11.4 Виртуальные машины
_screens/04_instances.png

11.5 ВМ1 (основная) - Сборка и запуск Docker Образа
_screens/05_instance1_docker.png

11.6 ВМ1 (основная) - Результат работы веб-приложения в браузере на Windows хосте
_screens/06_instance1_webapp_result.png

11.7 ВМ2 (тестовая) - Сборка и запуск Docker Образа
_screens/07_instance2_docker.png

11.8 ВМ2 (тестовая) - Результат работы веб-приложения в браузере на Windows хосте
_screens/08_webapp2_result.png
