# This file defines the Civo cloud infrastructure, including the Kubernetes cluster,
# firewall rules, and data sources for node sizes and load balancers.

# Data source to get the details of the "xsmall" instance size.
# This is used to specify the node size in the Kubernetes cluster pool.
data "civo_size" "xsmall" {
  filter {
    key      = "name"
    values   = ["g4s.kube.xsmall"]
    match_by = "re"
  }
}

# Creates a Kubernetes cluster on Civo.
# The cluster is named "k8s_1", has no default applications installed,
# and is associated with the firewall "fw_1".
resource "civo_kubernetes_cluster" "k8s_1" {
  name         = "k8s_1"
  applications = ""
  firewall_id  = civo_firewall.fw_1.id

  # Defines the node pool for the cluster.
  # It uses the "xsmall" size and starts with 2 nodes.
  pools {
    size       = element(data.civo_size.xsmall.sizes, 0).name
    node_count = 2
  }
}

# Creates a firewall named "fw_1" for the Kubernetes cluster.
# Default rules are disabled to allow for a custom ruleset.
resource "civo_firewall" "fw_1" {
  name                 = "fw_1"
  create_default_rules = false

  # Ingress rule to allow HTTP traffic on port 80 from any source.
  ingress_rule {
    protocol   = "tcp"
    port_range = "80"
    cidr       = ["0.0.0.0/0"]
    label      = "kubernetes_http"
    action     = "allow"
  }

  # Ingress rule to allow HTTPS traffic on port 443 from any source.
  ingress_rule {
    protocol   = "tcp"
    port_range = "443"
    cidr       = ["0.0.0.0/0"]
    label      = "kubernetes_https"
    action     = "allow"
  }

  # Ingress rule to allow access to the Kubernetes API server on port 6443.
  ingress_rule {
    protocol   = "tcp"
    port_range = "6443"
    cidr       = ["0.0.0.0/0"]
    label      = "kubernetes_api"
    action     = "allow"
  }
}

# Pauses execution for 20 seconds to ensure the Kubernetes cluster is fully
# provisioned and ready before other resources are created.
resource "time_sleep" "wait_for_kubernetes" {

    depends_on = [
        civo_kubernetes_cluster.k8s_1
    ]

    create_duration = "20s"
}

# Data source to retrieve information about the Traefik load balancer.
# This is used to get the public IP address for DNS configuration.
data "civo_loadbalancer" "traefik_lb" {

    depends_on = [
        helm_release.traefik
    ]

    name = "k8s_1-traefik-traefik"
}