# -*- coding: utf-8 -*-
class AppInfoViewController < HBFav2::UIViewController
  include HBFav2::ApplicationSwitchNotification
  include HBFav2::MenuTableDelegate

  def viewDidLoad
    super
    self.title = "アプリについて"
    self.tracked_view_name = "AppInfo"

    if UIDevice.currentDevice.ios7_or_later?
      self.edgesForExtendedLayout = UIRectEdgeNone
    end

    @dataSource = [
      {
        :rows => [
          {
            :label  => "ご意見・ご要望",
            :detail => "Github",
            :action => 'open_report'
          },
          {
            :label  => "レビュー",
            :detail => "App Store",
            :action => 'open_review'
          },
        ]
      },
      {
        :title => 'アプリの情報',
        :rows => [
          {
            :label  => "開発者より",
            :accessoryType => UITableViewCellAccessoryDisclosureIndicator,
            :action => 'open_help'
          },
          {
            :label => "クレジット",
            :accessoryType => UITableViewCellAccessoryDisclosureIndicator,
            :action => 'open_credit'
          },
          {
            :label  => "アプリのWebサイト",
            :accessoryType => UITableViewCellAccessoryDisclosureIndicator,
            :action => 'open_website'
          },
          {
            :label => "開発者ブログ",
            :accessoryType => UITableViewCellAccessoryDisclosureIndicator,
            :action => 'open_blog'
          }
        ],
      }
    ]

    @app_info_view = AppInfoView.new
    @app_info_view.menuTable.dataSource = @app_info_view.menuTable.delegate = self
    view << @app_info_view
  end

  def viewWillAppear(animated)
    super
    self.receive_application_switch_notifcation
    self.navigationController.toolbar.translucent = true
    self.navigationController.setToolbarHidden(true, animated:animated)

    @app_info_view.version = NSBundle.mainBundle.infoDictionary.objectForKey('CFBundleShortVersionString')

    self.view.frame = UIScreen.mainScreen.bounds
    @app_info_view.frame = self.view.bounds
    @app_info_view.menuTable.deselectRowAtIndexPath(@app_info_view.menuTable.indexPathForSelectedRow, animated:animated)
  end

  def viewWillDisappear(animated)
    self.unreceive_application_switch_notification
    super
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

  def open_blog
    bookmark = Bookmark.new({
      :title => 'HBFav2',
      :link  => "http://d.hatena.ne.jp/naoya/",
      :count => nil
    })
    controller = WebViewController.new
    controller.bookmark = bookmark
    self.navigationController.pushViewController(controller, animated:true)
  end

  def open_credit
    controller = CreditViewController.new
    self.navigationController.pushViewController(controller, animated:true)
  end

  def open_tips
    controller = TipsViewController.new
    self.navigationController.pushViewController(controller, animated:true)
  end

  def open_help
    controller = HelpViewController.new
    self.navigationController.pushViewController(controller, animated:true)
  end

  def dealloc
    NSLog("dealloc: " + self.class.name)
    super
  end

  def applicationWillEnterForeground
    @app_info_view.menuTable.deselectRowAtIndexPath(@app_info_view.menuTable.indexPathForSelectedRow, animated:true)
  end
end
