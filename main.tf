# Definir os provedores
provider "aws" {
  region = var.region
}

# Inclui os recursos principais
module "network" {
  source = "./network"
}

module "instances" {
  source = "./instances"
}

module "efs" {
  source = "./efs"
}

module "s3" {
  source = "./s3"
}

module "load_balancer" {
  source = "./load_balancer"
}