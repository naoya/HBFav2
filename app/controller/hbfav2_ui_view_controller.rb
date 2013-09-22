# -*- coding: undecided -*-
module HBFav2
  class UIViewController < UIViewController
    attr_accessor :tracked_view_name
    include HBFav2::GoogleAnalytics

    def viewDidAppear(animated)
      super
      self.navigationItem.backBarButtonItem = NavigationBackButton.create
      track_pageview(@tracked_view_name)
    end
  end
end
