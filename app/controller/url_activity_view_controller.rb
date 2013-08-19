# -*- coding: utf-8 -*-
class URLActivityViewController < UIActivityViewController
  def initWithDefaultActivities(activityItems)
    safari = TUSafariActivity.new
    pocket = PocketActivity.new
    hatena = HatenaBookmarkActivity.new

    chrome = ARChromeActivity.new.tap do |activity|
      activity.activityTitle = "Chromeで開く"
    end

    add_bookmark = AddBookmarkActivity.new.tap do |activity|
      user = ApplicationUser.sharedUser
      activity.hatena_id = user.hatena_id
      activity.password  = user.password
    end

    self.initWithActivityItems(
      activityItems,
      applicationActivities:[
        safari,
        chrome,
        add_bookmark,
        pocket,
        hatena,
      ]
    )

    self.setValue(activityItems[0], forKey:"subject")
    self.excludedActivityTypes = [UIActivityTypeMessage, UIActivityTypePostToWeibo]
    self
  end
end
