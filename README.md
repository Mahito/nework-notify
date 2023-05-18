# NeWork Notify

## Notification of NeWork's rooms status to Slack

NeWorkの状況を可視化して雑談をよりしやすくするためのツール

## Parameters

`FIREBASE_DB_URL` と `TOKEN_API_KEY`、`REFRESH_TOKEN` はGoogle ChromeのDevToolなどを利用して取得してください。

- FIREBASE_DB_URL: NeWork が利用している Firebase DB の URL 
- NEWORK_WORKSPACE: NeWorkのワークスペース名（例: `nttcom` ）
- TOKEN_API_KEY: `https://securetoken.googleapis.com/v1/token?key=...` の `key=...` の部分
- REFRESH_TOKEN: `https://securetoken.googleapis.com/v1/token?key=...` のレスポンスボディ参照
- SLACK_API_TOKEN: SlackにPostするようのToken（Slackで取得）
- SLACK_CHANNEL: Postしたいチャンネル名（例: `#remote` ）

## Usage

```
$ vim .env
```

```.env
NEWORK_WORKSPACE=nttcom
TOKEN_API_KEY=...
REFRESH_TOKEN=...
SLACK_CHANNEL="#remote"
SLACK_API_TOKEN=...
```

```
$ docker-compose up
```

## Develop

For local test & debug.

```
$ export NEWORK_WORKSPACE=nttcom
$ export TOKEN_API_KEY=...
$ export REFRESH_TOKEN=...
$ export SLACK_CHANNEL="#remote"
$ export SLACK_API_TOKEN=...
$ bundle exec ruby lib/nework-notify.rb
```
