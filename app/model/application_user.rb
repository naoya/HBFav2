# -*- coding: utf-8 -*-
class ApplicationUser
  attr_accessor :hatena_id, :use_timeline, :hide_nocomment_bookmarks, :send_bugreport, :webhook_key, :enable_notification_when_state_active, :last_url_in_pasteboard

  def self.sharedUser
    Dispatch.once { @instance ||= new }
    @instance
  end

  def save
    App::Persistence['hatena_id'] = @hatena_id
    App::Persistence['use_timeline'] = @use_timeline
    App::Persistence['hide_nocomment_bookmarks'] = @hide_nocomment_bookmarks
    App::Persistence['send_bugreport'] = @send_bugreport
    App::Persistence['webhook_key'] = @webhook_key
    App::Persistence['enable_notification_when_state_active'] = @enable_notification_when_state_active
    App::Persistence['last_url_in_pasteboard'] = @last_url_in_pasteboard
    self
  end

  def load
    self.hatena_id = App::Persistence['hatena_id']
    self.use_timeline = App::Persistence['use_timeline']
    self.hide_nocomment_bookmarks = App::Persistence['hide_nocomment_bookmarks']
    self.send_bugreport = App::Persistence['send_bugreport']
    self.webhook_key = App::Persistence['webhook_key']
    self.enable_notification_when_state_active = App::Persistence['enable_notification_when_state_active']
    self.last_url_in_pasteboard = App::Persistence['last_url_in_pasteboard']
    self
  end

  def configured?
    self.hatena_id.present?
  end

  def use_timeline?
    self.use_timeline ? true : false
  end

  def hide_nocomment_bookmarks?
    self.hide_nocomment_bookmarks ? true : false
  end

  def send_bugreport?
    self.send_bugreport ? true : false
  end

  def to_bookmark_user
    User.new({ :name => @hatena_id, :use_timeline => @use_timeline })
  end

  def wants_remote_notification?
    self.webhook_key ? true : false
  end

  def wants_notification_when_state_active?
    self.enable_notification_when_state_active ? true : false
  end

  def enable_remote_notification!(token)
    if self.configured? and self.wants_remote_notification?
      installation = PFInstallation.currentInstallation
      installation.setDeviceTokenFromData token
      installation.setObject self.hatena_id, forKey:"owner"
      installation.setObject self.webhook_key, forKey:"webhook_key"
      installation.setObject 'yes', forKey:"enabled"
      installation.saveInBackground
    end
  end

  def disable_remote_notification!
    self.webhook_key = nil
    self.save
    installation = PFInstallation.currentInstallation
    installation.setObject 'no', forKey:"enabled"
    installation.saveInBackground
  end
end
