# -*- coding: utf-8 -*-
class AppDelegate
  attr_accessor :viewController
  include HBFav2::RemoteNotificationDelegate
  include HBFav2::GoogleAnalytics

  def initialize
    IVersion.sharedInstance.appStoreID = 477950722
    IVersion.sharedInstance.remoteVersionsPlistURL = 'https://dl.dropboxusercontent.com/u/2586384/hbfav/versions.plist'
    ## デバッグ
    # IVersion.sharedInstance.previewMode = true
  end

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    NSLog("RUBYMOTION_ENV: " + RUBYMOTION_ENV)

    app_config = ApplicationConfig.sharedConfig
    app_user   = ApplicationUser.sharedUser.load

    ## initialize BugSense
    if app_user.send_bugreport?
      BugSenseController.sharedControllerWithBugSenseAPIKey(
        app_config.vars['bugsense']['api_key']
      )
    end

    ## initialize PocketAPI
    PocketAPI.sharedAPI.setConsumerKey(
      app_config.vars["pocket"]["consumer_key"]
    )

    ## initialize Hatena-Bookmark SDK
    HTBHatenaBookmarkManager.sharedManager.setConsumerKey(
      app_config.vars['hatena']['consumer_key'],
      consumerSecret:app_config.vars['hatena']['consumer_secret']
    )

    GoogleAPI.sharedAPI.api_key = app_config.vars['google']['api_key']

    self.configure_google_analytics(app_config.vars['google_analytics']['tracking_id'])
    self.configure_parse_service(app_config, launchOptions)
    self.initialize_audio_session
    self.configure_navigation_bar
    self.configure_bar_button_item

    if UIDevice.currentDevice.ios7?
      UIApplication.sharedApplication.setStatusBarStyle(UIStatusBarStyleLightContent)
    else
      UIApplication.sharedApplication.setStatusBarStyle(UIStatusBarStyleBlackOpaque)
    end

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

    ## Notification Center のプッシュ通知履歴から開いたとき
    if launchOptions.present?
      notification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]
      if notification
        payload = notification.userInfo
      else
        payload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]
      end
      self.handleNotificationPayload(payload) if payload.present?
    end
    true
  end

  def development?
    RUBYMOTION_ENV == "development"
  end

  def release?
    !development?
  end

  def configure_parse_service(app_config, launchOptions)
    ## initialize Parse.com
    if development?
      Parse.setApplicationId(
        app_config.vars['parse']['development']['application_id'],
        clientKey:app_config.vars['parse']['development']['client_key'],
      )
    else
      Parse.setApplicationId(
        app_config.vars['parse']['production']['application_id'],
        clientKey:app_config.vars['parse']['production']['client_key'],
      )
    end
    PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
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
    if UIDevice.currentDevice.ios7?
      UINavigationBar.appearance.barTintColor = UIColor.colorWithRed(0.000, green:0.450, blue:0.800, alpha:0.7)
      UINavigationBar.appearance.titleTextAttributes = {
        NSForegroundColorAttributeName => UIColor.whiteColor,
        NSFontAttributeName            => UIFont.boldSystemFontOfSize(18)
      }
      UINavigationBar.appearance.tintColor = UIColor.whiteColor
    else
      background_image = UIImage.imageNamed("UINavigationBarBackGround.png")
      UINavigationBar.appearance.setBackgroundImage(background_image, forBarMetrics:UIBarMetricsDefault)
    end
  end

  def configure_bar_button_item
    unless UIDevice.currentDevice.ios7?
      background_image = UIImage.imageNamed("UIBarButtonItemBarBackGround.png")
      UIBarButtonItem.appearanceWhenContainedIn(UINavigationBar, nil).setBackgroundImage(background_image, forState:UIControlStateNormal, barMetrics:UIBarMetricsDefault)
      UIBarButtonItem.appearanceWhenContainedIn(UINavigationBar, nil).setBackButtonBackgroundImage(background_image, forState:UIControlStateNormal, barMetrics:UIBarMetricsDefault)
    end
  end

  def application(application, openURL:url, sourceApplication:sourceApplication, annotation:annotation)
    if matches = url.absoluteString.match(%r{^hbfav:/entry/(https?://.*)})
      self.presentWebViewControllerWithURL(matches[1])
    else
      if PocketAPI.sharedAPI.handleOpenURL(url)
        return true
      end
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
end

if RUBYMOTION_ENV == 'release'
  def NSLog(msg)
  end
end
