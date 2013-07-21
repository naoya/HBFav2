# -*- coding: utf-8 -*-
class PermalinkViewController < UIViewController
  attr_accessor :bookmark

  def viewDidLoad
    super

    self.navigationItem.title = "ブックマーク"
    self.navigationItem.backBarButtonItem = UIBarButtonItem.titled("戻る")
    self.view.backgroundColor = UIColor.whiteColor

    @bookmarkView = HBFav2::BookmarkView.new.tap do |v|
      v.frame = CGRectZero

      v.headerView.when_tapped do
        ProfileViewController.new.tap do |c|
          c.user = bookmark.user
          self.navigationController.pushViewController(c, animated:true)
        end
      end

      v.titleButton.on(:touch) do
        WebViewController.new.tap do |c|
          c.bookmark = @bookmark
          navigationController.pushViewController(c, animated:true)
        end
      end

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

  def viewWillAppear(animated)
    super
    ## 応急処置
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleBlackOpaque
    UIApplication.sharedApplication.setStatusBarHidden(false, animated:false)
    self.wantsFullScreenLayout = false

    @bookmarkView.tap do |v|
      v.frame = self.view.bounds
      v.bookmark = self.bookmark
      v.starView.highlighted = false
      v.starView.backgroundColor = UIColor.whiteColor
    end
  end
end
