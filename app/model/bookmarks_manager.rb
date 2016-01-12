class BookmarksManager
  attr_accessor :popular, :followers, :all

  def initialize(url, options = {})
    @url = url
    @options = options
    @popular = []
    @followers = []
    @all     = []
    @responses = []
  end

  def items
    if @options[:hide_nocomment]
      self.comments
    else
      self.all
    end
  end

  def comments
    if @all.size > 0
      @comments ||= @all.select { |bookmark| bookmark.comment.length > 0 }
    else
      @all
    end
  end

  def has_popular_bookmarks?
    @popular.size > 0
  end

  def has_followers_bookmarks?
    @followers.size > 0
  end

  def sync!
    group = Dispatch::Group.new
    Dispatch::Queue.concurrent.async(group) do
      @popular, _x = get_bookmarks("http://b.hatena.ne.jp/api/viewer.popular_bookmarks?url=#{@url.escape_url}")      
    end

    Dispatch::Queue.concurrent.async(group) do
      @all, @followers = get_bookmarks(
        "http://comments.hbfav.com/#{ApplicationUser.sharedUser.hatena_id}?url=#{@url.escape_url}",
        {
          :cache_policy => NSURLRequestReloadIgnoringLocalCacheData
        }
      )
    end

    App.shared.networkActivityIndicatorVisible = true
    group.wait
    App.shared.networkActivityIndicatorVisible = false

    Response.new(@responses)
  end

  def get_bookmarks(url, options = {})
    bookmarks = []
    followers = []
    http = HBFav2::HTTPClient.new
    http.headers      = options[:headers] if options[:headers]
    http.cache_policy = options[:cache_policy] if options[:cache_policy]
    http.get(url) do |response|
      if response.ok?
        autorelease_pool {
          entry = BW::JSON.parse(response.content)
          if entry and entry['bookmarks'].present?
            entry['bookmarks'].each { |bookmark| bookmarks.push(Bookmark.new_from_data(entry, bookmark)) }
          end
          if entry and entry['followers'].present?
            entry['followers'].each{|follower| followers.push(Bookmark.new_from_data(entry, follower)) }
          end
        }
      end
      @responses.push(response)
    end
    return bookmarks, followers
  end

  class Response
    def initialize(responses)
      @responses = responses
    end

    def ok?
      @responses.each do |response|
        return false if not response.ok?
      end
      true
    end

    def message
      res = @responses.find { |response| not response.ok? }
      res.message
    end
  end
end
