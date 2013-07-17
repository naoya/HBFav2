# -*- coding: utf-8 -*-
class HatenaBookmarkActivity < UIActivity
  include URLPerformable

  def activityType
    "net.bloghackers.app.HatenaBookmarkActivity"
  end

  def activityImage
    # UIImage.imageNamed("HatenaBookmarkActivity")
    nil
  end

  def activityTitle
    "公式アプリ"
  end

  def performActivity
    "hatenabookmark:/entry/add?backurl=hbfav2:/&url=#{@url.absoluteString.escape_url}&title=#{@text.escape_url}".nsurl.open
    activityDidFinish(true)
  end
end
