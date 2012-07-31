# -*- coding: utf-8 -*-
class BookmarksViewController < UIViewController
  attr_accessor :entry

  def viewDidLoad
    super
    @bookmarks = []

    self.navigationItem.title = entry.count.to_s

    @headerView = UIView.new.tap do |v|
      v.frame = [[0, 0], [view.frame.size.width, 68]]
      v.backgroundColor = UIColor.groupTableViewBackgroundColor
      view << v

      v.whenTapped do
        WebViewController.new.tap do |c|
          c.bookmark = @entry
          navigationController.pushViewController(c, animated:true)
        end
      end
    end

    @faviconView = UIImageView.new.tap do |v|
      v.frame = [[5, 5 + 2], [14, 14]]
      v.image = entry.favicon
      @headerView << v
    end

    @titleLabel = UILabel.new.tap do |v|
      constrain = CGSize.new(view.frame.size.width - 19 - 10, 68)
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
      v.frame = [[0, 69], self.view.bounds.size]
      v.dataSource = v.delegate = self
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

  def tableView(tableView, numberOfRowsInSection:section)
    return @bookmarks.size
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    bookmark = @bookmarks[indexPath.row]
    bookmark.row = indexPath.row # FIXME: モデルに row 持たせるのおかしい

    # cell = BookmarkCell.cellForBookmark(bookmark, inTableView:tableView)

    ## とりあえず.
    cell = tableView.dequeueReusableCellWithIdentifier('commentCell') ||
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:'commentCell')
    cell.textLabel.text = bookmark.comment
    cell
  end
end
