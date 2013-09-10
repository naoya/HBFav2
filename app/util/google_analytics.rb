module HBFav2
  module GoogleAnalytics
    def configure_google_analytics(tracking_id)
      GAI.sharedInstance.trackerWithTrackingId(tracking_id)
      GAI.sharedInstance.logger.setLogLevel(KGAILogLevelVerbose) if RUBYMOTION_ENV == "development"
      GAI.sharedInstance.setDispatchInterval(30)
      GAI.sharedInstance.setDryRun(false)
    end

    def track_pageview(tracked_view_name)
      if tracked_view_name.present?
        tracker = GAI.sharedInstance.defaultTracker
        tracker.set(KGAIScreenName, value:tracked_view_name)
        tracker.send(GAIDictionaryBuilder.createAppView.build)
      end
    end
  end
end
