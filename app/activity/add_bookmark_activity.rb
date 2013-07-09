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
    SVProgressHUD.showWithStatus("保存中...")
    url = @url.absoluteString.gsub(/&/, '&amp;') ## work around

    xml = <<"EOF"
<entry xmlns="http://purl.org/atom/ns#">
  <title>dummy</title>
  <link rel="related" type="text/html" href="#{url}" />
  <summary type="text/plain"></summary>
</entry>
EOF
    ## debug
    # puts xml

    BW::HTTP.post(
      'http://b.hatena.ne.jp/atom/post', {
        :payload => xml,
        :headers => {
          'Accept' => 'application/x.atom+xml,application/xml,text/xml,*/*',
          'X-WSSE' => wsse_header(self.hatena_id, self.password)
        }
      }
    ) do |response|
      if response.ok?
        SVProgressHUD.showSuccessWithStatus("保存しました")
      else
        SVProgressHUD.showErrorWithStatus("失敗: " + response.status_code.to_s)
      end

      # puts response.status_code
      # puts response.error_message
      # puts response
    end
    activityDidFinish(true)
  end
end
