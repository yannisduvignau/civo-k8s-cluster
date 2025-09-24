# This Makefile provides convenience targets for common Terraform operations,
# simplifying the workflow for initializing, planning, and applying the
# infrastructure configuration.

# Initializes the Terraform working directory.
# This command downloads the necessary provider plugins and sets up the backend.
init:
	@terraform init

# Creates an execution plan for the Terraform configuration.
# This command shows what actions Terraform will take to modify the infrastructure.
plan:
	@terraform plan

# Applies the changes required to reach the desired state of the configuration.
# The --auto-approve flag bypasses the interactive approval prompt.
apply:
	@terraform apply --auto-approve