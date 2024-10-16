
# Definir um Provedor AWS com alias para outra configuração, se necessário
provider "aws" {
  alias  = "secondary"
  region = var.secondary_region 
}
