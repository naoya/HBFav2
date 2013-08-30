# -*- coding: utf-8 -*-
class BookmarkViewController < UIViewController
  attr_accessor :bookmark, :url, :short_url, :user_name, :on_modal

  def viewDidLoad
    super

    self.navigationItem.title = "ブックマーク"
    self.view.backgroundColor = UIColor.whiteColor
    self.backGestureEnabled = true
    self.navigationItem.backBarButtonItem = UIBarButtonItem.titled("戻る")
    self.configure_toolbar

    self.view << @bookmarkView = HBFav2::BookmarkView.new.tap do |v|
      v.frame = self.view.bounds
      v.backgroundColor = UIColor.whiteColor
      v.headerView.addGestureRecognizer(UITapGestureRecognizer.alloc.initWithTarget(self, action:'open_profile'))
      v.starView.addGestureRecognizer(UITapGestureRecognizer.alloc.initWithTarget(self, action:'open_stars'))
      v.titleButton.addTarget(self, action:'open_webview', forControlEvents:UIControlEventTouchUpInside)
      v.titleButton.addGestureRecognizer(UILongPressGestureRecognizer.alloc.initWithTarget(self, action:'on_action'))
      v.usersButton.addTarget(self, action:'open_bookmarks', forControlEvents:UIControlEventTouchUpInside)
      v.delegate = self
    end

    self.view << @indicator = UIActivityIndicatorView.gray

    ## clickable URL に悪影響を与えるので中止
    # self.view.addGestureRecognizer(UITapGestureRecognizer.alloc.initWithTarget(self, action:'toggle_toolbar'))

    if self.on_modal == true
      UIBarButtonItem.stop.tap do |btn|
        btn.action = 'on_close'
        btn.target = self
      end
      self.navigationItem.leftBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(
        UIBarButtonSystemItemStop,
        target:self,
        action:'on_close'
      )
    end
  end

  def open_profile
    controller = TimelineViewController.new.tap do |c|
      c.user  = bookmark.user
      c.content_type = :bookmark
      c.title = bookmark.user.name
    end
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

    self.navigationController.setToolbarHidden(false, animated:self.on_modal ? false : true)

    if self.bookmark.present?
      @bookmarkView.bookmark = self.bookmark
    elsif self.short_url and self.user_name
      @indicator.center = self.view.center
      @indicator.startAnimating

      ## FIXME: error handling
      GoogleAPI.sharedAPI.expand_url(self.short_url) do |response, long_url|
        if response.ok? and long_url
          BookmarkManager.sharedManager.get_bookmark(long_url, self.user_name) do |res, bm|
            @indicator.stopAnimating
            if bm
              self.bookmark = bm
              @bookmarkView.bookmark = bm
            else
              App.alert("ブックマークが見つかりません。時間をおいて再度試行してください")
            end
          end
        end
      end
    end

    @bookmarkView.tap do |v|
      v.starView.highlighted = false
      v.starView.backgroundColor = UIColor.whiteColor
    end
  end

  def toggle_toolbar
    if @toolbar_visible
      @toolbar_visible = false
      self.navigationController.setToolbarHidden(true, animated:true)
    else
      @toolbar_visible = true
      self.navigationController.setToolbarHidden(false, animated:true)
    end
  end

  def viewWillDisappear(animated)
    super
    self.navigationController.toolbar.translucent = false
  end

  def configure_toolbar
    spacer = UIBarButtonItem.fixedspace
    spacer.width = self.view.size.width - 110
    self.toolbarItems = [
      spacer,
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemCompose, target:self, action: 'on_bookmark'),
      UIBarButtonItem.flexiblespace,
      # BookmarkBarButtonItem.alloc.initWithTarget(self, action:'on_bookmark'),
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemAction, target:self, action:'on_action'),
    ]
  end

  def on_bookmark
    open_hatena_bookmark_view
  end

  def open_hatena_bookmark_view
    controller = HTBHatenaBookmarkViewController.alloc.init
    controller.URL = @bookmark.link.nsurl
    self.presentViewController(controller, animated:true, completion:nil)
  end

  def on_action
    controller = URLActivityViewController.alloc.initWithDefaultActivities([ @bookmark.title, @bookmark.link.nsurl ])
    self.presentViewController(controller, animated:true, completion:nil)
  end

  def attributedLabel(label, didSelectLinkWithURL:url)
    if url.scheme == 'bookmark'
      name = url.host

      controller = TimelineViewController.new.tap do |c|
        user = User.new({ :name => name })
        c.user  = user
        c.content_type = :bookmark
        c.title = user.name
      end
      return self.navigationController.pushViewController(controller, animated:true)
    end

    if url.scheme == 'twitter'
      name = url.host
      link = "http://twitter.com/#{name}"
    else
      link = url.absoluteString
    end

    bookmark = Bookmark.new(
      {
        :title => '',
        :link  => link,
        :count => nil
      }
    )
    controller = WebViewController.new
    controller.bookmark = bookmark
    self.navigationController.pushViewController(controller, animated:true)
  end

  def on_close
    self.dismissModalViewControllerAnimated(true, completion:nil)
  end

  def dealloc
    NSLog("dealloc: " + self.class.name)
    super
  end
end
