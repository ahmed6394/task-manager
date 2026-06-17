terraform {
  backend "s3" {
    bucket       = "todo-list-terra-bucket"
    key          = "dev/terraform.tfstate"
    region       = "eu-north-1"
    encrypt      = true
    use_lockfile = true
  }
}