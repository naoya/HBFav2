# -*- coding: utf-8 -*-
class BookmarksViewController < UITableViewController
  attr_accessor :entry

  def viewDidLoad
    super
    @bookmarks = []

    self.navigationItem.title = entry.count.to_s
    view.backgroundColor = UIColor.whiteColor

    ## Pull to Refresh
    self.refreshControl = UIRefreshControl.new.tap do |refresh|
      refresh.backgroundColor = '#e2e7ed'.uicolor
      refresh.on(:value_changed) do |event|
        refresh.beginRefreshing
        loadBookmarks
      end
    end

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
    BW::HTTP.get("http://b.hatena.ne.jp/entry/jsonlite/", {payload: {url: entry.link}}) do |response|
      if response.ok?
        json = BW::JSON.parse(response.body.to_str)
        ## FIXME: refactor with manager
        if json['bookmarks'].present?
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
        view.reloadData
      else
        App.alert(response.error_message)
      end
      @indicator.stopAnimating
      self.refreshControl.endRefreshing
      ## Show "scrolls to bottom" button
      if (tableView.contentSize.height > tableView.frame.size.height)
        button = UIBarButtonItem.titled("下へ") do
          offset = CGPointMake(0, tableView.contentSize.height - tableView.frame.size.height)
          tableView.setContentOffset(offset, animated:true)
        end
        self.navigationItem.setRightBarButtonItem(button, animated:true)
      end
    end
  end

  def viewWillAppear(animated)
    @indicator.center = [view.frame.size.width / 2, view.frame.size.height / 2]

    self.navigationItem.leftBarButtonItem  =
      UIBarButtonItem.stop { self.dismissViewControllerAnimated(true, completion:nil) }
    super
  end

  def viewDidAppear(animated)
    super
  end

  def tableView(tableView, numberOfRowsInSection:section)
    return @bookmarks.size
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    ## FIXME: ここの引数最後のわかりづらい
    BookmarkCell.heightForBookmark(@bookmarks[indexPath.row], tableView.frame.size.width, true)
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    bookmark = @bookmarks[indexPath.row]
    BookmarkCell.cellForBookmarkNoTitle(bookmark, inTableView:tableView)
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    PermalinkViewController.new.tap do |c|
      c.bookmark = @bookmarks[indexPath.row]
      self.navigationController.pushViewController(c, animated:true)
    end
  end
end
