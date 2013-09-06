# -*- coding: utf-8 -*-
class BookmarksViewController < UITableViewController
  attr_accessor :entry
  include HBFav2::ApplicationSwitchNotification

  def viewDidLoad
    super

    @bookmarks = BookmarksManager.new(entry.link)

    self.navigationItem.title = entry.count.to_s
    view.backgroundColor = UIColor.whiteColor

    ## Set RefreshControl background (work around)
    frame = self.tableView.bounds
    frame.origin.y = -frame.size.height
    bgview = UIView.alloc.initWithFrame(frame)
    bgview.backgroundColor = '#e2e7ed'.uicolor
    self.tableView.insertSubview(bgview, atIndex: 0)

    @indicator = UIActivityIndicatorView.new.tap do |v|
      v.style = UIActivityIndicatorViewStyleGray
      v.startAnimating
    end
    view << @indicator

    Dispatch::Queue.concurrent.async do
      response = @bookmarks.sync!

      Dispatch::Queue.main.sync do
        if not response.ok?
          App.alert(response.message)
        elsif @bookmarks.all.size == 0
          App.alert("ブックマークが全てプライベートモード、もしくはコメント非表示設定のエントリーです")
        end

        view.reloadData
        @indicator.stopAnimating

        ## Show "scrolls to bottom" button
        if (tableView.contentSize.height > tableView.frame.size.height)
          button = UIBarButtonItem.titled("下へ").tap do |btn|
            btn.action = "on_navigate"
            btn.target = self
          end
          self.navigationItem.setRightBarButtonItem(button, animated:true)
        end
      end
    end
  end

  def viewWillAppear(animated)
    self.receive_application_switch_notifcation
    indexPath = tableView.indexPathForSelectedRow
    tableView.reloadData
    tableView.selectRowAtIndexPath(indexPath, animated:animated, scrollPosition:UITableViewScrollPositionNone);
    tableView.deselectRowAtIndexPath(indexPath, animated:animated);
    self.navigationController.setToolbarHidden(true, animated:animated)
    @indicator.center = [view.frame.size.width / 2, view.frame.size.height / 2 - 21]
    self.navigationItem.leftBarButtonItem  = UIBarButtonItem.stop.tap do |btn|
      btn.action = 'on_close'
      btn.target = self
    end
    super
  end

  def viewWillDisappear(animated)
    super
    self.unreceive_application_switch_notification
  end

  def numberOfSectionsInTableView(tableView)
    if @bookmarks.has_popular_bookmarks?
      2
    else
      1
    end
  end

  def bookmarks (section)
    if @bookmarks.has_popular_bookmarks? and section == 0
      @bookmarks.popular
    else
      @bookmarks.all
    end
  end

  def tableView(tableView, numberOfRowsInSection:section)
    if @bookmarks.has_popular_bookmarks? and section == 0
      return @bookmarks.popular.size
    else
      return @bookmarks.all.size
    end
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    BookmarkFastCell.heightForBookmark(bookmarks(indexPath.section)[indexPath.row], tableView.frame.size.width, true)
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    BookmarkFastCell.cellForBookmarkNoTitle(bookmarks(indexPath.section)[indexPath.row], inTableView:tableView)
  end

  def tableView(tableView, titleForHeaderInSection:section)
    if @bookmarks.has_popular_bookmarks?
      section == 0 ? "人気" : "すべて"
    else
      nil
    end
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    open_bookmark(bookmarks(indexPath.section)[indexPath.row])
  end

  def open_bookmark (bookmark)
    BookmarkViewController.new.tap do |c|
      c.bookmark = bookmark
      self.navigationController.pushViewController(c, animated:true)
    end
  end

  def on_navigate
    offset = CGPointMake(0, tableView.contentSize.height - tableView.frame.size.height)
    self.tableView.setContentOffset(offset, animated:true)
  end

  def on_close
    self.dismissViewControllerAnimated(true, completion:nil)
  end

  def applicationWillEnterForeground
    self.tableView.reloadData
  end

  def dealloc
    NSLog("dealloc: " + self.class.name)
    super
  end
end
