## Not used, but existing for remainder
module HBFav
  module URI
    module Escape
      def escape_uri(str)
        CFURLCreateStringByAddingPercentEscapes(
          nil,
          str,
          nil,
          "!*'();:@&=+$,/?%#[]",
          KCFStringEncodingUTF8
        )
      end

      def unescape_uri(str)
        CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
          nil,
          str,
          CFSTR(""),
          KCFStringEncodingUTF8
        );
      end
    end
  end
end
