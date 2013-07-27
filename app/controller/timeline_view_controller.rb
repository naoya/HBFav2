# -*- coding: utf-8 -*-
class TimelineViewController < UITableViewController
  attr_accessor :user, :feed_url, :as_home
  # include Motion::Pixate::Observer

  def viewDidLoad
    super

    ## for Pixate development
    # startObserving
    # App.alert(user.use_timeline? ? "true" : "false")

    ApplicationUser.sharedUser.addObserver(self, forKeyPath:'hatena_id', options:0, context:nil)
    @bookmarks = BookmarkManager.new(self.feed_url)
    @bookmarks.addObserver(self, forKeyPath:'bookmarks', options:0, context:nil)
    if (user and user.use_timeline?)
      @bookmarks.paging_method = 'until'
    end

    self.navigationItem.title ||= "HBFav"
    self.navigationItem.backBarButtonItem = UIBarButtonItem.titled("戻る")
    self.view.backgroundColor = UIColor.whiteColor

    ## Navigation back button
    # self.navigationItem.leftBarButtonItem = UIBarButtonItem.alloc.initWithCustomView(
    #   UIButton.custom.tap do |btn|
    #     btn.frame = [[0, 0], [24, 24]]
    #     btn.setImage("arrow".uiimage, forState: :normal.uicontrolstate)
    #     btn.on(:touch) do
    #       self.navigationController.popViewControllerAnimated(true)
    #     end
    #   end
    # )
    # self.navigationItem.hidesBackButton = true

    ## Loading indicator for Paging
    tableView.tableFooterView = UIView.new.tap do |v|
      v.frame = [[0, 0], [tableView.frame.size.width, 44]]
      v.backgroundColor = '#fff'.uicolor
      v << @footer_indicator = UIActivityIndicatorView.gray
    end

    tableView.tableFooterView << @footerErrorView = TableFooterErorView.new.tap do |v|
      v.frame = tableView.tableFooterView.frame
      v.hide
      v.when_tapped do
        self.paginate
      end
    end

    ## Pull to Refresh
    self.refreshControl = HBFav2::RefreshControl.new.tap do |refresh|
      refresh.update_title("フィード取得中...")
      refresh.backgroundColor = '#e2e7ed'.uicolor
      refresh.on(:value_changed) do |event|
        refresh.update_title("フィード取得中...")
        refresh.beginRefreshing
        @bookmarks.update(true) do |res|
          if not res.ok?
            refresh.update_title(res.error_message)
          else
            refresh.update_title
            @footer_indicator.startAnimating
          end
          refresh.endRefreshing
        end
      end
    end

    ## Set RefreshControl background (work around)
    frame = self.tableView.bounds
    frame.origin.y = -frame.size.height
    bgview = UIView.alloc.initWithFrame(frame)
    bgview.backgroundColor = '#e2e7ed'.uicolor
    self.tableView.insertSubview(bgview, atIndex: 0)

    if home?
      btn = UIBarButtonItem.bookmarks { open_profile }
      btn.styleClass = 'navigation-button'
      self.navigationItem.rightBarButtonItem = btn
    end

    ## Activity Indicator for initial loading
    view << @indicator = UIActivityIndicatorView.gray.tap do |v|
      # v.startAnimating
    end

    if ApplicationUser.sharedUser.configured?
      ## Finally, fetch latest timeline feed
      initialize_bookmarks
    else
      AccountConfigViewController.new.tap do |c|
        c.allow_cancellation = false
        self.presentModalViewController(
          UINavigationController.alloc.initWithRootViewController(c),
          animated:true
        )
      end
    end
  end

  def initialize_bookmarks
    self.refreshControl.beginRefreshing
    @bookmarks.update(true) do |res|
      @indicator.stopAnimating
      self.refreshControl.endRefreshing
      if not res.ok?
        self.refreshControl.update_title(res.error_message)
      else
        self.refreshControl.update_title
        # tableView.reloadData ## 要らない模様
        if @bookmarks.size > 0
          @footer_indicator.startAnimating
        else
          if home?
            App.alert("表示するブックマークがありません。はてな上でお気に入りユーザーを追加してください")
          else
            App.alert("表示するブックマークがありません。")
          end
        end
      end
    end
  end

  def paginate
    if (not @bookmarks.updating?)
      @footerErrorView.hide
      @footer_indicator.startAnimating
      @bookmarks.update do |response|
        if not response.ok?
          puts 'error'
          @footerErrorView.show
        end
        @footer_indicator.stopAnimating
      end
    end
  end

  def dealloc
    @bookmarks.removeObserver(self, forKeyPath:'bookmarks')
    ApplicationUser.sharedUser.removeObserver(self, forKeyPath:'hatena_id')
  end

  def observeValueForKeyPath(keyPath, ofObject:object, change:change, context:context)
    if (@bookmarks == object and keyPath == 'bookmarks')
      view.reloadData
    end

    if (ApplicationUser.sharedUser == object and keyPath == 'hatena_id' and self.home?)
      self.user = ApplicationUser.sharedUser.to_bookmark_user
      self.feed_url = self.user.timeline_feed_url
      @bookmarks.url = self.feed_url
      initialize_bookmarks
    end
  end

  ## 末尾付近に来たら次のフィードを読み込む (paging)
  def tableView(tableView, willDisplayCell:cell, forRowAtIndexPath:indexPath)
    if (not @bookmarks.updating? and @bookmarks.size > 0 and indexPath.row >= @bookmarks.size - 5)
      self.paginate
    end
  end

  def viewWillAppear(animated)
    # NSNotificationCenter.defaultCenter.addObserver(self, selector: :'open_bookmark:', name:'title_touched', object:nil)

    ## 応急処置
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleBlackOpaque
    UIApplication.sharedApplication.setStatusBarHidden(false, animated:false)
    self.wantsFullScreenLayout = false

    indexPath = tableView.indexPathForSelectedRow
    tableView.reloadData
    tableView.selectRowAtIndexPath(indexPath, animated:animated, scrollPosition:UITableViewScrollPositionNone);
    tableView.deselectRowAtIndexPath(indexPath, animated:animated);

    @indicator.center = [view.frame.size.width / 2, view.frame.size.height / 2 - 21]
    @footer_indicator.center = [tableView.tableFooterView.frame.size.width / 2, tableView.tableFooterView.frame.size.height / 2]

    super
  end

  # def open_bookmark (notification)
  #   cell = notification.object
  #   WebViewController.new.tap do |c|
  #     c.bookmark = cell.bookmark
  #     navigationController.pushViewController(c, animated:true)
  #   end
  # end

  def viewDidAppear(animated)
    super
  end

  def tableView(tableView, numberOfRowsInSection:section)
    return @bookmarks.size
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    BookmarkFastCell.heightForBookmark(@bookmarks[indexPath.row], tableView.frame.size.width)
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    BookmarkFastCell.cellForBookmark(@bookmarks[indexPath.row], inTableView:tableView)
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    PermalinkViewController.new.tap do |c|
      c.bookmark = @bookmarks[indexPath.row]
      self.navigationController.pushViewController(c, animated:true)
    end
  end

  def open_profile
    ProfileViewController.new.tap do |c|
      c.user    = @user
      c.as_mine = true
      self.navigationController.pushViewController(c, animated:true)
    end
  end

  def home?
    as_home ? true : false
  end
end
