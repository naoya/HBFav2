class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds).tap do |w|
      w.rootViewController = UINavigationController.alloc.initWithRootViewController(
        TimelineViewController.new.tap { |c| c.user = User.new({ :name => 'naoya' }) }
      )
      w.makeKeyAndVisible
    end
    true
  end
end

