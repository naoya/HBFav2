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
      @popular = get_bookmarks("http://b.hatena.ne.jp/api/viewer.popular_bookmarks?url=#{@url.escape_url}")      
    end

    Dispatch::Queue.concurrent.async(group) do
      @all = get_bookmarks(
        "http://b.hatena.ne.jp/entry/jsonlite/?url=#{@url.escape_url}",
        {
          :headers      => { "Cache-Control" => "no-cache" },
          :cache_policy => NSURLRequestReloadIgnoringLocalCacheData
        }
      )

      ## 本当はこれも並列化したいが entry 情報が必要なので...
      if @all.size > 0
        ## all.first を渡すのは Bookmark オブジェクトにエントリ情報入ってるから
        @followers = get_followers_bookmarks('naoya', @all.first)
      end
    end

    App.shared.networkActivityIndicatorVisible = true
    group.wait
    App.shared.networkActivityIndicatorVisible = false

    Response.new(@responses)
  end

  def get_bookmarks(url, options = {})
    bookmarks = []
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
        }
      end
      @responses.push(response)
    end
    bookmarks
  end

  def get_followers_bookmarks(user, entry)
    bookmarks = []
    http = HBFav2::HTTPClient.new
    http.get("http://comments.hbfav.com/#{user}?eid=#{entry.eid}") do |response|
      if response.ok?
        autorelease_pool {
          data = BW::JSON.parse(response.content)
          if data and data['comments'].present?
            data['comments'].each { |rec|
              # FIXME: Bookmark クラスへ
              bookmark = Bookmark.new(
                {
                  :eid   => entry.eid,
                  :title => entry.title,
                  :link  => entry.link,
                  :count => entry.count,
                  :user => {
                    :name => rec['user']
                  },
                  :comment => rec['comment'],

                  # 2015/11/08 11:51:41
                  :created_at => rec['timestamp'],

                  # 2005-02-10T20:55:55+09:00
                  :datetime => Bookmark.timestamp2dt(rec['timestamp'])
                }
              )
              bookmarks.push(bookmark)
            }
          end
        }
      end
    end
    bookmarks
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
