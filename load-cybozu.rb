#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#その１：Gmailに接続してサイボウズなイベントをcsvで書きだす

require 'gmail' #ruby-gmail
require "nkf"
require "kconv"
require "yaml"

class LoadCybozu
  def initialize
    conf       = YAML::load(open("../API.yaml"))
    @USERNAME  =conf["username"]
    @PASSWORD  =conf["password"]
    @INBOXNAME =conf["inboxname"]
    @date_plan = []
  end

  def main
    #7日前のGmailから現在までを反映
    weekAgo = DateTime.now - 7
    gmail   = Gmail.new(@USERNAME, @PASSWORD)
    mails   = gmail.mailbox(@INBOXNAME).emails(:all, :after => weekAgo).map do |mail|
      p mailDate = mail.date.strftime("%y%m%d-%X")
      p mailSubject = $1 if mail.subject =~ /\[(登録|削除|変更)\]/
      count = 1
      date  = ""
      plan  = ""
      NKF.nkf("-S -w", "#{mail.body}").each_line do |row|
        if count==1
          #row =~ /(\d\d\d\d)年(\d\d)月(\d\d)日/
          #date="#{$1}-#{$2}-#{$3}"
          date = row.gsub(/日時　　：|
|\n| |（[月火水木金土日]）/, "").gsub(/[年月]/, "-").gsub(/日/, " ")
        elsif count==2
          plan = row.gsub(/予定　　：|\r\n/, "")[0, 20]
        else
          @date_plan << "#{mailDate},#{mailSubject},#{date},#{plan}"
          break
        end
        count+=1
      end

    end
    @date_plan.each do |row|
      if row !~ /期間/
        puts row
        open("plan.txt", "a+") do |f|
          f.puts row
        end
      end
    end
    puts "Done!!"
    #		gmail.logout
  end
end

lc = LoadCybozu.new
lc.main
