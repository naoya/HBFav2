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
end

if RUBYMOTION_ENV == 'release'
  def NSLog(msg)
  end
end
