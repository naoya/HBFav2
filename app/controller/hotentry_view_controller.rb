# -*- coding: utf-8 -*-
class HotentryViewController < HBFav2::UITableViewController
  attr_accessor :category, :list_type
  include HBFav2::ApplicationSwitchNotification

  def viewDidLoad
    super
    @bookmarks = []

    self.navigationItem.backBarButtonItem = UIBarButtonItem.titled("戻る")
    self.view.backgroundColor = UIColor.whiteColor
    self.tracked_view_name = list_type == :hotentry ? "Hotentry" : "Entrylist"

    self.navigationItem.titleView = TitleLabel.new.tap do |label|
      label.frame = [[0, 0], [view.frame.size.width, 44]]
    end

    ## Pull to Refresh
    self.refreshControl = HBFav2::RefreshControl.new.tap do |refresh|
      refresh.update_title("フィード取得中...")
      refresh.backgroundColor = '#e2e7ed'.uicolor
      refresh.addTarget(self, action:'on_refresh', forControlEvents:UIControlEventValueChanged)
    end

    load_hotentry

    self.tableView.addGestureRecognizer(
      UILongPressGestureRecognizer.alloc.initWithTarget(self, action:'on_long_press_row:')
    )
  end

  def on_long_press_row(recog)
    if recog.state == UIGestureRecognizerStateBegan and
        indexPath = tableView.indexPathForRowAtPoint(recog.locationInView(tableView))
      bookmark = @bookmarks[indexPath.row]
      controller = WebViewController.new
      controller.bookmark = bookmark
      self.navigationController.pushViewController(controller, animated:true)
    end
  end

  def clear_entries
    @bookmarks = []
    self.tableView.reloadData
  end

  def load_hotentry
    self.refreshControl.beginRefreshing

    if self.list_type == :hotentry
      feed_url = 'http://feed.hbfav.com/hotentry'
    else
      feed_url = 'http://feed.hbfav.com/entrylist'
    end

    if not self.category.nil?
      feed_url += "?category=#{self.category}"
    end

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
    end
    @connection = query.connection
  end

  def viewWillAppear(animated)
    self.receive_application_switch_notifcation
    self.navigationController.setToolbarHidden(true, animated:animated)

    ## category selector
    label =  CategoryList.sharedCategories.key_to_label(self.category)
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.titled(label).tap do |btn|
      btn.target = self
      btn.action = 'open_category'
    end

    subtitle = CategoryList.sharedCategories.key_to_title(self.category)
    self.navigationItem.titleView.text = list_type == :hotentry ? "人気エントリー" : "新着エントリー"

    indexPath = tableView.indexPathForSelectedRow
    tableView.reloadData
    tableView.selectRowAtIndexPath(indexPath, animated:animated, scrollPosition:UITableViewScrollPositionNone);
    tableView.deselectRowAtIndexPath(indexPath, animated:animated);
    super
  end

  def viewWillDisappear(animated)
    super
    self.unreceive_application_switch_notification
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
      HotentryCell.heightForBookmark(@bookmarks[indexPath.row], tableView.frame.size.width)
    else
      HotentryCell.heightForBookmarkNoThumbnail(@bookmarks[indexPath.row], tableView.frame.size.width)
    end
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
    self.tableView.reloadData
  end

  def dealloc
    NSLog("dealloc: " + self.class.name)
    super
  end
end
