module "aws-prod" {
  source        = "../../infra"
  instance      = "t2.micro"
  aws_region    = "us-west-2"
  key           = "iac-prod"
  name_instance = "Prod Terraform"
  securityGroup = "Producao"
  groupName     = "Prod"
  min           = 1
  max           = 10
  isProduction  = true
}
