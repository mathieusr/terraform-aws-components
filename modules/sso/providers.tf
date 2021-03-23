provider "aws" {
  region = var.region

  dynamic "assume_role" {
    for_each = module.iam_roles.org_role_arn != null ? [true] : []
    content {
      # `terraform import` will not use data from a data source,
      # so on import we have to explicitly specify the role
      role_arn = coalesce(var.import_role_arn, module.iam_roles.org_role_arn)
    }
  }
}

module "iam_roles" {
  source      = "../central-account/modules/iam-roles"
  stage       = var.stage
  assume_role = false
  region      = var.region
  tfstate_bucket_environment_name = var.tfstate_bucket_environment_name
  context     = module.this.context
  tfstate_account_id = var.tfstate_account_id
}

variable "import_role_arn" {
  type        = string
  default     = null
  description = "IAM Role ARN to use when importing a resource"
}
