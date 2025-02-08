module "prod" {
  source      = "../../infra"
  ecrName     = "producao"
  iamRole     = "producao"
  environment = "producao"
}

output "dns_alb" {
  value = module.prod.dns
}
