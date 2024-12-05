# Terraform modules

This repository contains a collection of predefined **Terraform** configurations designed to ease the management of AWS Organizations, Organizational Units, Organization Accounts, and DNS Records, with the purpose to efficiently streamline the onboarding for new accounts.

## Table of contents <!-- omit in toc -->

- [Modules overview](#modules-overview)
- [Requirements](#requirements)
- [Usage](#usage)
  - [Organization Setup](#organization-setup)
  - [Organizational Unit](#organizational-unit)
  - [Organization Account](#organization-account)
- [Onboarding workflows](#onboarding-workflows)
  - [Simple implementation](#simple-implementation)
  - [Proposed implementation (recommended)](#proposed-implementation-recommended)

---

## Modules overview

The repository provides the following **Terraform** modules:

| Name | Description |
| --- | --- |
| Organization Setup | Attach global configurations to an AWS Organization and create a global administration role |
| Organizational Unit | Create and manage hierarchical Organizational Units within an AWS Organization |
| Organization Account | Provision and manage AWS Accounts within Organizational Units |

## Requirements

- **Terraform**
- **AWS CLI**
- An **AWS User** created in the main AWS Organization account, with permissions to create Organizational Units, IAM and SSO executions, configured to use with the **AWS CLI**

```bash
eval $(aws configure export-credentials --profile <aws-profile-name> --format env)
```

## Usage

This is the basic usage for each of the modules:

### Organization Setup

```hcl
# https://us-east-1.console.aws.amazon.com/organizations/v2/home?region=us-east-1#
module "organization_setup" {
  source = "git@gitlab.com:borneo63/terraform-modules.git//aws/organization-setup?ref=0.1.0"

  roles = [
    {
      name   = "my-admin-role"
      policy = "AdministratorAccess"
    }
  ]
}
```

### Organizational Unit

```hcl
module "organizational_unit" {
  source = "git@gitlab.com:borneo63/terraform-modules.git//aws/organizational-unit?ref=0.1.0"

  name = "my-ou"
}
```

### Organization Account

```hcl
module "organization_account" {
  source = "git@gitlab.com:borneo63/terraform-modules.git//aws/organization-account?ref=0.1.0"

  organizational_unit = "my-ou"

  access_role = "my-admin-role"

  account_name  = "my-child-account"
  account_email = "my-email@my-company.io"

  domain_name = "my-company.io"
  dns_records = [
    {
      "type": "CNAME",
      "name": "www",
      "value": "my-company.io"
    },
  ]
}
```

## Onboarding workflows

You can copy-paste the previous examples into different files in an organization folder structure you define, changing their values as needed, keeping an intuitive way to keep track of the changes and resources created, having a predefined workflow to ease the use the modules and manage particular account settings.

### Simple implementation

```console
onboardings/
├── organizations/
│   ├── my-aws-org/
│   │   ├── main.tf
│   │   ├── organization-accounts/
│   │   │   ├── my-child-account/
│   │   │   │   ├── main.tf
│   │   │   ├── my-other-child-account/
│   │   │   │   └── main.tf
│   │   ├── organizational-units/
│   │   │   ├── my-ou/
│   │   │   │   └── main.tf
...
```

> **Caveats:** Because **Terraform** will create its needed structure on the current folder, you need to access each of these folders to create the desired resources, making difficult by an automate process to keep track and debug a process if folder structure changes. You're also repeating the same **Terraform** code for each of the projects.

You can access each of the folders containing a **Terraform** configuration or you can call them by setting the corresponding folder and variable files:

```bash
cd onboardings/organizations/my-aws-org/
terraform init
terraform apply
cd -
cd onboardings/organizations/my-aws-org/organizational-unit/my-ou/
terraform init
terraform apply
cd -
cd onboardings/organizations/my-aws-org/organization-accounts/my-child-account/
terraform init
terraform apply
cd -
cd onboardings/organizations/my-aws-org/organization-accounts/my-other-child-account/
terraform init
terraform apply
cd -
```

### Proposed implementation (recommended)

The previous [usage examples files](./examples) are present in this repository for you to simply copy them into your filesystem, with the proper placeholders, variable settings and module calls.

We can call them with the variables already set making use of `TFVARS` files, so we avoid copying the same module files into different onboarding projects.

You can have a folder structure similar to the following:

```console
deployments/
├── organization/
│   └── main.tf
├── organization-account/
│   └── main.tf
└── organizational-unit/
    └── main.tf
```

And the actual onboarding files stored this way:

```console
onboardings/
├── my-aws-org/
│   ├── organization.my-aws-org.tfvars.json
│   ├── organization-account.my-child-account.tfvars.json
│   ├── organization-account.my-other-child-account.json
│   └── organizational-unit.my-ou.tfvars.json
...
```

For example, this is all the information a `.tfvars.json` file needs for an **Organization Account** to be created:

```json
{
  "organizational_unit": "my-ou",
  "account_name": "my-child-account",
  "account_email": "my-email@my-company.io",
  "access_role": "my-admin-role",
  "domain_name": "my-company.io",
  "dns_records": [
    {
      "type": "CNAME",
      "name": "www",
      "value": "my-company.io"
    },
    {
      "type": "TXT",
      "name": "@",
      "value": "message=Welcome to my company"
    }
  ],
  "tags": {
    "organization": "my-aws-org",
    "section": "onboarding"
  }
}
```

To execute the deployments we'll do like the following:

```bash
terraform -chdir=$(pwd)/deployments/organization/ init
terraform -chdir=$(pwd)/deployments/organization/ apply -env-var=$(pwd)/onboardings/my-aws-org/my-aws-org.tfvars.json
terraform -chdir=$(pwd)/deployments/organizational-unit/ init
terraform -chdir=$(pwd)/deployments/organizational-unit/ apply -env-var=$(pwd)/onboardings/my-aws-org/my-ou.tfvars.json
terraform -chdir=$(pwd)/deployments/organization-account/ init
terraform -chdir=$(pwd)/deployments/organization-account/ apply -env-var=$(pwd)/onboardings/my-aws-org/my-child-account.tfvars.json
terraform -chdir=$(pwd)/deployments/organization-account/ apply -env-var=$(pwd)/onboardings/my-aws-org/my-other-child-account.tfvars.json
```

> None of these implementations are considering the **Terraform** state files that keep track of the deployments applied.
