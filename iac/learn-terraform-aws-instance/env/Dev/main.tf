module "aws-dev" {
  source        = "../../infra"
  instance      = "t2.micro"
  aws_region    = "us-west-2"
  key           = "iac-dev"
  name_instance = "Dev Terraform"
  securityGroup = "Dev"
  groupName     = "DEV"
  min           = 0
  max           = 1
  isProduction  = false
}
