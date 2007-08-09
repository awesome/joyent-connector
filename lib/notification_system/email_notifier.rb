module NotificationSystem
  class EmailNotifier
    def self.notify(notification)
      body =<<EOS
#{notification.notifier.full_name} notified you about #{notification.item.name} (#{notification.item.class_humanize}).

#{MessageHelper.url_for(notification.item)}
EOS

      send_message :subject => "Connector Notification: #{notification.item.name}", 
                   :body    => body,
                   :to      => recipients(notification),
                   :from    => notification.notifier.system_email
    end
    
    def self.alarm(event)
      send_message :subject => "Connector Alarm: #{event.name}",
                   :body    => "#{event.start_time.strftime('%D %T')}\n#{event.name}\n#{event.location}",
                   :to      => recipients(notification),
                   :from    => event.owner.system_email
    end
    
    def self.send_message(opts)
      host          = ENV['SMTP_HOST'] || JoyentConfig.smtp_host
      user          = ENV['SMTP_USER'] || nil
      pass          = ENV['SMTP_PASS'] || nil
      auth          = ENV['SMTP_AUTH'] || nil

      tmail         = TMail::Mail.new
      tmail.to      = opts[:to]
      tmail.from    = opts[:from]
      tmail.subject = opts[:subject]
      tmail.body    = opts[:body]
      
      unless ENV['RAILS_ENV'] == 'test'
        Net::SMTP.start(host, 25, host, user, pass, auth) do |smtp|
          smtp.send_message tmail.encoded, tmail.from, tmail.destinations
        end
      end
    end

    def self.recipients(notification)
      notification.notifiee.person.email_addresses.select(&:use_notifier?)
    end
  end
end
