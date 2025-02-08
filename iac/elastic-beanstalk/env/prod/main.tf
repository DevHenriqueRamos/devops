module "Production" {
  source = "../../infra"

  name        = "producao"
  description = "aplicação-de-producao"
  environment = "ambiente-de-producao"
  machine     = "t2.micro"
  max         = 5
}
