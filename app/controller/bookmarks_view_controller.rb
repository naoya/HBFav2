# -*- coding: utf-8 -*-
class BookmarksViewController < UITableViewController
  attr_accessor :entry
  include HBFav2::ApplicationSwitchNotification

  def viewDidLoad
    super
    @bookmarks = []

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

    loadBookmarks
  end

  def loadBookmarks
    query = BW::HTTP.get("http://b.hatena.ne.jp/entry/jsonlite/", {payload: {url: entry.link}}) do |response|
      @connection = nil

      if response.ok?
        autorelease_pool {
          json = BW::JSON.parse(response.body.to_str)
          if json and json['bookmarks'].present?
            @bookmarks = json['bookmarks'].collect do |dict|
              Bookmark.new(
                {
                  :title => entry.title,
                  :link  => entry.link,
                  :count => entry.count.to_s,
                  :eid   => json['eid'],
                  :user => {
                    :name => dict[:user]
                  },
                  :comment => dict[:comment],
                  :created_at => dict[:timestamp],
                  # 2005/02/10 20:55:55 => 2005-02-10T20:55:55+09:00
                  :datetime =>  dict[:timestamp].gsub(/\//, '-').gsub(/ /, 'T') + '+09:00'
                }
              )
            end
          else
            App.alert("ブックマークが全てプライベートモード、もしくはコメント非表示設定のエントリーです")
          end
        }
        view.reloadData
      else
        App.alert("通信エラー: " + response.status_code.to_s)
      end
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
    @connection = query.connection
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
    if @connection.present?
      @connection.cancel
      App.shared.networkActivityIndicatorVisible = false
    end
  end

  def tableView(tableView, numberOfRowsInSection:section)
    return @bookmarks.size
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    ## FIXME: ここの引数最後のわかりづらい
    BookmarkFastCell.heightForBookmark(@bookmarks[indexPath.row], tableView.frame.size.width, true)
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    bookmark = @bookmarks[indexPath.row]
    BookmarkFastCell.cellForBookmarkNoTitle(bookmark, inTableView:tableView)
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    BookmarkViewController.new.tap do |c|
      c.bookmark = @bookmarks[indexPath.row]
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
