# -*- coding: utf-8 -*-
class AppDelegate
  attr_accessor :viewController

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    NSLog("RUBYMOTION_ENV: " + RUBYMOTION_ENV)
    UIApplication.sharedApplication.setStatusBarStyle(UIStatusBarStyleBlackOpaque)
    ## initialize PocketAPI
    PocketAPI.sharedAPI.setConsumerKey("16058-73f06a0629616ad0245bbfd0")

    self.viewController = HBFav2PanelController.new
    self.viewController.leftGapPercentage = 0.7
    self.viewController.leftPanel = LeftViewController.new
    self.viewController.centerPanel = HBFav2NavigationController.alloc.initWithRootViewController(
      TimelineViewController.new.tap do |c|
        app_user = ApplicationUser.sharedUser.load
        c.user     = app_user.to_bookmark_user
        c.as_home  = true
      end
    )

    ## initialize HBFav2
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds).tap do |w|
      w.rootViewController = self.viewController
    end
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
