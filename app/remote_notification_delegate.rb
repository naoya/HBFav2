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

    ## For iOS 6 (7では呼ばれない)
    def application(application, didReceiveRemoteNotification:userInfo)
      self.handlePush(application, userInfo:userInfo)
    end

    ## for iOS 7 (7でしか呼ばれない)
    def application(application, didReceiveRemoteNotification:userInfo, fetchCompletionHandler:completionHandler)
      self.timelineViewController.performBackgroundFetchWithCompletion(completionHandler)

      ## FIXME: 自分のブックマークは timebased じゃないので自動更新は無理ぽ･･･
      # if self.bookmarksViewController.user.name == userInfo['aps']['...']
      # self.bookmarksViewController.performBackgroundFetchWithCompletion(completionHandler)
      # end
      self.handlePush(application, userInfo:userInfo)
    end

    def handlePush(application, userInfo:userInfo)
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

          ## 他の画面でローカルpushイベントを採れるように、発火
          ## iOS 7 は Background Fetch に任せるので必要ない
          if UIDevice.currentDevice.ios6?
            notify = NSNotification.notificationWithName(
              "applicationDidReceiveRemoteNotification", object:userInfo
            )
            NSNotificationCenter.defaultCenter.postNotification(notify)
          end
        end
      when UIApplicationStateInactive then
        PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        self.handleNotificationPayload(userInfo)
      when UIApplicationStateBackground then
        PFPush.handlePush(userInfo)
      end
    end

    def application(application, didFailToRegisterForRemoteNotificationsWithError:error)
      if error.code == 3010
        NSLog("Push notifications don't work in the simulator!")
      else
        NSLog("didFailToRegisterForRemoteNotificationsWithError: %@", error)
      end
    end
  end
end
