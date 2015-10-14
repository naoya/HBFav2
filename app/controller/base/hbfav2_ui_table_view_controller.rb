module HBFav2
  class UITableViewController < UITableViewController
    attr_accessor :tracked_view_name
    include HBFav2::HomeCondition
    include HBFav2::BackgroundEvent

    def viewDidLoad
      super
      self.navigationItem.backBarButtonItem = NavigationBackButton.create

      if UIDevice.currentDevice.ios7_or_later?
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 0)
        self.tableView.separatorColor = '#ddd'.uicolor
      end
    end

    def willAnimateRotationToInterfaceOrientation(orientation, duration:duration)
      self.view.reloadData
    end

    def viewWillTransitionToSize(size, withTransitionCoordinator:coordinator)
      self.view.reloadData
    end
  end
end
