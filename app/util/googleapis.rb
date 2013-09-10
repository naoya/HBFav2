class GoogleAPI
  attr_accessor :api_key

  def self.sharedAPI
    Dispatch.once { @instance ||= new }
    @instance
  end

  def expand_url (url, &block)
    BW::HTTP.get("https://www.googleapis.com/urlshortener/v1/url", {payload: {shortUrl:url, key:self.api_key}}) do |response|
      if response.ok?
        result = BW::JSON.parse(response.body.to_str)
        block.call(response, result['longUrl'])
      else
        block.call(response, nil)
      end
    end
  end
end
