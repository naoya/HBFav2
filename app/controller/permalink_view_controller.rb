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

    self.view << @bookmarkView = HBFav2::BookmarkView.new.tap do |v|
      v.frame = self.view.bounds
      v.backgroundColor = UIColor.whiteColor
      v.headerView.addGestureRecognizer(UITapGestureRecognizer.alloc.initWithTarget(self, action:'open_profile'))
      v.starView.addGestureRecognizer(UITapGestureRecognizer.alloc.initWithTarget(self, action:'open_stars'))
      v.titleButton.addTarget(self, action:'open_webview', forControlEvents:UIControlEventTouchUpInside)
      v.usersButton.addTarget(self, action:'open_bookmarks', forControlEvents:UIControlEventTouchUpInside)
    end
  end

  def open_profile
    controller = ProfileViewController.new.tap { |c| c.user = bookmark.user }
    self.navigationController.pushViewController(controller, animated:true)
  end

  def open_stars
    controller = StarsViewController.new.tap do |c|
      c.url = @bookmark.permalink
      @bookmarkView.starView.highlighted = true
      @bookmarkView.starView.backgroundColor = '#e5f0ff'.to_color
    end
    self.presentViewController(
      UINavigationController.alloc.initWithRootViewController(controller),
      animated:true,
      completion:nil
    )
  end

  def open_webview
    controller = WebViewController.new
    controller.bookmark = @bookmark
    self.navigationController.pushViewController(controller, animated: true)
  end

  def open_bookmarks
    controller = BookmarksViewController.new.tap { |c| c.entry = @bookmark }
    self.presentViewController(HBFav2NavigationController.alloc.initWithRootViewController(controller), animated:true, completion:nil)
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

  def viewWillDisappear(animated)
    super
    self.navigationController.toolbar.translucent = false
  end

  def dealloc
    NSLog("dealloc: " + self.class.name)
    super
  end
end
