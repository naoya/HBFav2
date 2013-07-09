# -*- coding: utf-8 -*-
class AddBookmarkActivity < UIActivity
  attr_accessor :hatena_id, :password
  include URLPerformable
  include RmWsse

  def activityType
    "net.bloghackers.app.AddBookmarkActivity"
  end

  def activityImage
    nil
  end

  def activityTitle
    "はてなブックマークに追加"
  end

  def performActivity
    url = @url.absoluteString.gsub(/&/, '&amp;') ## work around

    xml = <<"EOF"
<entry xmlns="http://purl.org/atom/ns#">
  <title>dummy</title>
  <link rel="related" type="text/html" href="#{url}" />
  <summary type="text/plain"></summary>
</entry>
EOF
    ## debug
    puts xml

    BW::HTTP.post(
      'http://b.hatena.ne.jp/atom/post', {
        :payload => xml,
        :headers => {
          'Accept' => 'application/x.atom+xml,application/xml,text/xml,*/*',
          'X-WSSE' => wsse_header(self.hatena_id, self.password)
        }
      }
    ) do |response|
      # TODO
      puts response.status_code
      puts response.error_message
      puts response
    end
    activityDidFinish(true)
  end
end
