# -*- coding: utf-8 -*-
class AppDelegate
  attr_accessor :viewController, :timelineViewController
  include HBFav2::RemoteNotificationDelegate
  include HBFav2::GoogleAnalytics

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    NSLog("RUBYMOTION_ENV: " + RUBYMOTION_ENV)

    app_config = ApplicationConfig.sharedConfig

    self.configure_bugsense_service(app_config)
    self.configure_pocket_service(app_config)
    self.configure_hatena_bookmark_service(app_config)
    self.configure_google_api_service(app_config)
    self.configure_google_analytics(app_config.vars['google_analytics']['tracking_id'])
    self.configure_parse_service(app_config, launchOptions)

    self.initialize_audio_session
    self.configure_navigation_bar
    self.configure_bar_button_item
    self.configure_status_bar
    self.initialize_window

    ## Notification Center のプッシュ通知履歴から開いたとき
    if launchOptions.present?
      notification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]
      if notification
        payload = notification.userInfo
      else
        payload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]
      end
      self.handleNotificationPayload(payload) if payload.present?
    else
      watch_pasteboard
    end

    self.configure_background_fetch
    true
  end

  def configure_status_bar
    if UIDevice.currentDevice.ios7?
      UIApplication.sharedApplication.setStatusBarStyle(UIStatusBarStyleLightContent)
    else
      UIApplication.sharedApplication.setStatusBarStyle(UIStatusBarStyleBlackOpaque)
    end
  end

  def initialize_window
    app_user   = ApplicationUser.sharedUser.load

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

    view_controllers = self.initialize_view_controllers(app_user)

    @viewController = HBFav2PanelController.sharedController
    @viewController.leftGapPercentage = 0.7

    @leftViewController = LeftViewController.new
    @leftViewController.controllers = view_controllers
    @viewController.leftPanel = @leftViewController

    @viewController.centerPanel = HBFav2NavigationController.alloc.initWithRootViewController(
      @timelineViewController
    )
    @window.rootViewController = @viewController
    @window.makeKeyAndVisible
  end

  def initialize_view_controllers(app_user)
    user = app_user.to_bookmark_user

    @timelineViewController = TimelineViewController.new.tap do |c|
      c.user     = user
      c.as_home  = true
    end

    @bookmarksViewController = TimelineViewController.new.tap do |c|
      c.user  = user
      c.content_type = :bookmark
      c.title = user.name
      c.as_home  = true
    end

    @hotentryViewController = HotentryViewController.new.tap do |c|
      c.list_type = :hotentry
      c.as_home   = true
    end

    @entrylistViewController = HotentryViewController.new.tap do |c|
      c.list_type = :entrylist
      c.as_home   = true
    end

    @accountViewController = AccountViewController.new.tap { |c| c.as_home = true }
    @appInfoViewController = AppInfoViewController.new.tap { |c| c.as_home = true }

    return {
      :timeline  => @timelineViewController,
      :bookmarks => @bookmarksViewController,
      :hotentry  => @hotentryViewController,
      :entrylist => @entrylistViewController,
      :account   => @accountViewController,
      :appInfo   => @appInfoViewController,
    }
  end

  def development?
    RUBYMOTION_ENV == "development"
  end

  def release?
    !development?
  end

  def configure_bugsense_service(app_config)
    if not Device.simulator? and app_user.send_bugreport?
      BugSenseController.sharedControllerWithBugSenseAPIKey(
        app_config.vars['bugsense']['api_key']
      )
    end
  end

  def configure_pocket_service(app_config)
    PocketAPI.sharedAPI.setConsumerKey(
      app_config.vars["pocket"]["consumer_key"]
    )
  end

  def configure_hatena_bookmark_service(app_config)
    HTBHatenaBookmarkManager.sharedManager.setConsumerKey(
      app_config.vars['hatena']['consumer_key'],
      consumerSecret:app_config.vars['hatena']['consumer_secret']
    )
  end

  def configure_google_api_service(app_config)
    GoogleAPI.sharedAPI.api_key = app_config.vars['google']['api_key']
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

  def configure_background_fetch
    if UIDevice.currentDevice.ios7?
      NSLog("Background Fetch Enabled")
      UIApplication.sharedApplication.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
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
    watch_pasteboard
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
    if url.kind_of?(NSURL)
      url = url.absoluteString
    end

    controller = HBFav2NavigationController.alloc.initWithRootViewController(
      WebViewController.new.tap do |c|
        c.bookmark = Bookmark.new({ :link => url })
        c.on_modal = true
      end
    )
    @viewController.presentViewController(controller)
  end

  def watch_pasteboard
    pasteboard = UIPasteboard.generalPasteboard
    if string = pasteboard.string
      if matches = string.match(%r{(https?://.*)})
        url  = matches[1]
        user = ApplicationUser.sharedUser
        if user.last_url_in_pasteboard and user.last_url_in_pasteboard == url
        else
          user.last_url_in_pasteboard = url
          user.save
          whenFoundURLInPasteboard(matches[1])
        end
      end
    end
  end

  def whenFoundURLInPasteboard(url)
    @logo ||= UIImage.imageNamed("default_app_logo.png")
    banner = MPNotificationView.notifyWithText(
      "コピーしたURLを開く",
      detail:url,
      image:@logo,
      duration:4.0,
      andTouchBlock:lambda { |notificationView|
        self.presentWebViewControllerWithURL(url)
      }
    )
    banner.detailTextLabel.font = UIFont.systemFontOfSize(12)
    banner.detailTextLabel.textColor = "#333333".uicolor
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

  def application(application, performFetchWithCompletionHandler:completionHandler)
    self.timelineViewController.performBackgroundFetchWithCompletion(completionHandler)
  end
end

if RUBYMOTION_ENV == 'release'
  def NSLog(msg)
  end
end
