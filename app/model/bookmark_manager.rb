class BookmarkManager
  attr_accessor :bookmarks, :url, :paging_method

  def initialize(url)
    @url = url
    @bookmarks = []
    @updating = nil
    @paging_method = 'offset'
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

  def update(init = false, &cb)
    @updating = true

    ## offset or until
    url = @url
    if not init and self.size != 0
      if paging_method == 'until'
        epoch = @bookmarks.last.datetime.timeIntervalSince1970.to_i
        url += "?until=#{epoch}"
      else
        url += "?of=#{self.size}"
      end
    end

    # debug
    puts url

    BW::HTTP.get(url) do |res|
      if res.ok?
        autorelease_pool {
          json = BW::JSON.parse(res.body.to_str)
          self.clear if init

          self.willChangeValueForKey('bookmarks')
          self << json['bookmarks'].collect { |dict| Bookmark.new(dict) }
          self.didChangeValueForKey('bookmarks')
        }
      end
      @updating = false
      cb.call(res) if cb
    end
  end

  def updating?
    return @updating
  end

  def parse_args(d, a)
    return d.map { |k, v| a[k] or v }
  end
end
