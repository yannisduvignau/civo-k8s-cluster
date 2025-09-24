# This file configures cert-manager in the Kubernetes cluster.
# It sets up the necessary namespace, installs cert-manager using a Helm chart,
# and creates a ClusterIssuer for issuing certificates via Let's Encrypt
# using Cloudflare for DNS-01 challenges.

# Creates the "certmanager" namespace in Kubernetes.
# This provides an isolated environment for all cert-manager related resources.
resource "kubernetes_namespace" "certmanager" {

  depends_on = [
    time_sleep.wait_for_kubernetes
  ]

  metadata {
    name = "certmanager"
  }
}

# Installs the cert-manager Helm chart into the "certmanager" namespace.
# cert-manager is a native Kubernetes certificate management controller that helps
# with issuing and renewing TLS certificates.
resource "helm_release" "certmanager" {

  depends_on = [
    kubernetes_namespace.certmanager
  ]

  name      = "certmanager"
  namespace = "certmanager"

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"

  # This setting ensures that the Custom Resource Definitions (CRDs) required
  # by cert-manager are installed as part of the Helm release.
  set {
    name  = "installCRDs"
    value = "true"
  }
}

# Pauses execution for 10 seconds to allow the cert-manager pods and services
# to initialize properly before creating dependent resources.
resource "time_sleep" "wait_for_certmanager" {

  depends_on = [
    helm_release.certmanager
  ]

  create_duration = "10s"
}

# Creates a ClusterIssuer resource named "cloudflare-prod".
# A ClusterIssuer is a Kubernetes resource that represents a certificate authority (CA)
# from which to obtain certificates. This one is configured for Let's Encrypt's
# production environment using a Cloudflare DNS-01 solver.
resource "kubectl_manifest" "cloudflare_prod" {

  depends_on = [
    time_sleep.wait_for_certmanager
  ]

  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: cloudflare-prod
spec:
  acme:
    email: mail-address
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: cloudflare-prod-account-key
    solvers:
    - dns01:
        cloudflare:
          email: mail-address
          apiKeySecretRef:
            name: cloudflare-api-key-secret
            key: api-key
    YAML
}

# Pauses execution for 30 seconds to allow the ClusterIssuer to be
# registered and become ready before other resources attempt to use it.
resource "time_sleep" "wait_for_clusterissuer" {

  depends_on = [
    kubectl_manifest.cloudflare_prod
  ]

  create_duration = "30s"
}