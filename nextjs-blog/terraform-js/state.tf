terraform {
  backend "s3" {
    bucket = "ify-my-terraform-state"
    key = "global/s3/terraform.tfstate"
    region = "eu-west-2"
    dynamodb_table = "terraform-lock-file"
  }
}