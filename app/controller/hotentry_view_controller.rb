# -*- coding: utf-8 -*-
class HotentryViewController < UITableViewController
  attr_accessor :feed_url

  def viewDidLoad
    @bookmarks = []

    self.navigationItem.backBarButtonItem = UIBarButtonItem.titled("戻る")
    self.view.backgroundColor = UIColor.whiteColor

    self.view << @indicator = UIActivityIndicatorView.gray.tap { |v| v.startAnimating }

    ## Pull to Refresh
    self.refreshControl = UIRefreshControl.new.tap do |refresh|
      refresh.backgroundColor = '#e2e7ed'.uicolor
      refresh.on(:value_changed) do |event|
        refresh.beginRefreshing
        load_hotentry
      end
    end

    ## Set RefreshControl background (work around)
    frame = self.tableView.bounds
    frame.origin.y = -frame.size.height
    bgview = UIView.alloc.initWithFrame(frame)
    bgview.backgroundColor = '#e2e7ed'.uicolor
    self.tableView.insertSubview(bgview, atIndex: 0)

    load_hotentry
  end

  def load_hotentry
    query = BW::HTTP.get(self.feed_url) do |response|
      @connection = nil

      if response.ok?
        data = BW::JSON.parse(response.body.to_str)
        @bookmarks = data['bookmarks'].map do |dict|
          # dict[:comment] = '"' + dict[:comment].truncate(60) + '"'
          dict[:comment] = ''
          Bookmark.new(dict)
        end
        view.reloadData
      else
        App.alert(response.error_message)
      end
      @indicator.stopAnimating
      self.refreshControl.endRefreshing
    end
    @connection = query.connection
  end

  def viewWillAppear(animated)
    super
    @indicator.center = [view.frame.size.width / 2, view.frame.size.height / 2 - 21]
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
    BookmarkCell.heightForBookmark(@bookmarks[indexPath.row], tableView.frame.size.width)
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    BookmarkCell.cellForBookmark(@bookmarks[indexPath.row], inTableView:tableView)
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    PermalinkViewController.new.tap do |c|
      c.bookmark = @bookmarks[indexPath.row]
      self.navigationController.pushViewController(c, animated:true)
    end
  end
end
