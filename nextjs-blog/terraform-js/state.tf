terraform {
  backend "s3" {
    bucket = "if-my-tf-website-state"
    key = "global/s3/terraform.tfstate"
    region = "eu-west-2"
    dynamodb_table = "ify-db-website-table"
  }
}
