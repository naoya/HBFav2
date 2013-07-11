# -*- coding: utf-8 -*-
class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    ## initialize PocketAPI
    PocketAPI.sharedAPI.setConsumerKey("16058-73f06a0629616ad0245bbfd0")

    ## Debugging PocketAPI
    # defaults = NSUserDefaults.new
    # data = defaults.dataForKey("PocketAPICurrentLogin")
    # if (data)
    #   login = NSKeyedUnarchiver.unarchiveObjectWithData(data)
    #   App.alert(login.requestToken)
    # end
    UIApplication.sharedApplication.setStatusBarStyle(UIStatusBarStyleBlackOpaque)

    ## initialize HBFav2
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds).tap do |w|
      w.rootViewController = UINavigationController.alloc.initWithRootViewController(
        TimelineViewController.new.tap do |c|
          app_user = ApplicationUser.sharedUser.load

          # FIXME: 管理画面から初期化できるようになったら消す
          app_user.hatena_id ||= 'naoya'

          c.user     = app_user.to_bookmark_user
          c.feed_url = c.user.timeline_feed_url
          c.as_home  = true
        end
      )
      w.makeKeyAndVisible
    end
    true
  end

  def application(application, openURL:url, sourceApplication:sourceApplication, annotation:annotation)
    if PocketAPI.sharedAPI.handleOpenURL(url)
      return true
    end
    return true
  end
end
