module HBFav2
  module ApplicationSwitchNotification
    def receive_application_switch_notifcation
      @receive_application_switch_notifcation_ = true
      nc = NSNotificationCenter.defaultCenter
      nc.addObserver(self, selector:"applicationDidEnterBackground",  name:"applicationDidEnterBackground", object:nil)
      nc.addObserver(self, selector:"applicationWillEnterForeground", name:"applicationWillEnterForeground", object:nil)
    end

    def applicationDidEnterBackground
    end

    def applicationWillEnterForeground
    end

    def unreceive_application_switch_notification
      if @receive_application_switch_notifcation_
        nc = NSNotificationCenter.defaultCenter
        nc.removeObserver(self, name:"applicationDidEnterBackground", object:nil)
        nc.removeObserver(self, name:"applicationWillEnterForeground", object:nil)
      end
    end
  end
end
