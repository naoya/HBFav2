# -*- coding: utf-8 -*-
class TimelineViewController < UITableViewController
  attr_accessor :user, :feed_url, :as_home

  def viewDidLoad
    super

    @bookmarks = BookmarkManager.new(self.feed_url)
    @bookmarks.addObserver(self, forKeyPath:'bookmarks', options:0, context:nil)

    self.navigationItem.title ||= "HBFav"
    self.view.backgroundColor = UIColor.whiteColor

    self.refreshControl = UIRefreshControl.new.tap do |refresh|
      # refresh.addTarget(self, action:'on_refresh', forControlEvents:UIControlEventValueChanged);
      refresh.on(:value_changed) do |event|
        refresh.beginRefreshing
        @bookmarks.update(true) do |res|
          if not res.ok?
            App.alert(res.error_message)
          end
          refresh.endRefreshing
        end
      end
    end

    if home?
      self.navigationItem.rightBarButtonItem = UIBarButtonItem.bookmarks { open_profile }
    end

    tableView.tableFooterView = UIView.new.tap do |v|
      v.frame = [[0, 0], [tableView.frame.size.width, 44]]
      v.backgroundColor = '#fff'.uicolor
      v << UIActivityIndicatorView.gray.tap do |i|
        i.center = [v.frame.size.width / 2, v.frame.size.height / 2]
        i.startAnimating
      end
    end

    @bookmarks.update do |res|
      if not res.ok?
        App.alert(res.error_message)
      end
    end
  end

  def viewDidUnload
    super
  end

  def dealloc
    @bookmarks.removeObserver(self, forKeyPath:'bookmarks')
  end

  def observeValueForKeyPath(keyPath, ofObject:object, change:change, context:context)
    if (@bookmarks == object and keyPath == 'bookmarks')
      view.reloadData
    end
  end

  def tableView(tableView, willDisplayCell:cell, forRowAtIndexPath:indexPath)
    if (not @bookmarks.updating? and @bookmarks.size > 0 and indexPath.row == @bookmarks.size - 1)
      @bookmarks.update do |res|
        if not res.ok?
          App.alert(res.error_message)
        end
      end
    end
  end

  def viewWillAppear(animated)
    super(animated)
    self.navigationController.toolbarHidden = true
    view.deselectRowAtIndexPath(view.indexPathForSelectedRow, animated:animated)
  end

  def tableView(tableView, numberOfRowsInSection:section)
    return @bookmarks.size
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    BookmarkCell.heightForBookmark(@bookmarks[indexPath.row], tableView.frame.size.width)
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    bookmark = @bookmarks[indexPath.row]
    cell = BookmarkCell.cellForBookmark(bookmark, inTableView:tableView)
    return cell
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
