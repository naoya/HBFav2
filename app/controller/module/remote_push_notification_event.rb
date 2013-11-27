module HBFav2
  module RemotePushNotificationEvent
    def receive_remote_push_notifcation_event
      @receive_remote_push_notification_ = true
      nc = NSNotificationCenter.defaultCenter
      nc.addObserver(self, selector:"applicationDidReceiveRemoteNotification:", name:"applicationDidReceiveRemoteNotification", object:nil)
    end

    def applicationDidReceiveRemoteNotification(userInfo)
    end

    def unreceive_remote_push_notification_event
      if @receive_remote_push_notification_
        nc = NSNotificationCenter.defaultCenter
        nc.removeObserver(self, name:"applicationDidReceiveRemoteNotification:", object:nil)
      end
    end
  end
end
