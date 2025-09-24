# This file manages Cloudflare-related resources.
# It creates a Kubernetes secret to store the Cloudflare API key, which is
# required by cert-manager to solve DNS-01 challenges.

# Creates a Kubernetes secret named "cloudflare-api-key-secret".
# This secret stores the Cloudflare API key, which cert-manager will use to
# create DNS records for domain validation (DNS-01 challenge).
resource "kubernetes_secret" "cloudflare_api_key_secret" {

    depends_on = [
        kubernetes_namespace.certmanager
    ]

    metadata {
        name = "cloudflare-api-key-secret"
        namespace = "certmanager"
    }

    data = {
        api-key = var.cloudflare_api_key
    }

    type = "Opaque"
}