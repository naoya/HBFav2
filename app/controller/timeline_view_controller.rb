# -*- coding: utf-8 -*-
class TimelineViewController < HBFav2::UITableViewController
  attr_accessor :user, :content_type
  include HBFav2::ApplicationSwitchNotification
  include HBFav2::RemotePushNotificationEvent

  DefaultTitle = "HBFav"

  def viewDidLoad
    super
    self.prepare_to_load_bookmarks
    self.view.backgroundColor = UIColor.whiteColor
    self.tracked_view_name = content_type == :bookmark ? "UserBookmarks" : "Timeline"

    ## Pull to Refresh
    self.refreshControl = HBFav2::RefreshControl.new.tap do |refresh|
      refresh.update_title("フィード取得中...")
      refresh.addTarget(self, action:'on_refresh', forControlEvents:UIControlEventValueChanged)
    end

    view << @indicator = UIActivityIndicatorView.new.tap do |v|
      v.style = UIActivityIndicatorViewStyleGray
    end

    if ApplicationUser.sharedUser.configured?
      initialize_bookmarks
    else
      open_account_config
    end

    self.registerObserver
    self.tableView.addGestureRecognizer(
      UILongPressGestureRecognizer.alloc.initWithTarget(self, action:'on_long_press_row:')
    )
    self.tableView.addGestureRecognizer(
      ForceTouchGestureRecognizer.alloc.initWithTarget(self, action:'on_force_touched_row:')
    )
    self.receive_application_switch_notifcation
    self.receive_remote_push_notifcation_event
    self.start_periodic_update(120.0)
  end

  def open_webview_with_gesture(recog)
    if indexPath = tableView.indexPathForRowAtPoint(recog.locationInView(tableView))
      bookmark = @bookmarks[indexPath.row]
      unless bookmark.kind_of? Placeholder
        controller = WebViewController.new
        controller.bookmark = bookmark
        self.navigationController.pushViewController(controller, animated:true)
      end
    end
  end

  def on_long_press_row(recog)
    if recog.state == UIGestureRecognizerStateBegan
      open_webview_with_gesture(recog)
    end
  end

  def on_force_touched_row(recog)
    open_webview_with_gesture(recog)
  end

  def prepare_to_load_bookmarks
    if self.home? and content_type == :bookmark
      self.user = ApplicationUser.sharedUser.to_bookmark_user
    end

    @last_bookmarks_size = 0
    @bookmarks = self.initialize_feed_manager(self.user)
    self.initialize_footerview
  end

  def initialize_feed_manager(user)
    if (content_type == :bookmark)
      manager = FeedManager::Offset.new
      manager.url = user.bookmark_feed_url
    else
      manager = FeedManager.factory(user)
    end
    manager
  end

  def initialize_bookmarks
    # self.refreshControl.beginRefreshing
    @indicator.startAnimating
    @bookmarks.update(true) do |res|
      self.refreshControl.endRefreshing
      @indicator.stopAnimating
      if not res.ok?
        self.refreshControl.update_title(res.error_message)
      else
        self.refreshControl.update_title
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

  def observeValueForKeyPath(keyPath, ofObject:object, change:change, context:context)
    if (@bookmarks == object and keyPath == 'bookmarks')
      Dispatch::Queue.main.async {
        if  @bookmarks.timebased? and
            @bookmarks.prepended? and
            @last_bookmarks_size != 0 and
            @last_bookmarks_size != @bookmarks.size
          
          ## FIXME: 差分の割り出しは本当は change オブジェクトを使うべき
          size = @bookmarks.size - @last_bookmarks_size
          @last_bookmarks_size = @bookmarks.size
          self.tableView(view, reloadDataWithKeepingContentOffset:size)
        else
          view.reloadDataWithKeepingSelectedRowAnimated(true)
          @last_bookmarks_size = @bookmarks.size
        end
      }
    end

    if (ApplicationUser.sharedUser == object and keyPath == 'hatena_id' and self.home?)
      self.user = ApplicationUser.sharedUser.to_bookmark_user
      @bookmarks.removeObserver(self, forKeyPath:'bookmarks')
      @bookmarks = self.initialize_feed_manager(self.user)
      @bookmarks.addObserver(self, forKeyPath:'bookmarks', options:0, context:nil)
      initialize_bookmarks
    end
  end

  def tableView(tableView, reloadDataWithKeepingContentOffset:prependedRowSize)
    offset = tableView.contentOffset
    tableView.reloadData
    for i in (0..prependedRowSize - 1) do
      offset.y += self.tableView(
        tableView,
        heightForRowAtIndexPath:NSIndexPath.indexPathForRow(i, inSection:0)
      )
    end
    if offset.y > tableView.contentSize.height
      offset.y = 0
    end
    tableView.setContentOffset(offset)
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
    self.navigationController.setToolbarHidden(true, animated:true)
    tableView.reloadDataWithDeselectingRowAnimated(animated)
    @indicator.center = [ view.center.x, view.center.y - 42 ]
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
      height = BookmarkFastCell.heightForBookmark(@bookmarks[indexPath.row], tableView.frame.size.width)
      height.ceil
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
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
      end
    else
      controller = BookmarkViewController.new.tap { |c| c.bookmark = @bookmarks[indexPath.row] }
      self.navigationController.pushViewController(controller, animated:true)
    end
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

  def trigger_auto_update(&block)
    self.prepare_to_load_bookmarks if @bookmarks.nil?
    case content_type
    when :timeline then
      if self.home? and @bookmarks.timebased?
        _update_bookmarks(block)
      end
    when :bookmark then
      ## 自分のブックマークは timebased じゃないので保留
      # _update_bookmarks(block) if self.home?
    end
  end

  def _update_bookmarks(block)
    @bookmarks.update(true) do |res|
      if res.ok?
        self.refreshControl.update_title
      end
      block.call(res) if block
    end
  end

  def applicationWillEnterForeground
    self.trigger_auto_update
    ## 相対時刻更新
    self.view.reloadDataWithKeepingSelectedRowAnimated(true)
  end

  def applicationDidReceiveRemoteNotification(userInfo)
    self.trigger_auto_update
  end

  def start_periodic_update(interval = 120.0)
    EM.add_periodic_timer interval do
      self.trigger_auto_update
    end
  end

  def performBackgroundFetchWithCompletion(completionHandler)
    self.trigger_auto_update do |res|
      if res.ok?
        completionHandler.call(UIBackgroundFetchResultNewData)
      else
        completionHandler.call(UIBackgroundFetchResultFailed)
      end
    end
  end

  def dealloc
    self.removeObserver
    self.unreceive_application_switch_notification
    self.unreceive_remote_push_notification_event
    super
  end
end
