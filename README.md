# AWSコスト監視くん

AWSのコストを監視し、Slackに通知するTerraformモジュールです。

## 機能

- AWSのコストを定期的に確認
- コストが閾値を超えた場合、Slackに通知
- コストの内訳をサービスごとに表示
- カスタマイズ可能なスケジュール設定

## モジュール構造

```
.
├── modules/
│   └── cost-watcher/     # コスト監視モジュール
│       ├── main.tf       # メインのリソース定義
│       ├── variables.tf  # 変数定義
│       └── outputs.tf    # 出力定義
└── examples/
    └── basic/           # 基本的な使用例
        ├── main.tf      # モジュールの使用例
        ├── variables.tf # 変数定義
        └── README.md    # 使用例の説明
```

## 使用方法

1. リポジトリをクローンします：
```bash
git clone https://github.com/nix-tkobayashi/aws-cost-monitoring-slack-notification.git
cd aws-cost-monitoring-slack-notification/examples/basic
```

2. モジュールを呼び出すTerraformコードを作成します(main.tf)：

```hcl
module "cost_watcher" {
  source = "../../modules/cost-watcher"

  project            = "my-project"
  slack_channel_id   = "C0123456789"
  slack_workspace_id = "T0123456789"
  cost_lookback_days = 7
  angry_threshold    = 100
  batch_schedule     = "cron(0 9 ? * MON-FRI *)"
  batch_timezone     = "Asia/Tokyo"
}
```

3. 必要な変数を設定します：
   - `project`: プロジェクト名
   - `slack_channel_id`: SlackチャンネルID
   - `slack_workspace_id`: SlackワークスペースID
   - `cost_lookback_days`: コストを確認する日数（デフォルト: 7）
   - `angry_threshold`: コスト監視くんが怒る閾値（USD）（デフォルト: 100）
   - `batch_schedule`: コスト確認のスケジュール（cron形式）（デフォルト: 平日9:00）
   - `batch_timezone`: スケジュールのタイムゾーン（デフォルト: Asia/Tokyo）

4. Terraformを実行します：
```bash
terraform init
terraform plan
terraform apply
```

## 必要な権限

このモジュールを使用するには、以下のAWS権限が必要です：

- Cost Explorerの読み取り権限
- SNSトピックの作成・管理権限
- Step Functionsの作成・管理権限
- EventBridge Schedulerの作成・管理権限
- IAMロール・ポリシーの作成・管理権限

## 作者

[nix-tkobayashi](https://github.com/nix-tkobayashi)

## 謝辞

このプロジェクトは、以下の記事を参考に作成されました：
- [AWS Step Functions(JSONata)でAWS料金をSlackへ通知【Lambda無し】](https://dev.classmethod.jp/articles/aws-cost-watcher-with-sfn-jsonata/)

## ライセンス

MITライセンスの下で公開されています。詳細は[LICENSE](LICENSE)を参照してください。