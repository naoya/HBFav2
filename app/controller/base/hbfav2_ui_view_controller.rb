# -*- coding: undecided -*-
module HBFav2
  class UIViewController < UIViewController
    attr_accessor :tracked_view_name
    include HBFav2::HomeCondition
    include HBFav2::BackGesture
    include HBFav2::BackgroundEvent

    def viewDidLoad
      super
      configure_back_gesture
    end

    def viewDidAppear(animated)
      super
      self.navigationItem.backBarButtonItem = NavigationBackButton.create
    end
  end
end
