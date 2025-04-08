# AWSコスト監視くん - 基本的な使用例

このディレクトリには、AWSコスト監視くんの基本的な使用例が含まれています。

## 使用方法

1. `terraform.tfvars.example`を`terraform.tfvars`にコピーし、必要な値を設定します：

```bash
cp terraform.tfvars.example terraform.tfvars
```

2. 以下の値を設定します：
   - `project`: プロジェクト名
   - `slack_channel_id`: SlackチャンネルID
   - `slack_workspace_id`: SlackワークスペースID
   - `cost_lookback_days`: コストを確認する日数（デフォルト: 7）
   - `angry_threshold`: コスト監視くんが怒る閾値（USD）（デフォルト: 100）
   - `batch_schedule`: コスト確認のスケジュール（cron形式）（デフォルト: 平日9:00）
   - `batch_timezone`: スケジュールのタイムゾーン（デフォルト: Asia/Tokyo）

3. Terraformを初期化します：

```bash
terraform init
```

4. 適用する前に変更内容を確認します：

```bash
terraform plan
```

5. 変更を適用します：

```bash
terraform apply
```

## 注意事項

- SlackチャンネルIDとワークスペースIDは、Slackの設定から確認できます。
- コスト監視くんが怒る閾値は、プロジェクトの予算に合わせて調整してください。
- スケジュールは、必要に応じて変更してください。 