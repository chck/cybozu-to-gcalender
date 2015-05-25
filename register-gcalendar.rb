#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#その２：loadCybozuで書きだしたcsvを読み込んでGoogleCalendarに登録

require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/file_storage'
require 'google/api_client/auth/installed_app'
require 'json'
require 'kconv'
require 'csv'
require 'yaml'

class RegisterCalendar
  def initialize
    conf         = YAML::load_file("API.yaml")
    @client      = Google::APIClient.new(:application_name => "Test", :application_versiton => "0.0.1")
    file_storage = Google::APIClient::FileStorage.new("#{$0}-oauth2.json")

    if file_storage.authorization.nil?
      flow                  = Google::APIClient::InstalledAppFlow.new(
        :@client_id     => conf["googleAPI"]["client_id"],
        :@client_secret => conf["googleAPI"]["client_secret"],
        :scope          => ["https://www.googleapis.com/auth/calendar"]
      )
      @client.authorization = flow.authorize(file_storage)
    else
      @client.authorization = file_storage.authorization
    end

    @service  = @client.discovered_api('calendar', 'v3')
    #カレンダーリストの取得
    gcal_list = @client.execute(:api_method => @service.calendar_list.list)

    @gcal_id = nil
    gcal_list.data.items.each do |c|
      if c["summary"] == "Cybozu"
        @gcal_id = c["id"]
        break
      end
    end
    system("echo cant find calendar!!!") if @gcal_id.nil?
  end

  def set_gcalendar(method_date_summary)
    ope              = method_date_summary[0]
    event            = {}
    event["summary"] = method_date_summary[2]
    #時間指定イベント
    if method_date_summary[1].include?(":")
      date_a         = method_date_summary[1].split("〜")
      #DateTime型に変換
      start_time     = DateTime.parse(date_a[0]) - Rational(9, 24) #時差を考慮
      end_time       = DateTime.parse(date_a[1]) - Rational(9, 24) #時差を考慮
      #時間指定の日付をイベントハッシュに登録
      event["start"] = { "date_time" => start_time }
      event["end"]   = { "date_time" => end_time }
      #終日イベント
    else
      date_a         = method_date_summary[1].gsub(/ /, "").split("〜")
      #日付をイベントハッシュに登録
      start_date     = date_a[0]
      end_date       = date_a[1]
      event["start"] = { "date" => start_date }
      event["end"]   = { "date" => end_date }
    end

    @client.execute(:api_method => @service.events.insert, :parameters => { 'calendarId' => @gcal_id }, :body => JSON.dump(event), :headers => { 'Content-Type' => 'application/json' })

  end

  def main
    #		array1 = ["2014-08-15 〜2014-08-15 ","終日らんち！！"]
    #		array2 = ["2014-08-15 20:30〜2014-08-15 23:55","時間指定らんち！！"]
    #		set_gcalendar(array2)
    count = 0
    CSV.open("./plan.txt", "r").each do |row|
      row.delete_at(0)
      puts "#{count+=1}\t#{row}"
      set_gcalendar(row)
    end
    puts "Done!!"
  end
end

rc = RegisterCalendar.new
rc.main
