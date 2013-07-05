# -*- coding: utf-8 -*-
class BookmarksViewController < UIViewController
  attr_accessor :entry

  def viewDidLoad
    super
    @bookmarks = []

    self.navigationItem.title = entry.count.to_s

    # @headerView = UIView.new.tap do |v|
    @headerView = UITableView.alloc.initWithFrame([[0, 0], [view.frame.size.width, 68]], style:UITableViewStyleGrouped).tap do |v|
      v.scrollsToTop = false
      view << v

      v.when_tapped do
        WebViewController.new.tap do |c|
          c.bookmark = @entry
          navigationController.pushViewController(c, animated:true)
        end
      end
    end

    @faviconView = UIImageView.new.tap do |v|
      v.frame = [[5, 5 + 2], [14, 14]]
      v.image = entry.favicon
      v.setImageWithURL(entry.favicon_url.nsurl, placeholderImage:nil)
      @headerView << v
    end

    @titleLabel = UILabel.new.tap do |v|
      constrain = CGSize.new(view.frame.size.width - 19 - 10, 68 - 10)
      size = entry.title.sizeWithFont(UIFont.boldSystemFontOfSize(13), constrainedToSize:constrain, lineBreakMode:UILineBreakModeCharacterWrap)
      v.frame = [[5 + 19, 5], size]
      v.numberOfLines = 0
      v.font = UIFont.boldSystemFontOfSize(13)
      v.text = entry.title
      v.backgroundColor = UIColor.clearColor

      @headerView << v
    end

    @border = UIView.new.tap do |v|
      v.frame = [[0, 68], [view.frame.size.width, 1]]
      v.backgroundColor = '#ababab'.uicolor
      view << v
    end

    @bookmarksTable = UITableView.new.tap do |v|
      frame_size = self.view.frame.size
      ## FIXME: frame.height が -69 だと見切れる。かといって200とかだと小さすぎる。なんで?
      ## navigation bar の分が入ってる? : yes
      v.frame = [[0, 69], [frame_size.width, frame_size.height - 69 - 42]]
      v.dataSource = v.delegate = self
      v.scrollsToTop = true
      view << v
    end

    loadBookmarks()
  end

  def loadBookmarks
    BW::HTTP.get("http://b.hatena.ne.jp/entry/jsonlite/?url=#{entry.link}") do |response|
      if response.ok?
        json = BW::JSON.parse(response.body.to_str)
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
              :created_at => dict[:timestamp]
            }
          )
        end
        unless @bookmarksTable.nil?
          @bookmarksTable.reloadData
        end
      else
        App.alert(response.error_message)
      end
    end
  end

  def viewWillAppear(animated)
    super
    self.navigationController.toolbarHidden = true
    @bookmarksTable.deselectRowAtIndexPath(@bookmarksTable.indexPathForSelectedRow, animated:animated)
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
