## kingtime_checker

KING OF TIME上の打刻漏れ・打刻ミス（連続した出勤打刻など）をチェックして
通知するツール。

### 使い方

1. 以下のようなconfig.jsonを作成する。

```
{
  "api_token": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  "divisions": [
    {
      "code": "009",
      "leader": {
        "fullname": "Ichiro Suzuki",
        "email": "suzuki@example.com"
      }
    },
    {
      "code": "010",
      "leader": {
        "fullname": "Taro Yamada",
        "email": "yamada@exampel.com"
      }
    }
  ]
}
```

2. 以下のコマンドを実行すると、前日に打刻漏れ・ミスのある人にメールで
   通知される。

```
$ ruby kingtime_checker.rb
```
