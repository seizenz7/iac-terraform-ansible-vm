# IaC Terraform + Ansible VM Provisioning

## Overview
Proyek ini mengotomatisasi provisioning VM Ubuntu di AWS menggunakan **Terraform** (Infrastructure as Code) dan konfigurasi Docker + deployment Flask app menggunakan **Ansible**. 
Tujuan: Mensimulasikan pembuatan infrastruktur yang reproducible dan version-controlled hanya dengan kode perintah.

## Tech Stack
- **Terraform** v1.10+ (AWS Provider)
- **Ansible** (playbook Docker + container)
- **AWS** (EC2 t2.micro, Security Group, VPC) – via KodeKloud Playground
- **Docker** + Flask app (reuse image dari [Project 1](https://github.com/seizenz7/devops-flask-ci-cd-kubernetes))
- **KodeKloud AWS Playground** (Business Plan)

## Flowchart Diagram
```mermaid
flowchart LR
    A[Terraform] --> B[Provision EC2 Ubuntu]
    B --> C[Ansible Playbook]
    C --> D[Install Docker]
    D --> E[Pull & Run Flask Container]
    E --> F[App Running di Public IP]
```

## Prerequisites
- WSL2 terinstall dan aktif
- Akun KodeKloud Business Plan (untuk AWS)
- Terraform CLI terinstal di WSL2/Windows
- Ansible terinstal di WSL2
- GitHub repo 

---
## Milestone 1: Provision EC2 via Terraform

### Steps 1 - Launch KodeKloud AWS Playground & Ambil Credentials
- Buka browser dan login ke KodeKloud
- Launch AWS Playground
- Ambil kredensial AWS melalui cloudshell aws
  
  Verifikasi siapa yang login `aws sts get-caller-identity`
  
  Ambil temporary credentials`curl -s -H "Authorization: $AWS_CONTAINER_AUTHORIZATION_TOKEN" "$AWS_CONTAINER_CREDENTIALS_FULL_URI" | jq .`
  
- Simpan di notepad

### Steps 2 - Siapkan Terraform & Konfigurasi Provider AWS dengan Temporary Credentials
- Buat repo di github (iac-terraform-ansible-vm) dan clone repo `git clone ....`
- Masuk ke folder repo dan Buat folder terraform `mkdir terraform`
- Masuk ke folder terraform `cd terraform`
- Export kredensial temporary AWS ke env WSL

  `export AWS_ACCESS_KEY_ID=""`

  `export AWS_SECRET_ACCESS_KEY=""`

  `export AWS_SESSION_TOKEN=""`

  `export AWS_REGION=""`

- Buat file [provider.tf](terraform/provider.tf)
- Buat file [variables.tf](terraform/variables.tf)
- Buat file [main.tf](terraform/main.tf)
- Jalankan perintah terraform

  `terraform init`
  
  `terraform validate`
  
  `terraform plan`
  
  `terraform apply -auto-approve`

### Screenshots (Terraform)

- AWS Cloudshell
  
  ![kodekloud-playground-launch.png](https://github.com/seizenz7/iac-terraform-ansible-vm/blob/main/screenshots/kodekloud-playground-launch.png)
  
- Terraform init dan validate
  
  ![terraform-files-init-validate.png](https://github.com/seizenz7/iac-terraform-ansible-vm/blob/main/screenshots/terraform-files-init-validate.png)

- Terraform plan

  ![terraform-plan-1.png](https://github.com/seizenz7/iac-terraform-ansible-vm/blob/main/screenshots/terraform-plan-1.png)
  ![terraform-plan-2.png](https://github.com/seizenz7/iac-terraform-ansible-vm/blob/main/screenshots/terraform-plan-2.png)
  ![terraform-plan-3.png](https://github.com/seizenz7/iac-terraform-ansible-vm/blob/main/screenshots/terraform-plan-3.png)
  ![terraform-plan-4.png](https://github.com/seizenz7/iac-terraform-ansible-vm/blob/main/screenshots/terraform-plan-4.png)

- Terraform apply

  ![terraform-apply-1.png](https://github.com/seizenz7/iac-terraform-ansible-vm/blob/main/screenshots/terraform-apply-1.png)
  ![terraform-apply-2.png](https://github.com/seizenz7/iac-terraform-ansible-vm/blob/main/screenshots/terraform-apply-2.png)
  ![terraform-apply-3.png](https://github.com/seizenz7/iac-terraform-ansible-vm/blob/main/screenshots/terraform-apply-3.png)
  ![terraform-apply-4.png](https://github.com/seizenz7/iac-terraform-ansible-vm/blob/main/screenshots/terraform-apply-4.png)

- IP

  ![publik_ip.png](https://github.com/seizenz7/iac-terraform-ansible-vm/blob/main/screenshots/publik_ip.png)

- Hasil instance vm AWS EC2

  ![AWS-EC2-Instance-devops-flask-vm.png](https://github.com/seizenz7/iac-terraform-ansible-vm/blob/main/screenshots/AWS-EC2-Instance-devops-flask-vm.png)

- Koneksi SSH berhasil masuk ke instance vm AWS EC2

  ![ssh-success.png](https://github.com/seizenz7/iac-terraform-ansible-vm/blob/main/screenshots/ssh-success.png)
  
### Challenges & Learnings

- Challenge: Membuat dynamic AMI lookup
- Learning:
    - Mengambil kredensial dengan AWS Cloudshell
    - Membuat kode iac terraform untuk menyiapkan instance vm di AWS EC2 secara otomatis
    - Membuat perintah untuk otomatis generate ssh key dan menyimpan private key di lokal untuk kemudahan akses ssh ke instance EC2
    - Menerapkan minimal security group
    - Menggunakan data source untuk lookup AMI terbaru secara dinamis

---

## Milestone 2: Ansible Configuration & Docker Setup

### Steps 1 - Setup Ansible Inventory & Playbook Dasar
- Buat folder ansible di dalam root project repo dan masuk ke dalam folder `mkdir ansible && cd ansible`
- Buat file [inventory.ini](ansible/inventory.ini)
- Buat file [playbook.yml](ansible/playbook.yml)
- Jalankan perintah ansible

  `ansible all -i inventory.ini -m ping` untuk test koneksi ssh ke server vm

  `ansible-playbook -i inventory.ini playbook.yml --syntax-check` untuk cek syntax code apakah sudah aman/tidak ada error

  `ansible-playbook -i inventory.ini playbook.yml` untuk menjalankan code ansible playbook

- Jika sudah sukses menjalankan ansible playbook tanpa error, masuk ke instance vm dan cek apakah docker berhasil terinstall dan berjalan
  
  `which docker`

  `docker version`

  `systemctl status docker`

### Screenshots (Ansible)

- Cek koneksi ssh & cek syntax
  
  ![ansible-playbook-check.png](https://github.com/seizenz7/iac-terraform-ansible-vm/blob/main/screenshots/ansible-playbook-check.png)

- Ansible playbook run & success

  ![ansible-playbook-success.png](https://github.com/seizenz7/iac-terraform-ansible-vm/blob/main/screenshots/ansible-playbook-success.png)

- Verifikasi Docker installed & running

  ![docker-verify.png](https://github.com/seizenz7/iac-terraform-ansible-vm/blob/main/screenshots/docker-verify.png)
  

### Challenges & Learnings

- Challenge: Ansible-lint violation (FQCN, truthy value, trailing spaces, line-length) saat menggunakan yes/no dan short module name.
- Learning: Menggunakan ansible.builtin.* (FQCN) dan true/false membuat kode lebih clean, future-proof, dan sesuai best practice perusahaan.

---

## Milestone 3: Deploy Flask Application

### Steps
- Tambahkan task Flask di [playbook.yml](ansible/playbook.yml) (pull image + run container)
- Jalankan playbook sekali lagi `ansible-playbook -i inventory.ini playbook.yml`
- Buka browser → http://<public-ip-ec2> (Flask app berjalan di port 80)

### Screenshots 

- Ansible playbook run & success (deploy flask app)
  
  ![ansible-playbook-deploy-success.png](https://github.com/seizenz7/iac-terraform-ansible-vm/blob/main/screenshots/ansible-playbook-deploy-success.png)

  ![ansible-playbook-deploy-success-2.png](https://github.com/seizenz7/iac-terraform-ansible-vm/blob/main/screenshots/ansible-playbook-deploy-success-2.png)

- Open http://<public-ip-ec2> in browser (Muncul tampilan flask app)

  ![flask-app-browser.png](https://github.com/seizenz7/iac-terraform-ansible-vm/blob/main/screenshots/flask-app-browser.png)

- Docker container flask app running

   ![docker-container-flask-app.png](https://github.com/seizenz7/iac-terraform-ansible-vm/blob/main/screenshots/docker-container-flask-app.png)
  

### Challenges & Learnings

- Challenge: Image Flask harus sudah ada di Docker Hub (dari Project 1).
- Learning:
    - Ansible bisa langsung pull & run container dari Docker Hub dengan module `community.docker.docker_container`.
    - Expose port 80:5000 sudah cukup untuk demo tanpa Nginx (untuk production baru ditambah reverse proxy).

---

---
## ***Key Takeaway Keseluruhan Project 2***
Dalam Proyek ini saya berhasil membangun **end-to-end Infrastructure as Code pipeline** yang lengkap dan modern. Dengan menggabungkan **Terraform** untuk provisioning infrastruktur (EC2 Ubuntu) dan **Ansible** untuk konfigurasi serta deployment aplikasi (Docker + Flask container), seluruh proses menjadi 100% deklaratif, idempotent, dan reproducible. Hasilnya adalah infrastruktur yang siap pakai, mudah direproduksi, dan scalable
