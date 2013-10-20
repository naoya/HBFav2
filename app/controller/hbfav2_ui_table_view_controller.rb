module HBFav2
  class UITableViewController < UITableViewController
    attr_accessor :tracked_view_name
    include HBFav2::GoogleAnalytics

    def viewDidLoad
      super

      self.navigationItem.backBarButtonItem = NavigationBackButton.create

      if UIDevice.currentDevice.ios7?
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 0)
        self.tableView.separatorColor = '#ddd'.uicolor
      end
    end

    def viewDidAppear(animated)
      super
      track_pageview(@tracked_view_name)
    end
  end
end
