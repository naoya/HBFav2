module HBFav2
  module BackgroundEvent
    def performBackgroundFetchWithCompletion(completionHandler)
      completionHandler.call(UIBackgroundFetchResultNoData)
    end
  end
end
