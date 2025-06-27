##  Infrastructure Setup (Terraform on GCP)

Author: MSc. Daniel Oswaldo Sierra Garcia
Date: 26 June 2025
Desc:  **couchsurfing‑infra** in Google Cloud with Terraform + GitHub Actions (We need to implement later the CI/CD).


### 1 · Pre requisits

```bash
# Recarga tu perfil (si usas brew en macOS)
source ~/.bash-profile

# Instala Terraform 1.12+
brew install terraform
terraform -v   # => v1.12.2 o superior

# Instala Git
brew install git
```

### 2 · GCP Project Config

```bash
export PROJECT_ID=couchsurfing-1

gcloud init                      # login + region/zone

gcloud projects create $PROJECT_ID

# Habilita APIs básicas
gcloud services enable \
  compute.googleapis.com \
  sqladmin.googleapis.com \
  servicenetworking.googleapis.com \
  iam.googleapis.com \
  cloudresourcemanager.googleapis.com \
  --project=$PROJECT_ID
```

### 3 · Service Account we can automated this on other resources or create a Ansible deploymement

```bash
gcloud iam service-accounts create tf-automation \
  --project=$PROJECT_ID \
  --description="Pipelines Account for Terraform" \
  --display-name="Terraform Automation Couchsurfing"

# Clave JSON (guárdala como **sa.json** y añade a GitHub Secrets)
gcloud iam service-accounts keys create sa.json \
  --iam-account tf-automation@$PROJECT_ID.iam.gserviceaccount.com

# Permisos mínimos
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:tf-automation@$PROJECT_ID.iam.gserviceaccount.com" \
  --role=roles/storage.admin

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:tf-automation@$PROJECT_ID.iam.gserviceaccount.com" \
  --role=roles/compute.admin

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:tf-automation@$PROJECT_ID.iam.gserviceaccount.com" \
  --role=roles/iam.serviceAccountUser

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:tf-automation@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/cloudsql.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:tf-automation@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/servicenetworking.networksAdmin"
```

### 4 · Remote Bucket to manage the state. 

```bash
gsutil mb -p $PROJECT_ID gs://tfstate-couchsurfing-1
gsutil versioning set on gs://tfstate-couchsurfing-1
```

### 5 · Git Branch

```bash
git checkout -b dev    && git push -u origin dev
git checkout -b preprod && git push -u origin preprod
git checkout -b prod   && git push -u origin prod
```

We can add secretes on **GitHub → Settings → Secrets and variables → Actions**: 

| Name              | Value                    |
| ----------------- | ------------------------ |
| `GCP_SA_KEY`      | contenido de **sa.json** |
| `TF_STATE_BUCKET` | `tfstate-couchsurfing-1` |


### 6 · Init Terraform and workspaces

```bash
export PROJECT_ENV=dev
terraform init \
  -backend-config="bucket=tfstate-$PROJECT_ID" \
  -backend-config="prefix=state/$PROJECT_ENV"

# Crear workspaces (una vez)
terraform workspace new dev
terraform workspace new preprod
terraform workspace new prod
```

### 7 · Plan & Apply for Environment 

```bash
terraform workspace select $PROJECT_ENV
terraform plan   -var-file=$PROJECT_ENV.tfvars
terraform apply  -var-file=$PROJECT_ENV.tfvars
```


Base Infra (VPC, VM, Cloud SQL, etc.),  we need to implement de CICD for this project 

