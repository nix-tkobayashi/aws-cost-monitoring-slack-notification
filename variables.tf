variable "project" {
  type        = string
  description = "プロジェクト名"
  default     = "aws-cost-watcher"
}

variable "slack_channel_id" {
  type        = string
  description = "Slack channel ID"
  sensitive   = true
}

variable "slack_workspace_id" {
  type        = string
  description = "Slack workspace ID"
  sensitive   = true
}

variable "angry_threshold" {
  type        = number
  description = "コスト警告のしきい値（USD）"
  default     = 10
}

variable "batch_schedule" {
  type        = string
  description = "バッチ実行スケジュール（cron形式）"
  default     = "cron(00 10 * * ? *)"
}

variable "batch_timezone" {
  type        = string
  description = "バッチ実行のタイムゾーン"
  default     = "Japan"
}

variable "cost_lookback_days" {
  type        = number
  description = "コスト取得の過去日数"
  default     = 7
} 