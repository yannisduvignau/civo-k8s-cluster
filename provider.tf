# This file configures the Terraform providers required for this project.
# It specifies the required versions for each provider and sets up the
# authentication details for Civo, Cloudflare, Helm, Kubernetes, and Kubectl.

terraform {
  required_version = ">= 0.13.0"

  required_providers {
    civo = {
      source  = "civo/civo"
      version = "~> 1.1.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.37.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# Variable for the Civo API token.
variable "civo_token" {
  type        = string
}

# Variable for the Cloudflare account email.
variable "cloudflare_email" {
  type        = string
}

# Variable for the Cloudflare API key.
variable "cloudflare_api_key" {
  type        = string
}

# Configures the Civo provider with the API token and region.
provider "civo" {
  token  = var.civo_token
  region = "FRA1"
}

# Configures the Helm provider to connect to the Civo Kubernetes cluster.
# It uses the kubeconfig from the created Civo cluster resource.
provider "helm" {
  kubernetes = {
    config_path            = "~/.kube/config"
    host                   = "${yamldecode(civo_kubernetes_cluster.k8s_1.kubeconfig).clusters.0.cluster.server}"
    client_certificate     = "${base64decode(yamldecode(civo_kubernetes_cluster.k8s_1.kubeconfig).users.0.user.client-certificate-data)}"
    client_key             = "${base64decode(yamldecode(civo_kubernetes_cluster.k8s_1.kubeconfig).users.0.user.client-key-data)}"
    cluster_ca_certificate = "${base64decode(yamldecode(civo_kubernetes_cluster.k8s_1.kubeconfig).clusters.0.cluster.certificate-authority-data)}"
  }
}

# Configures the Kubernetes provider to connect to the Civo Kubernetes cluster.
provider "kubernetes" {
  host                   = yamldecode(civo_kubernetes_cluster.k8s_1.kubeconfig).clusters.0.cluster.server
  client_certificate     = base64decode(yamldecode(civo_kubernetes_cluster.k8s_1.kubeconfig).users.0.user.client-certificate-data)
  client_key             = base64decode(yamldecode(civo_kubernetes_cluster.k8s_1.kubeconfig).users.0.user.client-key-data)
  cluster_ca_certificate = base64decode(yamldecode(civo_kubernetes_cluster.k8s_1.kubeconfig).clusters.0.cluster.certificate-authority-data)
}

# Configures the Kubectl provider for managing Kubernetes resources via manifests.
provider "kubectl" {
  host                   = yamldecode(civo_kubernetes_cluster.k8s_1.kubeconfig).clusters.0.cluster.server
  client_certificate     = base64decode(yamldecode(civo_kubernetes_cluster.k8s_1.kubeconfig).users.0.user.client-certificate-data)
  client_key             = base64decode(yamldecode(civo_kubernetes_cluster.k8s_1.kubeconfig).users.0.user.client-key-data)
  cluster_ca_certificate = base64decode(yamldecode(civo_kubernetes_cluster.k8s_1.kubeconfig).clusters.0.cluster.certificate-authority-data)
  load_config_file       = false
}

# Configures the Cloudflare provider with the account email and API key.
provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}