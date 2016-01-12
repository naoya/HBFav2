# -*- coding: utf-8 -*-
class BookmarksViewController < HBFav2::UITableViewController
  attr_accessor :entry
  include HBFav2::ApplicationSwitchNotification

  def viewDidLoad
    super

    @bookmarks = BookmarksManager.new(entry.link, {:hide_nocomment => ApplicationUser.sharedUser.hide_nocomment_bookmarks?})

    self.navigationItem.title = entry.count.to_s
    self.tracked_view_name = "EntryBookmarks"
    view.backgroundColor = UIColor.whiteColor

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
        elsif ApplicationUser.sharedUser.hide_nocomment_bookmarks? && @bookmarks.comments.size == 0
          App.alert("コメントがありません")
        elsif @bookmarks.all.size == 0
          App.alert("ブックマークが全てプライベートモード、もしくはコメント非表示設定のエントリーです")
        end

        if ApplicationUser.sharedUser.hide_nocomment_bookmarks?
          self.navigationItem.title = entry.count.to_s + " / " +
            Count.new(@bookmarks.comments.size).to_s("comment")
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
    @indicator.center = [ view.center.x, view.center.y - 42]
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
    if @bookmarks.has_popular_bookmarks? and @bookmarks.has_followers_bookmarks?
      return 3
    end

    if @bookmarks.has_popular_bookmarks? or @bookmarks.has_followers_bookmarks? 
      return 2
    end

    return 1
  end

  def bookmarks (section)
    if @bookmarks.has_popular_bookmarks? and @bookmarks.has_followers_bookmarks?
      return case section 
             when 0 then @bookmarks.popular
             when 1 then @bookmarks.followers
             when 2 then @bookmarks.items
             end
    end

    if @bookmarks.has_popular_bookmarks? then
      return case section
             when 0 then @bookmarks.popular
             when 1 then @bookmarks.items
             end
    end

    if @bookmarks.has_followers_bookmarks? then
      return case section
             when 0 then @bookmarks.followers
             when 1 then @bookmarks.items
             end
    end
    
    @bookmarks.items
  end

  def headerLabel(section)
    if @bookmarks.has_popular_bookmarks? and @bookmarks.has_followers_bookmarks?
      return case section 
             when 0 then "人気"
             when 1 then "フォロワー"
             when 2 then "すべて"
             end
    end

    if @bookmarks.has_popular_bookmarks? then
      return case section
             when 0 then "人気"
             when 1 then "すべて"
             end
    end

    if @bookmarks.has_followers_bookmarks? then
      return case section
             when 0 then "フォロワー"
             when 1 then "すべて"
             end
    end
    
    "すべて"
  end

  def tableView(tableView, numberOfRowsInSection:section)
    bookmarks(section).size
  end

  if UIDevice.currentDevice.ios7_or_later?
    def tableView(tableView, heightForHeaderInSection:section)
      if @bookmarks.has_popular_bookmarks? or @bookmarks.has_followers_bookmarks?
        SectionHeaderView.heightForHeader
      else
        0
      end
    end

    def tableView(tableView, viewForHeaderInSection:section)
      if UIDevice.currentDevice.ios7_or_later?
        SectionHeaderView.new.tap do |label|
          label.text = headerLabel(section)
        end
      end
    end
  end

  def tableView(tableView, titleForHeaderInSection:section)
    if @bookmarks.has_popular_bookmarks?
      headerLabel(section)
    else
      nil
    end
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    height = BookmarkFastCell.heightForBookmark(bookmarks(indexPath.section)[indexPath.row], tableView.frame.size.width, true)
    return height.ceil
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    BookmarkFastCell.cellForBookmarkNoTitle(bookmarks(indexPath.section)[indexPath.row], inTableView:tableView)
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
end
