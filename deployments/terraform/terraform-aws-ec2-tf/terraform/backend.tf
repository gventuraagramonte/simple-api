terraform {
  cloud {
    organization = "GiorgioDev"

    workspaces {
      name = "simple-api"
    }
  }
}