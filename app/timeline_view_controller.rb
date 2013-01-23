# -*- coding: utf-8 -*-
class TimelineViewController < UITableViewController
  attr_accessor :user, :feed_url, :as_home

  def viewDidLoad
    super

    self.navigationItem.title = "HBFav"
    self.view.backgroundColor = UIColor.whiteColor

    @pullToRefreshView = SSPullToRefreshView.alloc.initWithScrollView(tableView, delegate:self)

    ## 生の配列ではなく bookmarksManager とかになるべきな気が
    ## インスタンスは feed の URL を受け取る
    ## (/naoya/ とかも同じように処理できるようにするため)
    @bookmarks ||= []

    # こういうフラグ要るのかな...
    @loading = nil

    if home?
      self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(
        UIBarButtonSystemItemBookmarks,
        target:self,
        action:'openProfile'
      )
    end

    tableView.tableFooterView = UIView.new.tap do |v|
      v.frame = [[0, 0], [tableView.frame.size.width, 44]]
      v.backgroundColor = '#fff'.uicolor
      v << UIActivityIndicatorView.gray.tap do |i|
        i.center = [v.frame.size.width / 2, v.frame.size.height / 2]
        i.startAnimating
      end
    end

    self.updateBookmarks
    # # FIXME: 通信を発生させながら NavigationController で行き来してると高確率で落ちる･･･
    # BW::HTTP.get(@feed_url) do |response|
    #   if response.ok?
    #     json = BW::JSON.parse(response.body.to_str)
    #     @bookmarks = json['bookmarks'].collect { |dict| Bookmark.new(dict) }
    #     @last
    #     ## すでにviewが破棄されてる時がある(通信中にpopViewした場合など)ので nil チェック
    #     unless self.view.nil?
    #       self.view.reloadData
    #     end
    #   else
    #     App.alert(response.error_message)
    #   end
    # end

    # Dispatch::Queue.concurrent.async do
    #   json = nil
    #   begin
    #     json = JSONParser.parse_from_url(@feed_url)
    #   rescue RuntimeError => e
    #     presentError e.message
    #   end

    #   @bookmarks = json['bookmarks'].collect { |dict| Bookmark.new(dict) }

    #   Dispatch::Queue.main.sync do
    #     ## すでにviewが破棄されてる時がある(通信中にpopViewした場合など)ので nil チェック
    #     unless self.view.nil?
    #       self.view.reloadData
    #     end
    #   end
    # end
  end

  def viewDidUnload
    super
    @pullToRefreshView = nil
  end

  def pullToRefreshViewDidStartLoading(pullToRefreshView)
    pullToRefreshView.startLoading
    self.updateBookmarks(true) do
      pullToRefreshView.finishLoading
    end
  end

  ## これは bookmarksManager とかのクラスに生えてて、
  ## bookmarksManager.update で通知を受け取って view.reloadData するべ
  ## き箇所では?
  def updateBookmarks(init=nil, &cb)
    @loading = true
    offset = init ? 0 : @bookmarks.size
    url = @feed_url + "?of=#{offset}"

    # debug
    puts url

    BW::HTTP.get(url) do |response|
      if response.ok?
        json = BW::JSON.parse(response.body.to_str)
        if (init)
          @bookmarks = []
        end
        @bookmarks.concat(json['bookmarks'].collect { |dict| Bookmark.new(dict) })
        unless self.view.nil?
          self.view.reloadData
        end
      else
        App.alert(response.error_message)
      end

      if (cb)
        cb.call
      end

      @loading = nil
    end
  end

  def tableView(tableView, willDisplayCell:cell, forRowAtIndexPath:indexPath)
    if (@loading.nil? and @bookmarks.size > 0 and indexPath.row == @bookmarks.size - 1)
      self.updateBookmarks
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
    PermalinkViewController.new.tap do |c|
      c.bookmark = @bookmarks[indexPath.row]
      self.navigationController.pushViewController(c, animated:true)
    end
  end

  def openProfile
    ProfileViewController.new.tap do |c|
      c.user    = @user
      c.as_mine = true
      self.navigationController.pushViewController(c, animated:true)
    end
  end

  def home?
    as_home ? true : false
  end
end
