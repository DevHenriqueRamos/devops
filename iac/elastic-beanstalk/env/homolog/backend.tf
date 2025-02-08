terraform {
  backend "s3" {
    bucket = "terraform-state-proghenrique"
    key    = "homolog/terraform.tfstate"
    region = "us-west-2"
  }
}
