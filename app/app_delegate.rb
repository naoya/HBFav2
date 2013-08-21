# -*- coding: utf-8 -*-
class AppDelegate
  attr_accessor :viewController

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    NSLog("RUBYMOTION_ENV: " + RUBYMOTION_ENV)

    app_config = ApplicationConfig.sharedConfig
    app_user   = ApplicationUser.sharedUser.load

    ## initialize BugSense
    if app_user.send_bugreport?
      BugSenseController.sharedControllerWithBugSenseAPIKey(
        app_config.vars[:bugsense][:api_key]
      )
    end

    ## initialize PocketAPI
    PocketAPI.sharedAPI.setConsumerKey(
      app_config.vars[:pocket][:consumer_key]
    )

    ## initialize Hatena-Bookmark SDK
    HTBHatenaBookmarkManager.sharedManager.setConsumerKey(
      app_config.vars[:hatena][:consumer_key],
      consumerSecret:app_config.vars[:hatena][:consumer_secret]
    )

    ## initialize Parse.com
    Parse.setApplicationId(
      "nY5jbkvvEKPUaehNgb0q9IIvYxSE2jx6CwNm2b5c",
      clientKey:"mekSRONfofOj5tpV7e9XxG65nRCc650JevZcRB6l"
    )

    self.initialize_audio_session
    self.configure_navigation_bar
    self.configure_bar_button_item

    UIApplication.sharedApplication.setStatusBarStyle(UIStatusBarStyleBlackOpaque)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

    @viewController = HBFav2PanelController.sharedController
    @viewController.leftGapPercentage = 0.7
    @viewController.leftPanel = LeftViewController.new
    @viewController.centerPanel = HBFav2NavigationController.alloc.initWithRootViewController(
      TimelineViewController.new.tap do |c|
        c.user     = app_user.to_bookmark_user
        c.as_home  = true
      end
    )
    @window.rootViewController = @viewController
    @window.makeKeyAndVisible
    true
  end

  def initialize_audio_session
    session = AVAudioSession.sharedInstance
    err_ptr = Pointer.new(:object)
    ok = session.setCategory(AVAudioSessionCategoryPlayback, error:err_ptr)
    if not ok
      NSLog("Failed to setCategory")
    end
  end

  def configure_navigation_bar
    background_image = UIImage.imageNamed("UINavigationBarBackGround.png")
    UINavigationBar.appearance.setBackgroundImage(background_image, forBarMetrics:UIBarMetricsDefault)
  end

  def configure_bar_button_item
    background_image = UIImage.imageNamed("UIBarButtonItemBarBackGround.png")
    UIBarButtonItem.appearanceWhenContainedIn(UINavigationBar, nil).setBackgroundImage(background_image, forState:UIControlStateNormal, barMetrics:UIBarMetricsDefault)
    UIBarButtonItem.appearanceWhenContainedIn(UINavigationBar, nil).setBackButtonBackgroundImage(background_image, forState:UIControlStateNormal, barMetrics:UIBarMetricsDefault)
  end

  def application(application, openURL:url, sourceApplication:sourceApplication, annotation:annotation)
    if PocketAPI.sharedAPI.handleOpenURL(url)
      return true
    end
    return true
  end

  def applicationDidEnterBackground(application)
    notify = NSNotification.notificationWithName("applicationDidEnterBackground", object:self)
    NSNotificationCenter.defaultCenter.postNotification(notify)
  end

  def applicationWillEnterForeground(application)
    notify = NSNotification.notificationWithName("applicationWillEnterForeground", object:self)
    NSNotificationCenter.defaultCenter.postNotification(notify)
  end

  ## pragma - push notification

  def application(application, didRegisterForRemoteNotificationsWithDeviceToken:deviceToken)
    user = ApplicationUser.sharedUser

    if user.hatena_id.present? and user.webhook_key.present?
      installation = PFInstallation.currentInstallation
      installation.setDeviceTokenFromData(deviceToken)
      installation.setObject(user.hatena_id, forKey:"owner")
      installation.setObject(user.webhook_key, forKey:"webhook_key")
      installation.saveInBackground
    end
  end

  def application(application, didReceiveRemoteNotification:userInfo)
    PFPush.handlePush(userInfo)
  end

  def application(application, didFailToRegisterForRemoteNotificationsWithError:error)
    if error.code == 3010
      NSLog("Push notifications don't work in the simulator!")
    else
      NSLog("didFailToRegisterForRemoteNotificationsWithError: %@", error)
    end
  end
end

if RUBYMOTION_ENV == 'release'
  def NSLog(msg)
  end
end
