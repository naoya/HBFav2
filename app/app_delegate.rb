class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds).tap do |w|
      w.rootViewController = UINavigationController.alloc.initWithRootViewController(
        TimelineViewController.new.tap do |c|
          c.user     = User.new({ :name => 'naoya' })
          c.feed_url = c.user.timeline_feed_url
          c.as_home  = true
        end
      )
      w.makeKeyAndVisible
    end
    true
  end
end
