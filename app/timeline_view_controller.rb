# -*- coding: utf-8 -*-
class TimelineViewController < UITableViewController
  def init
    self.navigationItem.title = "HBFav"
    self.view.backgroundColor = UIColor.whiteColor
    return self
  end

  def viewDidLoad
    super
    @bookmarks = []

    BW::HTTP.get('http://hbfav.herokuapp.com/naoya') do |response|
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
    wv = WebViewController.new
    wv.bookmark = @bookmarks[indexPath.row]
    self.navigationController.pushViewController(wv, animated:true)
  end
end
