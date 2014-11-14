module HBFav2
  module HatenaBookmarkSDK
    def configure_hatena_bookmark_service
      config = ApplicationConfig.sharedConfig
      HTBHatenaBookmarkManager.sharedManager.setConsumerKey(
        config.vars['hatena']['consumer_key'],
        consumerSecret:config.vars['hatena']['consumer_secret'],
      )
    end
  end
end
