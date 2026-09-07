terraform {
  # Existing shared backend bucket; this project's state uses a separate key.
  # Authentication comes from the normal AWS credential chain.
  backend "s3" {
    bucket       = "nextfoundry-terraform-state-387344700059"
    region       = "us-east-1"
    key          = "andyhopla/prod/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }
}
