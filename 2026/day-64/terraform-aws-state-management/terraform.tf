terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.71.0"
    }
  }
}

terraform {
  backend "s3"{
    bucket = "terraweek-state-akash001"
    key = "terraform.tfstate"
    region = "us-west-2"
    use_lockfile = true

  }
}
