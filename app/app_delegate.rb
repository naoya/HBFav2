# -*- coding: utf-8 -*-
class AppDelegate
  attr_accessor :viewController

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    NSLog("RUBYMOTION_ENV: " + RUBYMOTION_ENV)

    ## initialize PocketAPI
    PocketAPI.sharedAPI.setConsumerKey("16058-73f06a0629616ad0245bbfd0")

    UIApplication.sharedApplication.setStatusBarStyle(UIStatusBarStyleBlackOpaque)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

    @viewController = HBFav2PanelController.sharedController
    @viewController.leftGapPercentage = 0.7
    @viewController.leftPanel = LeftViewController.new
    @viewController.centerPanel = HBFav2NavigationController.alloc.initWithRootViewController(
      TimelineViewController.new.tap do |c|
        app_user = ApplicationUser.sharedUser.load
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
end

if RUBYMOTION_ENV == 'release'
  def NSLog(msg)
  end
end
