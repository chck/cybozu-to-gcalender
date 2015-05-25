cybozu-to-gcalender
===================
Gmailで受信したCybozuの予定をGoogleCalendarに登録してくれる

##Requirement
```
ruby 2.1.3

CybozuでGmail通知設定を済ませ、GmailでCybozu用の受信boxとフィルタを設定、API.yamlにgmailのid・pw・受信box・googleapiのid, secretを記入しておくこと

```

##Install
```
bundle install --path vendor/bundle
```

##Usage
```
bundle exec ruby load-cybozu.rb
bundle exec ruby register-gcalendar.rb
```
