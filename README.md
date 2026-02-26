# ☸️🚀 Civo Kubernetes Cluster Automation

> Spin up opinionated, production-ready Kubernetes clusters on Civo in seconds – *because life is too short for manual YAML.* 🏖️

## ✨ Features

- ⚡️ **Fast provisioning** – From zero to ready in < 90 s.
- 🧪 **Terraform IaC** – Reproducible infrastructure defined as code.
- 🔒 **Secure by default** – CIS-compliant base hardening & network policies.
- 📈 **Observability stack** – Prometheus, Grafana, Loki & Alertmanager shipped out-of-the-box.
- 🔄 **GitOps-ready** – Argo CD pre-installed for seamless continuous delivery.
- 🧹 **One-command teardown** – Clean up resources to avoid unwanted charges.

## 📦 Project Structure

```text
.
├── modules/               # Reusable Terraform modules
├── helm/                  # Helm charts & values
├── manifests/             # Raw Kubernetes yaml overrides
└── README.md              # You are here
```

*(Folders may appear after your first `terraform init`)*

## 🛠️ Prerequisites

1. [Civo account](https://www.civo.com/) with an API token.
2. macOS, Linux, or WSL2 shell with:
   - `terraform` ≥ 1.8
   - `kubectl` ≥ 1.30
   - `helm` ≥ 3.14
   - `civo` CLI ≥ 1.0
   - `make` (optional but recommended)  
3. `git` to clone this repository.

## 🚀 Quick Start

```bash
# 1) Clone
git clone https://github.com/obeone/civo-k8s-cluster.git
cd civo-k8s-cluster

# 2) Export your Civo token
export CIVO_TOKEN="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# 3) Provision the cluster
terraform init
terraform apply -auto-approve

# 4) Grab kubeconfig
civo kubernetes config <cluster-name> --save

# 5) Enjoy! 🎉
kubectl get nodes -o wide
```

## 🔧 Advanced Usage

| Action                | Command            |
|-----------------------|--------------------|
| Destroy everything    | `terraform destroy`|
| Re-deploy Argo CD     | `make argocd`      |
| Upgrade charts        | `make upgrade`     |
| Tail cluster logs     | `make logs`        |

See [`Makefile`](./Makefile) for a complete list of helper targets.

## ⚙️ Configuration

All Terraform variables live in [`terraform.tfvars`](terraform.tfvars).  
Helm chart values are in `helm/*/values.yaml`.

Adjust them to fit your needs (cluster size, k3s version, region, add-ons…).

## 👥 Contributing

Contributions are welcome! Fork the repo and open a pull request 🎉

1. Create your feature branch (`git checkout -b feature/awesome`)
2. Commit your changes (`git commit -m 'feat: add awesome feature'`)
3. Push to the branch (`git push origin feature/awesome`)
4. Open a PR

Please follow Conventional Commits and ensure `make test` passes locally.

## 📜 License

Distributed under the MIT License. See [`LICENSE`](LICENSE) for more information.
 

---

Made with 💙 using [Civo](https://www.civo.com/) & ☸️ Kubernetes.
