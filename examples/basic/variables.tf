variable "aws_region" {
  description = "AWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "project" {
  description = "プロジェクト名"
  type        = string
}

variable "slack_channel_id" {
  description = "SlackチャンネルID"
  type        = string
}

variable "slack_workspace_id" {
  description = "SlackワークスペースID"
  type        = string
}

variable "cost_lookback_days" {
  description = "コストを確認する日数"
  type        = number
  default     = 7
}

variable "angry_threshold" {
  description = "コスト監視くんが怒る閾値（USD）"
  type        = number
  default     = 100
}

variable "batch_schedule" {
  description = "コスト確認のスケジュール（cron形式）"
  type        = string
  default     = "cron(0 9 ? * MON-FRI *)"
}

variable "batch_timezone" {
  description = "スケジュールのタイムゾーン"
  type        = string
  default     = "Asia/Tokyo"
} 