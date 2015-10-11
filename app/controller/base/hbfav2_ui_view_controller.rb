# -*- coding: utf-8 -*-
module HBFav2
  class UIViewController < UIViewController
    attr_accessor :tracked_view_name
    include HBFav2::HomeCondition
    include HBFav2::BackgroundEvent

    def viewDidLoad
      super
    end

    def viewDidAppear(animated)
      super
      self.navigationItem.backBarButtonItem = NavigationBackButton.create
    end

    def willAnimateRotationToInterfaceOrientation(orientation, duration:duration)
      # FIXME : Just rotate. need better way for iOS 7.
      v = self.view.subviews.first
      frame = v.frame
      v.frame = CGRectMake(0, 0, frame.size.height, frame.size.width)
    end

    def viewWillTransitionToSize(size, withTransitionCoordinator:coordinator)
      v = self.view.subviews.first
      v.frame = CGRectMake(0, 0, size.width, size.height)
    end
  end
end
