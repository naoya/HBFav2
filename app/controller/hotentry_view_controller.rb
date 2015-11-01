# -*- coding: utf-8 -*-
class HotentryViewController < HBFav2::UITableViewController
  attr_accessor :category, :list_type
  include HBFav2::ApplicationSwitchNotification

  def viewDidLoad
    super
    @bookmarks = []

    self.view.backgroundColor = UIColor.whiteColor
    self.tracked_view_name = list_type == :hotentry ? "Hotentry" : "Entrylist"

    ## Pull to Refresh
    self.refreshControl = HBFav2::RefreshControl.new.tap do |refresh|
      refresh.update_title("フィード取得中...")
      refresh.addTarget(self, action:'on_refresh', forControlEvents:UIControlEventValueChanged)
    end

    view << @indicator = UIActivityIndicatorView.new.tap do |v|
      v.style = UIActivityIndicatorViewStyleGray
    end

    load_hotentry

    self.tableView.addGestureRecognizer(
      UILongPressGestureRecognizer.alloc.initWithTarget(self, action:'on_long_press_row:')
    )
    self.tableView.addGestureRecognizer(
      ForceTouchGestureRecognizer.alloc.initWithTarget(self, action:'on_force_touched_row:')
    )
    self.receive_application_switch_notifcation
  end

  def open_webview_with_gesture(recog)
    if indexPath = tableView.indexPathForRowAtPoint(recog.locationInView(tableView))
      bookmark = @bookmarks[indexPath.row]
      controller = WebViewController.new
      controller.bookmark = bookmark
      self.navigationController.pushViewController(controller, animated:true)
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

  def clear_entries
    @bookmarks = []
    self.tableView.reloadData
  end

  def load_hotentry(&block)
    @indicator.startAnimating
    if self.list_type == :hotentry
      feed_url = 'http://feed.hbfav.com/hotentry'
    else
      feed_url = 'http://feed.hbfav.com/entrylist'
    end

    if not self.category.nil?
      feed_url += "?category=#{self.category}"
    end

    NSLog(feed_url)

    query = BW::HTTP.get(feed_url) do |response|
      @connection = nil
      if response.ok?
        data = BW::JSON.parse(response.body.to_str)
        @bookmarks = data['bookmarks'].map do |dict|
          dict[:comment] = ''
          Bookmark.new(dict)
        end
        self.refreshControl.update_title
      else
        self.refreshControl.update_title(response.error_message)
      end
      tableView.reloadData
      self.refreshControl.endRefreshing
      @indicator.stopAnimating

      block.call(response) if block
    end
    @connection = query.connection
  end

  def viewWillAppear(animated)
    self.navigationController.setToolbarHidden(true, animated:animated)
    @indicator.center = [ view.center.x, view.center.y - 42]

    ## category selector
    label =  CategoryList.sharedCategories.key_to_label(self.category)
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.titled(label).tap do |btn|
      btn.target = self
      btn.action = 'open_category'
    end

    subtitle = CategoryList.sharedCategories.key_to_title(self.category)
    self.title = list_type == :hotentry ? "人気エントリー" : "新着エントリー"

    indexPath = tableView.indexPathForSelectedRow
    tableView.reloadData
    tableView.selectRowAtIndexPath(indexPath, animated:animated, scrollPosition:UITableViewScrollPositionNone);
    tableView.deselectRowAtIndexPath(indexPath, animated:animated);
    super
  end

  def viewWillDisappear(animated)
    super
    if @connection.present?
      @connection.cancel
      App.shared.networkActivityIndicatorVisible = false
    end
  end

  def tableView(tableView, numberOfRowsInSection:section)
    return @bookmarks.size
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    bookmark = @bookmarks[indexPath.row]
    if bookmark.thumbnail_url.present?
      height = HotentryCell.heightForBookmark(@bookmarks[indexPath.row], tableView.frame.size.width)
    else
      height = HotentryCell.heightForBookmarkNoThumbnail(@bookmarks[indexPath.row], tableView.frame.size.width)
    end
    return height.ceil
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    HotentryCell.cellForBookmark(@bookmarks[indexPath.row], inTableView:tableView)
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    WebViewController.new.tap do |c|
      c.bookmark = @bookmarks[indexPath.row]
      self.navigationController.pushViewController(c, animated:true)
    end
  end

  def on_refresh
    load_hotentry
  end

  def open_category
    controller = CategoryViewController.alloc.initWithStyle(UITableViewStyleGrouped)
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal
    controller.current_category = self.category
    controller.hotentry_controller = self

    self.presentViewController(
      UINavigationController.alloc.initWithRootViewController(controller),
      animated:true,
      completion:nil
    )
  end

  def applicationWillEnterForeground
    load_hotentry
    self.view.reloadDataWithKeepingSelectedRowAnimated(true)
  end

  # def performBackgroundFetchWithCompletion(completionHandler)
  #   NSLog("###### Background Fetch : Update Hotentry ######")
  #   load_hotentry do |res|
  #     if res.ok?
  #       completionHandler.call(UIBackgroundFetchResultNewData)
  #     else
  #       completionHandler.call(UIBackgroundFetchResultFailed)
  #     end
  #   end
  # end

  def dealloc
    self.unreceive_application_switch_notification
    NSLog("dealloc: " + self.class.name)
    super
  end
end
