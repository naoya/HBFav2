# -*- coding: utf-8 -*-
class AccountViewController < HBFav2::UIViewController
  include HBFav2::MenuTableDelegate

  def viewDidLoad
    super
    ApplicationUser.sharedUser.addObserver(self, forKeyPath:'hatena_id', options:0, context:nil)

    @user = ApplicationUser.sharedUser.to_bookmark_user
    self.navigationItem.title = @user.name
    self.tracked_view_name = "Account"

    if UIDevice.currentDevice.ios7?
      self.edgesForExtendedLayout = UIRectEdgeNone
    end

    self.initialize_data_source

    @profile_view = HBFav2::ProfileView.new
    @profile_view.menuTable.dataSource = @profile_view.menuTable.delegate = self
    view << @profile_view
  end

  def initialize_data_source
    @dataSource = [
      {
        :title => "設定",
        :rows => [
          {
            :label  => "はてなアカウント",
            :detail => ApplicationUser.sharedUser.hatena_id,
            :action => 'open_hatena_config'
          },
          {
            :label  => 'プッシュ通知',
            :detail => ApplicationUser.sharedUser.wants_remote_notification? ? "設定済み" : "未設定",
            :action => 'open_notification_config'
          },
          {
            :label  => 'クラッシュレポート',
            :detail => ApplicationUser.sharedUser.send_bugreport? ? "オン" : "オフ",
            :action => 'open_bugreport_config',
          },
        ],
      },
      {
        :title => "サービス連携",
        :rows => [
          {
            :label  => "はてなブックマーク",
            :detail => HTBHatenaBookmarkManager.sharedManager.authorized ? HTBHatenaBookmarkManager.sharedManager.username : "未設定",
            :action => 'open_hatena',
            :accessoryType =>  HTBHatenaBookmarkManager.sharedManager.authorized ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone
          },
          {
            :label  => "Pocket",
            :detail => PocketAPI.sharedAPI.username || "未設定",
            :action => 'open_pocket',
            :accessoryType => PocketAPI.sharedAPI.loggedIn? ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone
          },
        ]
      }
    ]
  end

  def viewWillAppear(animated)
    super
    self.navigationController.setToolbarHidden(true, animated:animated)
    self.initialize_data_source

    @profile_view.frame = self.view.bounds
    @profile_view.user  = @user

    indexPath = @profile_view.menuTable.indexPathForSelectedRow
    @profile_view.menuTable.reloadData
    @profile_view.menuTable.selectRowAtIndexPath(indexPath, animated:animated, scrollPosition:UITableViewScrollPositionNone);
    @profile_view.menuTable.deselectRowAtIndexPath(indexPath, animated:animated);
  end

  def observeValueForKeyPath(keyPath, ofObject:object, change:change, context:context)
    if (ApplicationUser.sharedUser == object and keyPath == 'hatena_id')
      @user = ApplicationUser.sharedUser.to_bookmark_user
      self.initialize_data_source
      navigationItem.title = @user.name
      @profile_view.user  = @user
    end
  end

  def open_hatena_config
    self.presentModalViewController(
      UINavigationController.alloc.initWithRootViewController(
        AccountConfigViewController.new.tap { |c| c.allow_cancellation = true }
      ),
      animated:true
    )
  end

  def open_bugreport_config
    self.presentViewController(
      UINavigationController.alloc.initWithRootViewController(BugreportConfigViewController.new),
      animated:true,
      completion:nil
    )
  end

  def open_notification_config
    self.presentViewController(
      UINavigationController.alloc.initWithRootViewController(NotificationConfigViewController.new),
      animated:true,
      completion:nil
    )
  end

  def open_website
    bookmark = Bookmark.new({
      :title => 'HBFav2',
      :link  => 'http://hbfav.bloghackers.net/',
      :count => nil
    })
    controller = WebViewController.new
    controller.bookmark = bookmark
    self.navigationController.pushViewController(controller, animated:true)
  end

  def open_review
    "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=477950722&pageNumber=0&sortOrdering=1&type=Purple+Software&mt=8".nsurl.open
  end

  def open_report
    "https://github.com/naoya/HBFav2/issues?state=open".nsurl.open
  end

  def open_hatena
    if HTBHatenaBookmarkManager.sharedManager.authorized
      self.navigationController.pushViewController(HatenaConfigViewController.alloc.initWithStyle(UITableViewStyleGrouped), animated:true)
    else
      NSNotificationCenter.defaultCenter.addObserver(self, selector:'showOAuthLoginView:', name:KHTBLoginStartNotification, object:nil)
      HTBHatenaBookmarkManager.sharedManager.authorizeWithSuccess(
        lambda {
          self.initialize_data_source
          @profile_view.menuTable.reloadData
        },
        failure: lambda {|error| NSLog(error.localizedDescription) }
      )
    end
  end

  def open_pocket
    if PocketAPI.sharedAPI.loggedIn?
      self.navigationController.pushViewController(PocketViewController.alloc.initWithStyle(UITableViewStyleGrouped), animated:true)
    else
      PocketAPI.sharedAPI.loginWithHandler(
        lambda do |pocket, error|
          if error.nil?
          else
            NSLog(error.localizedDescription)
          end
          self.initialize_data_source
          @profile_view.menuTable.reloadData
        end
      )
    end
  end

  def showOAuthLoginView(notification)
    NSNotificationCenter.defaultCenter.removeObserver(self, name:KHTBLoginStartNotification, object:nil)
    req = notification.object
    navigationController = UINavigationController.alloc.initWithNavigationBarClass(HTBNavigationBar, toolbarClass:nil)
    viewController = HTBLoginWebViewController.alloc.initWithAuthorizationRequest(req)
    navigationController.viewControllers = [viewController]
    self.presentViewController(navigationController, animated:true, completion:nil)
  end

  def dealloc
    NSLog("dealloc: " + self.class.name)
    ApplicationUser.sharedUser.removeObserver(self, forKeyPath:'hatena_id')
    super
  end
end
