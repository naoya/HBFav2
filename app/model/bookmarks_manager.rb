class BookmarksManager
  attr_accessor :popular, :all

  def initialize(url)
    @url = url
    @popular = []
    @all     = []
    @responses = []
  end

  def has_popular_bookmarks?
    @popular.size > 0
  end

  def sync!
    group = Dispatch::Group.new
    Dispatch::Queue.concurrent.async(group) do
      @popular = get_bookmarks("http://b.hatena.ne.jp/api/viewer.popular_bookmarks?url=#{@url.escape_url}")
    end

    Dispatch::Queue.concurrent.async(group) do
      @all = get_bookmarks(
        "http://b.hatena.ne.jp/entry/jsonlite/?url=#{@url.escape_url}",
        { "Cache-Control" => "no-cache" }
      )
    end

    App.shared.networkActivityIndicatorVisible = true
    group.wait
    App.shared.networkActivityIndicatorVisible = false

    Response.new(@responses)
  end

  def get_bookmarks(url, headers = {})
    bookmarks = []
    http = HBFav2::HTTPClient.new
    http.headers = headers
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
