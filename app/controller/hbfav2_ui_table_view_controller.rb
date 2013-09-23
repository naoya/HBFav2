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

      ## Set RefreshControl background (work around)
      if not UIDevice.currentDevice.ios7?
        frame = self.tableView.bounds
        frame.origin.y = -frame.size.height
        bgview = UIView.alloc.initWithFrame(frame)
        bgview.backgroundColor = '#e2e7ed'.uicolor
        self.tableView.insertSubview(bgview, atIndex: 0)
      end
    end

    def viewDidAppear(animated)
      super
      track_pageview(@tracked_view_name)
    end
  end
end
