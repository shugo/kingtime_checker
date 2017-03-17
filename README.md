## kingtime_checker

### 使い方

1. 以下のようなconfig.jsonを作成する。

```
{
  "api_token": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  "division": "009",
  "admin": {
    "email": "suzuki@example.com"
  }
}
```

2. 以下のコマンドを実行すると、前日に打刻漏れ・ミスのある人にメールで
   通知される。

```
$ ruby kingtime_checker.rb
```
