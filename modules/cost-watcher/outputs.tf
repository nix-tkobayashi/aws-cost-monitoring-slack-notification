output "sns_topic_arn" {
  description = "SNSトピックのARN"
  value       = aws_sns_topic.cost_watcher.arn
}

output "step_functions_arn" {
  description = "Step FunctionsステートマシンのARN"
  value       = aws_sfn_state_machine.cost_watcher.arn
}

output "scheduler_arn" {
  description = "SchedulerのARN"
  value       = aws_scheduler_schedule.cost_watcher.arn
} 