=begin #(fold)
++
Copyright 2004-2007 Joyent Inc.

Redistribution and/or modification of this code is 
governed by the GPLv2.

Report issues and contribute at http://dev.joyent.com/

$Id$
--
=end #(end)

module NotificationSystem
  class SmsNotifier
      extend ActionView::Helpers::TextHelper
      
      @@host        = ENV['SMTP_HOST'] || JoyentConfig.smtp_host
      @@user        = ENV['SMTP_USER'] || nil
      @@pass        = ENV['SMTP_PASS'] || nil
      @@auth        = ENV['SMTP_AUTH'] || nil
      
    def self.notify(notification)
      tmail         = TMail::Mail.new
      tmail.from    = JoyentConfig.sms_notifier_from_address
      tmail.subject = "Notification: #{notification.item.name}"
      body          = "#{MessageHelper.url_for(notification.item)} #{notification.notifier.full_name} notified you about #{notification.item.name} (#{notification.item.class_humanize})."
      tmail.body    = truncate(body, 140)
      
      send_messages(tmail, sms_recipients(notification.notifiee))
    end
       
    def self.alarm(event, user)
      tmail         = TMail::Mail.new
      tmail.from    = JoyentConfig.sms_notifier_from_address
      tmail.subject = "Connector Alarm"
      body          = "Event Alarm: #{event.name} at #{event.alarm_time_in_user_tz.strftime('%D %I:%M %p')} (#{event.location})"
      tmail.body    = truncate(body, 140)
      
      send_messages(tmail, sms_recipients(user))
    end
    
    def self.sms_recipients(user)
      user.person.phone_numbers.select{|ph| ph.use_notifier? && ph.confirmed?}
    end
    
    private
    
      def self.send_messages(tmail, recipients)
        unless ENV['RAILS_ENV'] == 'test' or recipients.empty?
          recipients.each do |sms_recipient|
            tmail.to = sms_recipient.sms_address
            Net::SMTP.start(@@host, 25, @@host, @@user, @@pass, @@auth) do |smtp|
              smtp.send_message tmail.encoded, tmail.from, tmail.destinations
            end
          end
        end
      end
    
  end
end