terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "GiorgioDev"
    workspaces {
      prefix = "simple-api"
    }
  }
}