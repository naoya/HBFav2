# -*- coding: utf-8 -*-
class PermalinkViewController < UIViewController
  attr_accessor :bookmark

  def viewDidLoad
    super

    self.navigationItem.title = "ブックマーク"
    self.view.backgroundColor = UIColor.whiteColor
    self.navigationController.toolbar.translucent = true
    self.navigationController.setToolbarHidden(true, animated:false)
    self.navigationItem.backBarButtonItem = UIBarButtonItem.titled("戻る")

    @bookmarkView = HBFav2::BookmarkView.new.tap do |v|
      v.frame = self.view.bounds
      v.backgroundColor = UIColor.whiteColor

      v.headerView.when_tapped do
        ProfileViewController.new.tap do |c|
          c.user = bookmark.user
          self.navigationController.pushViewController(c, animated:true)
        end
      end

      v.titleButton.addTarget(self, action:'open_webview', forControlEvents:UIControlEventTouchUpInside)

      v.starView.when_tapped do
        StarsViewController.new.tap do |c|
          c.url = @bookmark.permalink
          v.starView.highlighted = true
          v.starView.backgroundColor = '#e5f0ff'.to_color
          self.presentViewController(UINavigationController.alloc.initWithRootViewController(c), animated:true, completion:nil)
        end
      end

      v.usersButton.on(:touch) do
        BookmarksViewController.new.tap do |c|
          c.entry = @bookmark
          self.presentViewController(UINavigationController.alloc.initWithRootViewController(c), animated:true, completion:nil)
        end
      end
    end
    view << @bookmarkView
  end

  def open_webview
    controller = WebViewController.new
    controller.bookmark = @bookmark
    self.navigationController.pushViewController(controller, animated: true)
  end

  def viewWillAppear(animated)
    super

    ## 応急処置
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleBlackOpaque
    UIApplication.sharedApplication.setStatusBarHidden(false, animated:animated)
    self.wantsFullScreenLayout = false

    self.navigationController.toolbar.translucent = true
    self.navigationController.setToolbarHidden(true, animated:animated)

    @bookmarkView.tap do |v|
      ## ここでセットすると隠れた toolbar 部分のサイズが勘定されない、なぜ...
      # v.frame = self.view.bounds
      v.bookmark = self.bookmark
      v.starView.highlighted = false
      v.starView.backgroundColor = UIColor.whiteColor
    end
  end

  def viewDidAppear(animated)
    super
  end

  def viewWillDisappear(animated)
    super
    self.navigationController.toolbar.translucent = false
  end
end
