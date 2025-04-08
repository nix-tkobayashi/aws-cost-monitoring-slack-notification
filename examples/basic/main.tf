terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "cost_watcher" {
  source = "../../modules/cost-watcher"

  project            = var.project
  slack_channel_id   = var.slack_channel_id
  slack_workspace_id = var.slack_workspace_id
  cost_lookback_days = var.cost_lookback_days
  angry_threshold    = var.angry_threshold
  batch_schedule     = var.batch_schedule
  batch_timezone     = var.batch_timezone
} 