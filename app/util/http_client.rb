module HBFav2
  class HTTPClient
    attr_accessor :headers, :cache_policy, :timeout

    def initialize
      @headers = {}
      @cache_policy = NSURLRequestUseProtocolCachePolicy
      @timeout = 30.0
    end

    def get(url, &block)
      request = NSURLRequest.alloc.initWithURL(url.nsurl, cachePolicy:@cache_policy, timeoutInterval:@timeout)

      if self.headers.size > 0
        mutableRequest = request.mutableCopy
        self.headers.each { |k, v| mutableRequest.addValue(v, forHTTPHeaderField:k) }
        request = mutableRequest.copy
      end

      error = Pointer.new(:object)
      response = Pointer.new(:object)
      data = NSURLConnection.sendSynchronousRequest(request, returningResponse:response, error:error)

      res = Response.new
      res.error       = error[0]  ? error[0] : nil
      res.status_code = response[0] ? response[0].statusCode : nil
      res.data        = data

      block.call(res)
    end

    class Response
      attr_accessor :status_code, :data, :error

      def ok?
        if error.present?
          false
        else
          self.status_code.to_s =~ /2\d\d/ ? true : false
        end
      end

      def message
        if error.present?
          error.localizedDescription
        else
          self.status_code.nil? ? nil : NSHTTPURLResponse.localizedStringForStatusCode(status_code)
        end
      end

      def content
        return nil if not data
        data.to_s
      end
    end
  end
end
