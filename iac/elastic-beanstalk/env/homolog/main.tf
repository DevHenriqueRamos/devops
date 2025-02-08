module "Homologacao" {
  source = "../../infra"

  name        = "homologacao"
  description = "aplicação-de-homologacao"
  environment = "ambiente-de-homologacao"
  machine     = "t2.micro"
  max         = 3
}
