class BookmarkManager
  def self.sharedManager
    Dispatch.once { @instance ||= new }
    @instance
  end

  def get_bookmark(url, user_name, &block)
    BW::HTTP.get("http://b.hatena.ne.jp/entry/jsonlite/", {payload: {url: url}}) do |response|
      if response.ok?
        autorelease_pool {
          entry = BW::JSON.parse(response.body.to_str)

          if entry and entry['bookmarks'].present?
            bookmark = entry['bookmarks'].find { |item| item['user'] == user_name }
            if bookmark
              block.call(response, data_to_object(entry, bookmark))
            else
              block.call(response, nil)
            end
          end
        }
      else
        block.call(response, nil)
      end
    end
  end

  def data_to_object(entry, bookmark)
    Bookmark.new(
      {
        :eid   => entry['eid'],
        :title => entry['title'] || '',
        :link  => entry['url'],
        :count => entry['count'],
        :eid   => entry['eid'],
        :user => {
          :name => bookmark['user']
        },
        :comment    => bookmark['comment'] || '',
        :created_at => bookmark['timestamp'],
        # 2005/02/10 20:55:55 => 2005-02-10T20:55:55+09:00
        :datetime   =>  bookmark['timestamp'].gsub(/\//, '-').gsub(/ /, 'T') + '+09:00'
      }
    )
  end
end
