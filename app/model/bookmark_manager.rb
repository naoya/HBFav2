# -*- coding: utf-8 -*-
class BookmarkManager
  attr_accessor :url

  def self.factory(user)
    @bookmarks = if user and user.use_timeline?
                   BookmarkManager::TimeBased.new
                 else
                   BookmarkManager::Offset.new
                 end
    @bookmarks.url = user.timeline_feed_url
    @bookmarks
  end

  def initialize
    @url = url
    @bookmarks = []
    @updating = nil
  end

  def size
    return @bookmarks.size
  end

  def [] (i)
    return @bookmarks[i]
  end

  def add(bookmarks)
    @bookmarks.concat(bookmarks)
  end
  alias_method :<<, :add

  def clear
    @bookmarks.clear
  end

  def update(prepend = false, &cb)
    @updating = true

    url = prepend ? self.prepend_url : self.append_url

    # debug
    puts url

    BW::HTTP.get(url) do |response|
      if response.ok?
        autorelease_pool {
          json = BW::JSON.parse(response.body.to_str)
          bookmarks = json['bookmarks'].collect { |dict| Bookmark.new(dict) }
          self.willChangeValueForKey('bookmarks')
          prepend ? self.prepend(bookmarks) : self.append(bookmarks)
          self.didChangeValueForKey('bookmarks')
        }
      end
      @updating = false
      cb.call(response) if cb
    end
  end

  def updating?
    return @updating
  end

  def dealloc
    NSLog("dealloc: " + self.class.name)
    super
  end

  class TimeBased < BookmarkManager
    def prepend_url
      @url
    end

    def append_url
      epoch = @bookmarks.last.datetime.timeIntervalSince1970.to_i
      @url + "?until=#{epoch}"
    end

    def prepend(bookmarks)
      if @bookmarks.size > 0 and bookmarks.first.id == @bookmarks.first.id
        # 新着なし
        NSLog("No news")
      else
        bookmarks.concat(@bookmarks)
        @bookmarks = bookmarks.uniq { |b| b.id }
      end
    end

    def append(bookmarks)
      self << bookmarks
    end
  end

  class Offset < BookmarkManager
    def prepend_url
      @url
    end

    def append_url
      @url + "?of=#{self.size}"
    end

    def prepend(bookmarks)
      self.clear
      self.append(bookmarks)
    end

    def append(bookmarks)
      self << bookmarks
    end
  end
end
