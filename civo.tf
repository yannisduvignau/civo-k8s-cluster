# Kubernetes Cluster

data "civo_size" "xsmall" {
  filter {
    key      = "name"
    values   = ["g4s.kube.xsmall"]
    match_by = "re"
  }
}

resource "civo_kubernetes_cluster" "k8s_1" {
  name         = "k8s_1"
  applications = ""
  firewall_id  = civo_firewall.fw_1.id

  pools {
    size       = element(data.civo_size.xsmall.sizes, 0).name
    node_count = 2
  }
}

resource "civo_firewall" "fw_1" {
  name                 = "fw_1"
  create_default_rules = false

  // Rule for HTTP
  ingress_rule {
    protocol   = "tcp"
    port_range = "80"
    cidr       = ["0.0.0.0/0"]
    label      = "kubernetes_http"
    action     = "allow"
  }

  // Rule for HTTPS
  ingress_rule {
    protocol   = "tcp"
    port_range = "443"
    cidr       = ["0.0.0.0/0"]
    label      = "kubernetes_https"
    action     = "allow"
  }

  // Rule for Kubernetes API Server
  ingress_rule {
    protocol   = "tcp"
    port_range = "6443"
    cidr       = ["0.0.0.0/0"]
    label      = "kubernetes_api"
    action     = "allow"
  }
}

resource "time_sleep" "wait_for_kubernetes" {

    depends_on = [
        civo_kubernetes_cluster.k8s_1
    ]

    create_duration = "20s"
}

data "civo_loadbalancer" "traefik_lb" {

    depends_on = [
        helm_release.traefik
    ]

    name = "k8s_1-traefik-traefik"
}