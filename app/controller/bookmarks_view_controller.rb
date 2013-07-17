# -*- coding: utf-8 -*-
class BookmarksViewController < UITableViewController
  attr_accessor :entry
  include SugarCube::Modal

  def viewDidLoad
    super
    @bookmarks = []

    self.navigationItem.title = entry.count.to_s
    self.navigationItem.leftBarButtonItem  = UIBarButtonItem.titled('閉じる') { dismiss_modal }
    view.backgroundColor = UIColor.whiteColor

    @indicator = UIActivityIndicatorView.new.tap do |v|
      v.center = [view.frame.size.width / 2, view.frame.size.height / 2 - 42]
      v.style = UIActivityIndicatorViewStyleGray
      v.startAnimating
    end
    view << @indicator

    loadBookmarks()
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
    end
  end

  def viewWillAppear(animated)
    view.deselectRowAtIndexPath(view.indexPathForSelectedRow, animated:animated)
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
