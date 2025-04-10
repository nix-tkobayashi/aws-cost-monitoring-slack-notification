# SNSトピック
resource "aws_sns_topic" "cost_watcher" {
  name = var.project
}

# Chatbot用のIAMロール
resource "aws_iam_role" "chatbot" {
  name = "${var.project}-chatbot"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "chatbot.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "chatbot" {
  name = "AWS-Chatbot-NotificationsOnly-Policy"
  role = aws_iam_role.chatbot.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:Describe*",
          "cloudwatch:Get*",
          "cloudwatch:List*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Chatbot設定
resource "aws_chatbot_slack_channel_configuration" "cost_watcher" {
  configuration_name = var.project
  iam_role_arn       = aws_iam_role.chatbot.arn
  logging_level      = "NONE"
  slack_channel_id   = var.slack_channel_id
  slack_team_id      = var.slack_workspace_id
  sns_topic_arns     = [aws_sns_topic.cost_watcher.arn]
}

# Step Functions用のIAMロール
resource "aws_iam_role" "step_functions" {
  name = "${var.project}-sfn"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "step_functions" {
  name = "SFnPolicy"
  role = aws_iam_role.step_functions.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "xray:GetSamplingRules",
          "xray:GetSamplingTargets"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ce:GetCostAndUsage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.cost_watcher.arn
      }
    ]
  })
}

# Step Functionsステートマシン
resource "aws_sfn_state_machine" "cost_watcher" {
  name     = var.project
  role_arn = aws_iam_role.step_functions.arn

  definition = jsonencode({
    Comment       = "A description of my state machine"
    QueryLanguage = "JSONata"
    StartAt       = "GetCostAndUsage"
    States = {
      GetCostAndUsage = {
        Type     = "Task"
        Resource = "arn:aws:states:::aws-sdk:costexplorer:getCostAndUsage"
        Arguments = {
          Filter = {
            Not = {
              Dimensions = {
                Key    = "SERVICE"
                Values = ["Tax"]
              }
            }
          }
          Granularity = "MONTHLY"
          GroupBy = [{
            Key  = "SERVICE"
            Type = "DIMENSION"
          }]
          Metrics = ["UnblendedCost"]
          TimePeriod = {
            End   = "{% $millis() ~> $fromMillis('[Y0001]-[M01]-[D01]') %}"
            Start = "{% ($millis() - 86400000 * 7) ~> $fromMillis('[Y0001]-[M01]-[D01]') %}"
          }
        }
        Assign = {
          AngryThreshold = 10
        }
        Next = "SNS Publish"
        Output = {
          CostSorted = "{% ($all_entries := $map($zip($states.result.ResultsByTime[].Groups[].Keys[0], $states.result.ResultsByTime[].Groups[].Metrics.UnblendedCost.Amount.$number()), function($v) { {\"Service\": $v[0], \"Amount\": $v[1]} }); $services := $all_entries.Service ~> $distinct(); $cost_per_service := $map($services, function($s){ {\"Service\": $s, \"Total\": $all_entries[Service=$s].Amount ~> $sum() ~> $round(1)} }); $sort($cost_per_service, function($l, $r){ $l.Total < $r.Total })) %}"
          CostSum    = "{% $states.result.ResultsByTime[].Groups[].Metrics.UnblendedCost.Amount.$number() ~> $sum() ~> $round(1) %}"
        }
      }
      "SNS Publish" = {
        Type     = "Task"
        Resource = "arn:aws:states:::sns:publish"
        Arguments = {
          Message = {
            version = "1.0"
            source  = "custom"
            content = {
              textType    = "client-markdown"
              title       = "{% $states.input.CostSum > $AngryThreshold ? \":serious_face_with_symbols_covering_mouth: コスト監視くんはお怒りです\" : \":simple_smile: コスト監視くんは平常心を保っています\" %}"
              description = "{% \"ここ1週間ぐらいのコストは \" & $string($states.input.CostSum) & \" USD です。\" & \"\\n\" & \"\\n:one: \" & ( $states.input.CostSorted[0].Service ~> $replace(/^(AWS|Amazon)\\s*/,\"\") ) & \": \" & $states.input.CostSorted[0].Total & \" USD\" & \"\\n:two: \" & ( $states.input.CostSorted[1].Service ~> $replace(/^(AWS|Amazon)\\s*/,\"\") ) & \": \" & $states.input.CostSorted[1].Total & \" USD\" & \"\\n:three: \" & ( $states.input.CostSorted[2].Service ~> $replace(/^(AWS|Amazon)\\s*/,\"\") ) & \": \" & $states.input.CostSorted[2].Total & \" USD\" & \"\\n:four: \" & ( $states.input.CostSorted[3].Service ~> $replace(/^(AWS|Amazon)\\s*/,\"\") ) & \": \" & $states.input.CostSorted[3].Total & \" USD\" & \"\\n:five: \" & ( $states.input.CostSorted[4].Service ~> $replace(/^(AWS|Amazon)\\s*/,\"\") ) & \": \" & $states.input.CostSorted[4].Total & \" USD\" %}"
            }
          }
          TopicArn = aws_sns_topic.cost_watcher.arn
        }
        End = true
      }
    }
  })
}

# Scheduler用のIAMロール
resource "aws_iam_role" "scheduler" {
  name = "${var.project}-scheduler"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "scheduler" {
  name = "StartExecution"
  role = aws_iam_role.scheduler.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["states:StartExecution"]
        Resource = [aws_sfn_state_machine.cost_watcher.arn]
      }
    ]
  })
}

# Scheduler
resource "aws_scheduler_schedule" "cost_watcher" {
  name                         = var.project
  description                  = "Post AWS costs to Slack channel"
  schedule_expression          = var.batch_schedule
  schedule_expression_timezone = var.batch_timezone
  flexible_time_window {
    mode                      = "FLEXIBLE"
    maximum_window_in_minutes = 1
  }
  state = "ENABLED"
  target {
    arn      = aws_sfn_state_machine.cost_watcher.arn
    role_arn = aws_iam_role.scheduler.arn
  }
}
