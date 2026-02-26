# This file configures the Traefik Ingress Controller in the Kubernetes cluster.
# It creates a dedicated namespace and installs Traefik using its official Helm chart.
# Key configurations include setting Traefik as the default ingress class,
# redirecting HTTP to HTTPS, and enabling TLS on the secure entry point.

# Creates the "traefik" namespace for all Traefik-related resources.
resource "kubernetes_namespace" "traefik" {

    depends_on = [
        time_sleep.wait_for_kubernetes
    ]

    metadata {
        name = "traefik"
    }
}

# Installs the Traefik Helm chart into the "traefik" namespace.
# Traefik will act as the reverse proxy and load balancer for the cluster.
resource "helm_release" "traefik" {
    depends_on = [
        kubernetes_namespace.traefik
    ]

    name = "traefik"
    namespace = "traefik"

    repository = "https://helm.traefik.io/traefik"
    chart = "traefik"

    # Sets Traefik as the default Ingress Controller for the cluster.
    # This means any Ingress resource without a specific ingressClassName
    # will be managed by Traefik.
    set {
        name  = "ingressClass.enabled"
        value = "true"
    }
    set {
        name  = "ingressClass.isDefaultClass"
        value = "true"
    }

    # Configures the HTTP entry point ("web") to automatically redirect
    # all traffic to the HTTPS entry point ("websecure").
    set {
        name  = "ports.web.redirectTo"
        value = "websecure"
    }

    # Enables TLS on the "websecure" (HTTPS) entry point, allowing Traefik
    # to handle TLS termination for incoming traffic.
    set {
        name  = "ports.websecure.tls.enabled"
        value = "true"
    }

}