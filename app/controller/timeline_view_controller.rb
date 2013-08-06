# -*- coding: utf-8 -*-
class TimelineViewController < UITableViewController
  attr_accessor :user, :as_home, :content_type
  # include Motion::Pixate::Observer

  DefaultTitle = "HBFav2"

  def registerObserver
    @observed = true
    ApplicationUser.sharedUser.addObserver(self, forKeyPath:'hatena_id', options:0, context:nil)
    @bookmarks.addObserver(self, forKeyPath:'bookmarks', options:0, context:nil)
  end

  def removeObserver
    if @observed
      @bookmarks.removeObserver(self, forKeyPath:'bookmarks')
      ApplicationUser.sharedUser.removeObserver(self, forKeyPath:'hatena_id')
      @observed = false
    end
  end

  def viewDidLoad
    super
    if (content_type == :bookmark)
      @bookmarks = BookmarkManager::Offset.new
      @bookmarks.url = user.bookmark_feed_url
    else
      @bookmarks = BookmarkManager.factory(user)
    end

    self.navigationItem.backBarButtonItem = UIBarButtonItem.titled("戻る")
    self.view.backgroundColor = UIColor.whiteColor
    self.initialize_footerview

    ## Pull to Refresh
    self.refreshControl = HBFav2::RefreshControl.new.tap do |refresh|
      refresh.update_title("フィード取得中...")
      refresh.backgroundColor = '#e2e7ed'.uicolor
      refresh.addTarget(self, action:'on_refresh', forControlEvents:UIControlEventValueChanged)
    end

    ## Set RefreshControl background (work around)
    frame = self.tableView.bounds
    frame.origin.y = -frame.size.height
    bgview = UIView.alloc.initWithFrame(frame)
    bgview.backgroundColor = '#e2e7ed'.uicolor
    self.tableView.insertSubview(bgview, atIndex: 0)

    if ApplicationUser.sharedUser.configured?
      ## Finally, fetch latest timeline feed
      initialize_bookmarks
    else
      open_account_config
    end

    self.registerObserver
  end

  def initialize_bookmarks
    self.refreshControl.beginRefreshing
    @bookmarks.update(true) do |res|
      self.refreshControl.endRefreshing
      if not res.ok?
        self.refreshControl.update_title(res.error_message)
      else
        self.refreshControl.update_title
        # tableView.reloadData ## 要らない模様 (observerで更新される)
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

  def initialize_footerview
    if @footerView.nil?
      @footerView = UIView.new.tap do |v|
        v.frame = [[0, 0], [tableView.frame.size.width, 44]]
        v.backgroundColor = '#fff'.uicolor
        v << @footer_indicator = UIActivityIndicatorView.gray
      end

      @footerView << @footerErrorView = TableFooterErorView.new.tap do |v|
        v.frame = @footerView.frame
        v.hide
        v.addGestureRecognizer(UITapGestureRecognizer.alloc.initWithTarget(self, action:'paginate'))
      end
    end
  end

  def paginate
    if (not @bookmarks.updating?)
      if tableView.tableFooterView.nil?
        tableView.tableFooterView = @footerView
      end
      @footerErrorView.hide
      @footer_indicator.startAnimating
      @bookmarks.update do |response|
        if not response.ok?
          @footerErrorView.show
        end
        @footer_indicator.stopAnimating
      end
    end
  end

  def observeValueForKeyPath(keyPath, ofObject:object, change:change, context:context)
    if (@bookmarks == object and keyPath == 'bookmarks')
      view.reloadData
    end

    if (ApplicationUser.sharedUser == object and keyPath == 'hatena_id' and self.home?)
      self.user = ApplicationUser.sharedUser.to_bookmark_user
      @bookmarks.removeObserver(self, forKeyPath:'bookmarks')
      @bookmarks = BookmarkManager.factory(self.user)
      @bookmarks.addObserver(self, forKeyPath:'bookmarks', options:0, context:nil)
      initialize_bookmarks
    end
  end

  ## 末尾付近に来たら次のフィードを読み込む (paging)
  def tableView(tableView, willDisplayCell:cell, forRowAtIndexPath:indexPath)
    if (not @bookmarks.updating? and @bookmarks.size > 0 and indexPath.row >= @bookmarks.size - 5)
      self.paginate
    end
  end

  def update_title
    if content_type == :bookmark
      self.navigationItem.title = self.user.name
    else
      self.navigationItem.title = DefaultTitle
    end
  end

  def viewWillAppear(animated)
    self.update_title

    ## JASlidePanels の初期化タイミングでボタンスタイルが当たらないので明示的にセット
    if self.navigationItem.leftBarButtonItem
      self.navigationItem.leftBarButtonItem.styleClass = 'navigation-button'
    end

    ## 応急処置
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleBlackOpaque
    UIApplication.sharedApplication.setStatusBarHidden(false, animated:false)
    self.wantsFullScreenLayout = false

    self.navigationController.setToolbarHidden(true, animated:animated)

    indexPath = tableView.indexPathForSelectedRow
    tableView.reloadData
    tableView.selectRowAtIndexPath(indexPath, animated:animated, scrollPosition:UITableViewScrollPositionNone);
    tableView.deselectRowAtIndexPath(indexPath, animated:animated);

    @footer_indicator.center = [@footerView.frame.size.width / 2, @footerView.frame.size.height / 2]

    super
  end

  def tableView(tableView, numberOfRowsInSection:section)
    return @bookmarks.size
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    bookmark = @bookmarks[indexPath.row]
    if bookmark.kind_of? Placeholder
      super
    else
      BookmarkFastCell.heightForBookmark(@bookmarks[indexPath.row], tableView.frame.size.width)
    end
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    bookmark = @bookmarks[indexPath.row]
    if bookmark.kind_of? Placeholder
      PlaceholderCell.cellForPlaceholder(bookmark, inTableView:tableView)
    else
      BookmarkFastCell.cellForBookmark(bookmark, inTableView:tableView)
    end
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    bookmark = @bookmarks[indexPath.row]
    if bookmark.kind_of? Placeholder
      cell = tableView.cellForRowAtIndexPath(indexPath)
      cell.beginRefreshing
      self.refreshControl.beginRefreshing
      @bookmarks.replace_placeholder(bookmark) do |response|
        self.refreshControl.endRefreshing
        cell.endRefreshing
      end
    else
      controller = PermalinkViewController.new.tap { |c| c.bookmark = @bookmarks[indexPath.row] }
      self.navigationController.pushViewController(controller, animated:true)
    end
  end

  def open_profile
    controller = ProfileViewController.new.tap do |c|
      c.user    = @user
      c.as_mine = true
    end
    self.navigationController.pushViewController(controller, animated:true)
  end

  def open_account_config
    controller = AccountConfigViewController.new.tap { |c| c.allow_cancellation = false }
    self.presentModalViewController(
      UINavigationController.alloc.initWithRootViewController(controller),
      animated:true
    )
  end

  def on_refresh
    self.refreshControl.update_title("フィード取得中...")
    self.refreshControl.beginRefreshing
    @bookmarks.update(true) do |res|
      if not res.ok?
        self.refreshControl.update_title(res.error_message)
      else
        self.refreshControl.update_title
        @footer_indicator.startAnimating
      end
      self.refreshControl.endRefreshing
    end
  end

  def home?
    as_home ? true : false
  end

  def dealloc
    self.removeObserver
    NSLog("dealloc: " + self.class.name)
    super
  end
end
