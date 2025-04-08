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

基本的な使用例については、[examples/basic/README.md](examples/basic/README.md)を参照してください。

## 必要な権限

このモジュールを使用するには、以下のAWS権限が必要です：

- Cost Explorerの読み取り権限
- SNSトピックの作成・管理権限
- Step Functionsの作成・管理権限
- EventBridge Schedulerの作成・管理権限
- IAMロール・ポリシーの作成・管理権限

## 作者

[nix-tkobayashi](https://github.com/nix-tkobayashi)

## ライセンス

MITライセンスの下で公開されています。詳細は[LICENSE](LICENSE)を参照してください。