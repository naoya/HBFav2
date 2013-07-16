# -*- coding: utf-8 -*-
class BookmarksViewController < UIViewController
  attr_accessor :entry

  def viewDidLoad
    super
    @bookmarks = []

    self.navigationItem.title = entry.count.to_s
    view.backgroundColor = UIColor.whiteColor

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

    @headerView << UIImageView.new.tap do |v|
      v.image = UIImage.imageNamed('disc2.png')
      w = @headerView.bounds.size.width
      h = @headerView.bounds.size.height
      v.frame = [[w - 20, (h / 2) - 8], [12, 17]]
    end

    @faviconView = UIImageView.new.tap do |v|
      v.frame = [[5, 5 + 2], [14, 14]]
      v.image = entry.favicon
      v.setImageWithURL(entry.favicon_url.nsurl, placeholderImage:nil)
      @headerView << v
    end

    @titleLabel = UILabel.new.tap do |v|
      constrain = CGSize.new(view.frame.size.width - 19 - 10 - 18, 68 - 10) # 18 ... disc.png の分の幅
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
      # view << v
    end

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
        unless @bookmarksTable.nil?
          @bookmarksTable.reloadData
        end
      else
        App.alert(response.error_message)
      end
      @indicator.stopAnimating
      view << @bookmarksTable
    end
  end

  def viewWillAppear(animated)
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
