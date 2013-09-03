# -*- coding: utf-8 -*-
module HBFav2
  module RemoteNotificationDelegate
    def application(application, didRegisterForRemoteNotificationsWithDeviceToken:deviceToken)
      user = ApplicationUser.sharedUser
      if user.configured? and user.wants_remote_notification?
        user.enable_remote_notification!(deviceToken)
      end
    end

    def application(application, didReceiveLocalNotification:notification)
      if application.applicationState == UIApplicationStateInactive
        self.handleNotificationPayload(notification.userInfo)
      end
    end

    def application(application, didReceiveRemoteNotification:userInfo)
      case application.applicationState
      when UIApplicationStateActive then
        if userInfo.present? and userInfo['aps']
          ## LocalNotification で Notification Center に転送
          notification = UILocalNotification.new
          if not notification.nil?
            notification.alertBody = userInfo['aps']['alert']
            notification.userInfo = userInfo
            application.presentLocalNotificationNow(notification)
          end

          if ApplicationUser.sharedUser.wants_notification_when_state_active?
            @logo ||= UIImage.imageNamed("default_app_logo.png")
            banner = MPNotificationView.notifyWithText(
              "HBFav",
              detail:userInfo['aps']['alert'],
              image:@logo,
              duration:3.0,
              andTouchBlock:lambda { |notificationView| self.handleNotificationPayload(userInfo) }
            )
            banner.detailTextLabel.font = UIFont.systemFontOfSize(13)
            banner.detailTextLabel.textColor = "#333333".uicolor
          end
        end
      when UIApplicationStateInactive then
        PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        self.handleNotificationPayload(userInfo)
      when UIApplicationStateBackground then
        PFPush.handlePush(userInfo)
      end
    end

    def handleNotificationPayload(payload)
      if payload.present? and payload['u']
        if payload['id']
          self.presentBookmarkViewControllerWithURL(payload['u'], user:payload['id'])
        else
          self.presentWebViewControllerWithURL(payload['u'])
        end
      end
    end

    def application(application, didFailToRegisterForRemoteNotificationsWithError:error)
      if error.code == 3010
        NSLog("Push notifications don't work in the simulator!")
      else
        NSLog("didFailToRegisterForRemoteNotificationsWithError: %@", error)
      end
    end

    def presentBookmarkViewControllerWithURL(url, user:user)
      controller = HBFav2NavigationController.alloc.initWithRootViewController(
        BookmarkViewController.new.tap do |c|
          c.short_url = url
          c.user_name = user
          c.on_modal = true
        end
      )
      @viewController.presentViewController(controller)
    end

    def presentWebViewControllerWithURL(url)
      controller = HBFav2NavigationController.alloc.initWithRootViewController(
        WebViewController.new.tap do |c|
          c.bookmark = Bookmark.new({ :link => url })
          c.on_modal = true
        end
      )
      @viewController.presentViewController(controller)
    end
  end
end
