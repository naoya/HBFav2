# -*- coding: utf-8 -*-
class TimelineViewController < UITableViewController
  attr_accessor :user, :feed_url, :as_home

  def viewDidLoad
    super

    self.navigationItem.title = "HBFav"
    self.view.backgroundColor = UIColor.whiteColor

    @bookmarks = []

    if home?
      self.navigationItem.rightBarButtonItem =
        UIBarButtonItem.alloc.initWithBarButtonSystemItem(
        UIBarButtonSystemItemBookmarks,
        target:self,
        action:'openProfile'
        )
    end

    BW::HTTP.get(@feed_url) do |response|
      if response.ok?
        json = BW::JSON.parse(response.body.to_str)
        json['bookmarks'].each { |dict| @bookmarks << Bookmark.new(dict) }
        view.reloadData
      else
        App.alert(response.error_message)
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
    bookmark.row = indexPath.row # FIXME: モデルに row 持たせるのおかしい
    cell = BookmarkCell.cellForBookmark(bookmark, inTableView:tableView)
    return cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    WebViewController.new.tap do |c|
      c.bookmark = @bookmarks[indexPath.row]
      self.navigationController.pushViewController(c, animated:true)
    end
  end

  def openProfile
    ProfileViewController.new.tap do |c|
      c.user = @user
      self.navigationController.pushViewController(c, animated:true)
    end
  end

  def home?
    as_home ? true : false
  end
end
