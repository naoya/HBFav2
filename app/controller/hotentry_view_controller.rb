# -*- coding: utf-8 -*-
class HotentryViewController < UITableViewController
  attr_accessor :feed_url

  def viewDidLoad
    @bookmarks = []

    self.navigationItem.backBarButtonItem = UIBarButtonItem.titled("戻る")
    self.view.backgroundColor = UIColor.whiteColor

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

    self.refreshControl.beginRefreshing
    load_hotentry
  end

  def load_hotentry
    query = BW::HTTP.get(self.feed_url) do |response|
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

  def on_refresh
    self.refreshControl.beginRefreshing
    load_hotentry
  end

  def dealloc
    NSLog("dealloc: " + self.class.name)
    super
  end
end
