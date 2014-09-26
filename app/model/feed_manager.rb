# -*- coding: utf-8 -*-
class FeedManager
  attr_accessor :url

  def self.factory(user)
    @bookmarks = if user and user.use_timeline?
                   FeedManager::TimeBased.new
                 else
                   FeedManager::Offset.new
                 end
    @bookmarks.url = user.timeline_feed_url
    @bookmarks
  end

  def initialize
    @url = nil
    @bookmarks = []
    @updating = nil
    @last_update_method = nil
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

    BW::HTTP.get(url, {timeout: 25.0}) do |response|
      Dispatch::Queue.concurrent.async {
        if response.ok?
          json = BW::JSON.parse(response.body.to_str)
          bookmarks = json['bookmarks'].collect { |dict| Bookmark.new(dict) }
          self.willChangeValueForKey('bookmarks')
          prepend ? self.prepend(bookmarks) : self.append(bookmarks)
          self.didChangeValueForKey('bookmarks')
        else
          ## 触っててウザいので出さない
          # Dispatch::Queue.main.async {
          #   App.alert(response.error_message)
          # }
        end
        Dispatch::Queue.main.async {
          @updating = false
          cb.call(response) if cb
        }
      }
    end
  end

  def updating?
    return @updating
  end

  def dealloc
    NSLog("dealloc: " + self.class.name)
    super
  end

  class TimeBased < FeedManager
    ## url when prepend feed
    def prepend_url
      @url
    end

    ## url when append feed
    def append_url
      append_url_from(@bookmarks.last.datetime)
    end

    ## url when replace placeholder
    def append_url_from(datetime)
      epoch = datetime.timeIntervalSince1970.to_i
      @url + "?until=#{epoch}"
    end

    def prepend(bookmarks)
      ## 取ってきたフィードそのものに被りがあると上手くいかないので先に uniq
      bookmarks.uniq! { |b| b.id }

      if @bookmarks.size > 0 and bookmarks.first.id == @bookmarks.first.id
        # 新着なし
      else
        ## 以下二行テスト用
        # dt = bookmarks[4].datetime
        # bookmarks.insert(5, Placeholder.new(5, dt))

        @last_update_method = 'prepend'

        origin_size = @bookmarks.size
        boundary = bookmarks.size
        bookmarks.concat(@bookmarks)
        @bookmarks = bookmarks

        unless self.uniq!
          if origin_size > 0
            dt = @bookmarks[boundary - 1].datetime
            @bookmarks.insert(boundary, Placeholder.new(boundary, dt))
          end
        end
      end
    end

    def append(bookmarks)
      @last_update_method = 'append'
      self << bookmarks
    end

    ## since パラメータがあれば uniq とか変なことしなくていいのだが
    def uniq!
      size = @bookmarks.size
      @bookmarks.uniq! { |b| b.id }
      if size == @bookmarks.size
        ## 被りがない == まだ続きがあるかも
        false
      else
        true
      end
    end

    def replace(i, bookmarks)
      @last_update_method = 'replace'
      ## 取ってきたフィードそのものに被りがあると上手くいかないので先に uniq
      bookmarks.uniq! { |b| b.id }

      boundary = i + bookmarks.size # ここ正しいかちょい不安
      @bookmarks[i] = bookmarks
      @bookmarks.flatten!

      # ここで落ちてるかも･･･
      unless self.uniq!
        id = @bookmarks[boundary - 1].id
        dt = @bookmarks[boundary - 1].datetime
        @bookmarks.insert(boundary, Placeholder.new(id, dt))
      end
    end

    def replace_placeholder(ph, &cb)
      @updating = true
      url = append_url_from(ph.datetime)

      NSLog("replace_placeholder: #{url}")

      ## FIXME: not DRY
      BW::HTTP.get(url) do |response|
        if response.ok?
          autorelease_pool {
            json = BW::JSON.parse(response.body.to_str)
            bookmarks = json['bookmarks'].collect { |dict| Bookmark.new(dict) }
            self.willChangeValueForKey('bookmarks')
            self.replace(@bookmarks.index(ph), bookmarks)
            self.didChangeValueForKey('bookmarks')
          }
        end
        @updating = false
        cb.call(response) if cb
      end
    end

    def prepended?
      @last_update_method == 'prepend'
    end

    def timebased?
      true
    end
  end

  class Offset < FeedManager
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

    def timebased?
      false
    end
  end
end
