module HBFav2
  module GoogleAnalytics
    def track_pageview(tracked_view_name)
      if tracked_view_name.present?
        tracker = GAI.sharedInstance.defaultTracker
        tracker.set(KGAIScreenName, value:tracked_view_name)
        tracker.send(GAIDictionaryBuilder.createAppView.build)
      end
    end
  end
end
