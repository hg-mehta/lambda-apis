data "terraform_remote_state" "shared_infra" {
  backend = "s3"
  config = {
    bucket = var.shared_infra_bucket_name
    key    = var.shared_infra_state_object_key # Path to your shared state file in a bucket
    region = var.aws_region
    dynamodb_table = var.shared_infra_dynamodb_table_name
  }
}

output "api_domain_id" {
  value = data.terraform_remote_state.shared_infra.outputs.api_domain_id
}