data "aws_caller_identity" "current" {}
locals {
  aws_account_id = data.aws_caller_identity.current.account_id
}

variable "app_name" {
  default = null
}
locals {
  app_name = var.app_name == null ? "elliptio" : var.app_name
}

# specify most variables in dotenv file
# see https://stackoverflow.com/a/76194380/2135504
variable "dot_env_file_path" {
  default = "../.env"
}
locals {
  dot_env_regex = "(?m:^\\s*([^#\\s]\\S*)\\s*=\\s*[\"']?(.*[^\"'\\s])[\"']?\\s*$)"
  dot_env       = { for tuple in regexall(local.dot_env_regex, file(var.dot_env_file_path)) : tuple[0] => sensitive(tuple[1]) }
}
