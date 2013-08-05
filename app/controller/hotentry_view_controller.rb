# -*- coding: utf-8 -*-
class HotentryViewController < UITableViewController
  attr_accessor :category, :list_type

  def viewDidLoad
    @bookmarks = []

    self.navigationItem.backBarButtonItem = UIBarButtonItem.titled("戻る")
    self.view.backgroundColor = UIColor.whiteColor

    self.navigationItem.titleView = TitleLabel.new.tap do |label|
      label.frame = [[0, 0], [view.frame.size.width, 44]]
    end

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
    load_hotentry
  end

  def clear_entries
    @bookmarks = []
    self.tableView.reloadData
  end

  def load_hotentry
    self.refreshControl.beginRefreshing

    if self.list_type == :hotentry
      feed_url = 'http://hbfav.herokuapp.com/hotentry'
    else
      feed_url = 'http://hbfav.herokuapp.com/entrylist'
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
    self.navigationController.setToolbarHidden(true, animated:animated)

    ## category selector
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.titled("カテゴリ").tap do |btn|
      btn.target = self
      btn.action = 'open_category'
    end

    ## JASlidePanels の初期化タイミングでボタンスタイルが当たらないので明示的にセット
    if self.navigationItem.leftBarButtonItem
      self.navigationItem.leftBarButtonItem.styleClass = 'navigation-button'
    end

    subtitle = CategoryList.sharedCategories.key_to_title(self.category)
    self.navigationItem.titleView.text = list_type == :hotentry ? "人気: #{subtitle}" : "新着: #{subtitle}"

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

  def dealloc
    NSLog("dealloc: " + self.class.name)
    super
  end
end
