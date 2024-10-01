# Дипломный практикум в Yandex.Cloud
  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
     * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
     * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
     * [Создание тестового приложения](#создание-тестового-приложения)
     * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
     * [Установка и настройка CI/CD](#установка-и-настройка-cicd)
  * [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
  * [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Этапы выполнения:


### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
Для облачного k8s используйте региональный мастер(неотказоустойчивый). Для self-hosted k8s минимизируйте ресурсы ВМ и долю ЦПУ. В обоих вариантах используйте прерываемые ВМ для worker nodes.
- Следует использовать версию [Terraform](https://www.terraform.io/) не старше 1.5.x .

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
   а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF)
   б. Альтернативный вариант:  [Terraform Cloud](https://app.terraform.io/)  
3. Создайте VPC с подсетями в разных зонах доступности.
4. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
5. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.


## Выполнение задания:

Предварительная подготовка к установке и запуску Kubernetes кластера.


1. Создаем сервисный аккаунт, который будет использоваться Terraform для работы с инфраструктурой.

<details>
<summary>Пишем код для создания аккаунта, бэкенда и каталога для S3 bucket с помощью `terraform`, содержимое файла account.tf (в каталоге terraform_s3_network)</summary>

```
# Создаем сервисный аккаунт для Terraform
resource "yandex_iam_service_account" "service" {
  folder_id = var.FOLDER_ID
  name      = var.account_name
}

# Выдаем роль editor сервисному аккаунту Terraform
resource "yandex_resourcemanager_folder_iam_member" "service_editor" {
  folder_id = var.FOLDER_ID
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.service.id}"
}

# Создаем статический ключ доступа для сервисного аккаунта
resource "yandex_iam_service_account_static_access_key" "terraform_service_account_key" {
  service_account_id = yandex_iam_service_account.service.id
}

# Используем ключ доступа для создания бакета
resource "yandex_storage_bucket" "tf-bucket" {
  bucket     = var.bucket_name
  access_key = yandex_iam_service_account_static_access_key.terraform_service_account_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.terraform_service_account_key.secret_key

  anonymous_access_flags {
    read = false
    list = false
  }

  force_destroy = true

# Записываем ключи в файл backend.tfvars
provisioner "local-exec" {
  command = "echo export ACCESS_KEY=${yandex_iam_service_account_static_access_key.terraform_service_account_key.access_key} > ../terraform_prod/backend.tfvars"
}

provisioner "local-exec" {
  command = "echo export SECRET_KEY=${yandex_iam_service_account_static_access_key.terraform_service_account_key.secret_key} >> ../terraform_prod/backend.tfvars"
}
}
```

</details>  

2. Пробуем выполение созданного кода, проверяем работу команд `terraform apply` и `terraform destroy`.

<details>

<summary>Создание ресурсов</summary>


```
aleksander@aleksander-System-Product-Name:~/devops-diplom-yandexcloud/terraform_s3_network$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_iam_service_account.service will be created
  + resource "yandex_iam_service_account" "service" {
      + created_at = (known after apply)
      + folder_id  = (sensitive value)
      + id         = (known after apply)
      + name       = "service"
    }

  # yandex_iam_service_account_static_access_key.terraform_service_account_key will be created
  + resource "yandex_iam_service_account_static_access_key" "terraform_service_account_key" {
      + access_key           = (known after apply)
      + created_at           = (known after apply)
      + encrypted_secret_key = (known after apply)
      + id                   = (known after apply)
      + key_fingerprint      = (known after apply)
      + secret_key           = (sensitive value)
      + service_account_id   = (known after apply)
    }

  # yandex_resourcemanager_folder_iam_member.service_editor will be created
  + resource "yandex_resourcemanager_folder_iam_member" "service_editor" {
      + folder_id = (sensitive value)
      + id        = (known after apply)
      + member    = (known after apply)
      + role      = "editor"
    }

  # yandex_storage_bucket.tf-bucket will be created
  + resource "yandex_storage_bucket" "tf-bucket" {
      + access_key            = (known after apply)
      + acl                   = "private"
      + bucket                = "diplom-state"
      + bucket_domain_name    = (known after apply)
      + default_storage_class = (known after apply)
      + folder_id             = (known after apply)
      + force_destroy         = true
      + id                    = (known after apply)
      + secret_key            = (sensitive value)
      + website_domain        = (known after apply)
      + website_endpoint      = (known after apply)

      + anonymous_access_flags {
          + list = false
          + read = false
        }
    }

Plan: 4 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

yandex_iam_service_account.service: Creating...
yandex_iam_service_account.service: Creation complete after 3s [id=ajeuseefvsihcbqb6obr]
yandex_iam_service_account_static_access_key.terraform_service_account_key: Creating...
yandex_resourcemanager_folder_iam_member.service_editor: Creating...
yandex_iam_service_account_static_access_key.terraform_service_account_key: Creation complete after 1s [id=aje7gk08pprkqtnaveuj]
yandex_storage_bucket.tf-bucket: Creating...
yandex_resourcemanager_folder_iam_member.service_editor: Creation complete after 2s [id=b1g7kr9i41eoi2fqj52o/editor/serviceAccount:ajeuseefvsihcbqb6obr]
yandex_storage_bucket.tf-bucket: Provisioning with 'local-exec'...
yandex_storage_bucket.tf-bucket (local-exec): Executing: ["/bin/sh" "-c" "echo export ACCESS_KEY=YCAJEA-j1KGvx5dQmA71PZLZb > ../terraform_prod/backend.tfvars"]
yandex_storage_bucket.tf-bucket: Provisioning with 'local-exec'...
yandex_storage_bucket.tf-bucket (local-exec): (output suppressed due to sensitive value in config)
yandex_storage_bucket.tf-bucket: Creation complete after 4s [id=diplom-state]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
```

Проверяем создание ресурсов в консоли ЯО:

аккаунт `service` создан:
<p align="center">
  <img width="1200" height="600" src="./image/account.png">
</p>

бакет `diplom-state` создан:
<p align="center">
  <img width="1200" height="600" src="./image/backet.png">
</p>

</details>

<details>

<summary>Удаление ресурсов</summary>

```
aleksander@aleksander-System-Product-Name:~/devops-diplom-yandexcloud/terraform_s3_network$ terraform destroy
yandex_iam_service_account.service: Refreshing state... [id=ajeuseefvsihcbqb6obr]
yandex_resourcemanager_folder_iam_member.service_editor: Refreshing state... [id=b1g7kr9i41eoi2fqj52o/editor/serviceAccount:ajeuseefvsihcbqb6obr]
yandex_iam_service_account_static_access_key.terraform_service_account_key: Refreshing state... [id=aje7gk08pprkqtnaveuj]
yandex_storage_bucket.tf-bucket: Refreshing state... [id=diplom-state]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # yandex_iam_service_account.service will be destroyed
  - resource "yandex_iam_service_account" "service" {
      - created_at = "2024-09-30T08:03:58Z" -> null
      - folder_id  = (sensitive value) -> null
      - id         = "ajeuseefvsihcbqb6obr" -> null
      - name       = "service" -> null
    }

  # yandex_iam_service_account_static_access_key.terraform_service_account_key will be destroyed
  - resource "yandex_iam_service_account_static_access_key" "terraform_service_account_key" {
      - access_key         = "YCAJEA-j1KGvx5dQmA71PZLZb" -> null
      - created_at         = "2024-09-30T08:04:01Z" -> null
      - id                 = "aje7gk08pprkqtnaveuj" -> null
      - secret_key         = (sensitive value) -> null
      - service_account_id = "ajeuseefvsihcbqb6obr" -> null
    }

  # yandex_resourcemanager_folder_iam_member.service_editor will be destroyed
  - resource "yandex_resourcemanager_folder_iam_member" "service_editor" {
      - folder_id = (sensitive value) -> null
      - id        = "b1g7kr9i41eoi2fqj52o/editor/serviceAccount:ajeuseefvsihcbqb6obr" -> null
      - member    = "serviceAccount:ajeuseefvsihcbqb6obr" -> null
      - role      = "editor" -> null
    }

  # yandex_storage_bucket.tf-bucket will be destroyed
  - resource "yandex_storage_bucket" "tf-bucket" {
      - access_key            = "YCAJEA-j1KGvx5dQmA71PZLZb" -> null
      - acl                   = "private" -> null
      - bucket                = "diplom-state" -> null
      - bucket_domain_name    = "diplom-state.storage.yandexcloud.net" -> null
      - default_storage_class = "STANDARD" -> null
      - folder_id             = "b1g7kr9i41eoi2fqj52o" -> null
      - force_destroy         = true -> null
      - id                    = "diplom-state" -> null
      - max_size              = 0 -> null
      - secret_key            = (sensitive value) -> null

      - anonymous_access_flags {
          - list = false -> null
          - read = false -> null
        }

      - versioning {
          - enabled = false -> null
        }
    }

Plan: 0 to add, 0 to change, 4 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

yandex_resourcemanager_folder_iam_member.service_editor: Destroying... [id=b1g7kr9i41eoi2fqj52o/editor/serviceAccount:ajeuseefvsihcbqb6obr]
yandex_storage_bucket.tf-bucket: Destroying... [id=diplom-state]
yandex_resourcemanager_folder_iam_member.service_editor: Destruction complete after 3s
yandex_storage_bucket.tf-bucket: Still destroying... [id=diplom-state, 10s elapsed]
yandex_storage_bucket.tf-bucket: Destruction complete after 11s
yandex_iam_service_account_static_access_key.terraform_service_account_key: Destroying... [id=aje7gk08pprkqtnaveuj]
yandex_iam_service_account_static_access_key.terraform_service_account_key: Destruction complete after 1s
yandex_iam_service_account.service: Destroying... [id=ajeuseefvsihcbqb6obr]
yandex_iam_service_account.service: Destruction complete after 3s

Destroy complete! Resources: 4 destroyed.
```

</details>


 
---
### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать **региональный** мастер kubernetes с размещением нод в разных 3 подсетях      
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
  
Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.


1. Создаем VPC с подсетями в разных зонах доступности.

<details>

<summary>Пишем код для создания VPC с подсетями с помощью `terraform`, содержимое файла networks.tf (в каталоге terraform_prod)</summary>

```
# networks
resource "yandex_vpc_network" "net" {
  name = "net"
}

resource "yandex_vpc_subnet" "subnet-a" {
  name           = "subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = ["10.10.10.0/24"]
}

resource "yandex_vpc_subnet" "subnet-b" {
  name           = "subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = ["10.10.20.0/24"]
}
```

</details> 

2. При помощи Terraform подготовим 3 виртуальных машины Compute Cloud на которых затем будем разворачивать Kubernetes-кластер.


<details>

<summary>Код Terraform для создания виртуальных машин, записанный в файле main.tf (в каталоге terraform_prod):</summary>

Для подключения к создаваемым виртуальным машинам с нашей локальной машины предварительно создаем на нашей локальной машине ключ достура с помощью команды `ssh-keygen -t ed25519`, затем с помощью Terraform этот код записывается в соответствующие переменные.

```
locals {
  ssh-keys = fileexists("~/.ssh/id_ed25519.pub") ? file("~/.ssh/id_ed25519.pub") : var.ssh_public_key
  ssh-private-keys = fileexists("~/.ssh/id_ed25519") ? file("~/.ssh/id_ed25519") : var.ssh_private_key
}

data "template_file" "meta" {
 template = file("${path.module}/meta.yml")
 vars = {
   ssh_public_key = local.ssh-keys
   ssh_private_key = local.ssh-private-keys
 }
}


# instances
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

resource "yandex_compute_instance" "control" {
  name = "control"
  zone = "ru-central1-a"
  hostname = "control"
  allow_stopping_for_update = true

  resources {
    core_fraction = var.core_fraction
    cores = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size = 20
      type = var.disk_type
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-a.id
    ip_address = "10.10.10.10"
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh-keys}"
    serial-port-enable = "1"
    user-data          = data.template_file.meta.rendered
  }

  scheduling_policy {
    preemptible = var.preemptible
  }
}

resource "yandex_compute_instance" "node1" {
  name = "node1"
  zone = "ru-central1-b"
  hostname = "node1"
  allow_stopping_for_update = true

  resources {
    core_fraction = var.core_fraction
    cores = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size = 20
      type = var.disk_type
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-b.id
    ip_address = "10.10.20.11"
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh-keys}"
    serial-port-enable = "1"
    user-data          = data.template_file.meta.rendered
  }

```

</details>

3. Для разворачивания Kubernetes-кластера скачиваем на свою локальную машину [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)

<details>

<summary>Подготавливаем файл ansible.tf для установки Kubernetes-кластера, (в каталоге terraform_prod):</summary> 

В результате в файл hosts.yaml записываются ip адреса созданных виртуальных машин и далее выполняется плейбук из состава библиотеки Kubespray: 

```
resource "local_file" "ansible_inventory" { 
  content = templatefile("${path.module}/hosts.tftpl", {
    control_ext_ip = yandex_compute_instance.control.network_interface.0.nat_ip_address
    control_int_ip = yandex_compute_instance.control.network_interface.0.ip_address
    node1_ext_ip   = yandex_compute_instance.node1.network_interface.0.nat_ip_address
    node1_int_ip   = yandex_compute_instance.node1.network_interface.0.ip_address
    node2_ext_ip   = yandex_compute_instance.node2.network_interface.0.nat_ip_address
    node2_int_ip   = yandex_compute_instance.node2.network_interface.0.ip_address   
  })
  filename = "../kubespray/inventory/k8s_cluster/hosts.yaml"
}

resource "null_resource" "show_env" {
  depends_on = [
    local_file.ansible_inventory
  ]

  provisioner "local-exec" {
    command = "echo -e \"\\n========================= HOSTS.YAML START =========================\\n\" && cat ../kubespray/inventory/k8s_cluster/hosts.yaml && echo -e \"\\n========================== HOSTS.YAML END ==========================\\n\""
  }
}


resource "null_resource" "wait_for_port_22_control" {
  depends_on = [
    local_file.ansible_inventory
  ]

  provisioner "local-exec" {
    command = "while ! nc -z ${yandex_compute_instance.control.network_interface.0.nat_ip_address}   22; do sleep   5; done"
  }
}

resource "null_resource" "wait_for_port_22_node1" {
  depends_on = [
    local_file.ansible_inventory
  ]

  provisioner "local-exec" {
    command = "while ! nc -z ${yandex_compute_instance.node1.network_interface.0.nat_ip_address}   22; do sleep   5; done"
  }
}

resource "null_resource" "wait_for_port_22_node2" {
  depends_on = [
    local_file.ansible_inventory
  ]

  provisioner "local-exec" {
    command = "while ! nc -z ${yandex_compute_instance.node2.network_interface.0.nat_ip_address}   22; do sleep   5; done"
  }
}

resource "null_resource" "ansible_provisioner" {
  depends_on = [
    local_file.ansible_inventory,
    null_resource.wait_for_port_22_control,
    null_resource.wait_for_port_22_node1,
    null_resource.wait_for_port_22_node2
  ]

  provisioner "local-exec" {
    command = "cd ../kubespray && ansible-playbook -i inventory/k8s_cluster/hosts.yaml cluster.yml -b --become-user=root"
  }
}
```

</details>


<details>

4. Перед выполнением кода для создания виртуальных машин и должен быть выполнен код из каталога terraform_s3_network создания аккаунта, бэкенда и каталога для S3 bucket 

После выполения вышеобозначенного кода в файле backend.tfvars создаются ключи ACCESS_KEY и SECRET_KEY, выполняем инициализию бэкенд с помощью кода terraform init -backend-config="access_key=<your access key>" -backend-config="secret_key=<your secret key>"

</details>

<summary>Выполняем `terraform apply`, в результате создаются ВМ и с помощью ansible (файл ansible.tf) разворачивается Kubernetes-кластер на созданных ВМ</summary> 

Результат выполнения кода terraform и плейбука ansible:

<p align="center">
  <img width="1200" height="600" src="./image/kubernetes.png">
</p>

сеть и подсети `net` созданы:
<p align="center">
  <img width="1200" height="600" src="./image/net.png">
</p>
<p align="center">
  <img width="1200" height="600" src="./image/subnet.png">
</p>

</details>


После выполнения кода (создания ВМ и Kubernetes-кластера) на управляющей ноде создаем директорию для хранения файла конфигурации, копируем созданный при установке Kubernetes кластера конфигурационный файл в эту директорию, и назначаем права для пользователя на директорию и файл конфигурации :

```
aleksander@aleksander-System-Product-Name:~/devops-diplom-yandexcloud/terraform_prod$ ssh ubuntu@62.84.116.137
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.4.0-196-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro
New release '22.04.5 LTS' available.
Run 'do-release-upgrade' to upgrade to it.

Last login: Mon Sep 30 09:19:07 2024 from 89.109.5.129
ubuntu@control:~$ mkdir ~/.kube
ubuntu@control:~$ sudo cp /etc/kubernetes/admin.conf ~/.kube/config
ubuntu@control:~$ sudo chown -R ubuntu:ubuntu $HOME/.kube/config
ubuntu@control:~$ ll ~/.kube
total 16
drwxrwxr-x 2 ubuntu ubuntu 4096 Oct  1 07:37 ./
drwxr-xr-x 6 ubuntu ubuntu 4096 Oct  1 07:37 ../
-rw------- 1 ubuntu ubuntu 5665 Oct  1 07:37 config
```

Проверяем доступность подов и нод кластера:

```
ubuntu@control:~$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                      READY   STATUS    RESTARTS      AGE
kube-system   calico-kube-controllers-648dffd99-w74bq   1/1     Running   0             22h
kube-system   calico-node-9kd5c                         1/1     Running   0             22h
kube-system   calico-node-fdjf9                         1/1     Running   0             22h
kube-system   calico-node-njz9f                         1/1     Running   0             22h
kube-system   coredns-69db55dd76-bf27j                  1/1     Running   0             22h
kube-system   coredns-69db55dd76-dfchp                  1/1     Running   0             22h
kube-system   dns-autoscaler-6f4b597d8c-nfxg2           1/1     Running   0             22h
kube-system   kube-apiserver-control                    1/1     Running   1             22h
kube-system   kube-controller-manager-control           1/1     Running   2             22h
kube-system   kube-proxy-jlbz5                          1/1     Running   0             22h
kube-system   kube-proxy-mlwht                          1/1     Running   0             22h
kube-system   kube-proxy-wm6j5                          1/1     Running   0             22h
kube-system   kube-scheduler-control                    1/1     Running   2 (22h ago)   22h
kube-system   nginx-proxy-node1                         1/1     Running   0             22h
kube-system   nginx-proxy-node2                         1/1     Running   0             22h
kube-system   nodelocaldns-6v9t5                        1/1     Running   0             22h
kube-system   nodelocaldns-hj6pt                        1/1     Running   0             22h
kube-system   nodelocaldns-zlxff                        1/1     Running   0             22h
ubuntu@control:~$ kubectl get nodes
NAME      STATUS   ROLES           AGE   VERSION
control   Ready    control-plane   22h   v1.29.1
node1     Ready    <none>          22h   v1.29.1
node2     Ready    <none>          22h   v1.29.1
```

ubuntu@control:~$ mkdir ~/.kube
ubuntu@control:~$ ls
mydir
ubuntu@control:~$ sudo cp /etc/kubernetes/admin.conf ~/.kube/config
ubuntu@control:~$ sudo chown -R ubuntu:ubuntu $HOME/.kube/config
ubuntu@control:~$ ll ~/.kube
total 16
drwxrwxr-x 2 ubuntu ubuntu 4096 Sep 24 12:32 ./
drwxr-xr-x 7 ubuntu ubuntu 4096 Sep 24 12:31 ../
-rw------- 1 ubuntu ubuntu 5661 Sep 24 12:32 config
ubuntu@control:~$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                      READY   STATUS    RESTARTS       AGE
kube-system   calico-kube-controllers-648dffd99-j84gw   1/1     Running   0              9m27s
kube-system   calico-node-gtxpx                         1/1     Running   0              22m
kube-system   calico-node-jccxk                         1/1     Running   0              22m
kube-system   calico-node-zg69q                         1/1     Running   0              22m
kube-system   coredns-69db55dd76-2j6hp                  1/1     Running   0              9m7s
kube-system   coredns-69db55dd76-tvfqn                  1/1     Running   0              8m37s
kube-system   dns-autoscaler-6f4b597d8c-jrf9k           1/1     Running   0              9m2s
kube-system   kube-apiserver-control                    1/1     Running   1              24m
kube-system   kube-controller-manager-control           1/1     Running   3 (8m6s ago)   24m
kube-system   kube-proxy-2jw4x                          1/1     Running   0              10m
kube-system   kube-proxy-8sjfl                          1/1     Running   0              10m
kube-system   kube-proxy-h98jj                          1/1     Running   0              10m
kube-system   kube-scheduler-control                    1/1     Running   2 (8m7s ago)   24m
kube-system   nginx-proxy-node1                         1/1     Running   0              23m
kube-system   nginx-proxy-node2                         1/1     Running   0              23m
kube-system   nodelocaldns-4lf8l                        1/1     Running   0              9m1s
kube-system   nodelocaldns-6nq8d                        1/1     Running   0              9m1s
kube-system   nodelocaldns-sjlqg                        1/1     Running   0              9m1s
ubuntu@control:~$ 

---
### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.  
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.
2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.

---
### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Способ выполнения:
1. Воспользовать пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). При желании можете собрать все эти приложения отдельно.
2. Для организации конфигурации использовать [qbec](https://qbec.io/), основанный на [jsonnet](https://jsonnet.org/). Обратите внимание на имеющиеся функции для интеграции helm конфигов и [helm charts](https://helm.sh/)
3. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ к тестовому приложению.

---
### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.

---
## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)

