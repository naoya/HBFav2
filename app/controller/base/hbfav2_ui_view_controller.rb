# -*- coding: undecided -*-
module HBFav2
  class UIViewController < UIViewController
    attr_accessor :tracked_view_name
    include HBFav2::GoogleAnalytics
    include HBFav2::HomeCondition
    include HBFav2::BackGesture

    def viewDidLoad
      super
      configure_back_gesture
    end

    def viewDidAppear(animated)
      super
      self.navigationItem.backBarButtonItem = NavigationBackButton.create
      track_pageview(@tracked_view_name)
    end
  end
end
