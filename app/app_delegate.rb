# -*- coding: utf-8 -*-
class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds).tap do |w|
      w.rootViewController = UINavigationController.alloc.initWithRootViewController(
        TimelineViewController.new.tap do |c|
          app_user = ApplicationUser.new
          app_user.load

          # FIXME: 管理画面から初期化できるようになったら消す
          app_user.hatena_id ||= 'naoya'

          # FIXME: User と ApplicationUser の関係整理
          c.user     = User.new({ :name => app_user.hatena_id })
          c.feed_url = c.user.timeline_feed_url
          c.as_home  = true
        end
      )
      w.makeKeyAndVisible
    end
    true
  end
end
