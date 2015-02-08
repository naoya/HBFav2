module HBFav2
  class UITabBarController < UITabBarController
    def viewDidLoad
      super
      self.delegate = self
    end

    #
    # UITabBarControllerDelegate
    #
    def tabBarController(tabBarController, didSelectViewController:viewController)
      @previousController = @previousController || viewController
      if (@previousController == viewController)
        if viewController.kind_of?(UINavigationController)
          if (viewController.viewControllers.count == 1)
            rootViewController = viewController.viewControllers.firstObject
            if rootViewController.respondsToSelector('tableView')
              rootViewController.tableView.setContentOffset(CGPointMake(0, -rootViewController.tableView.contentInset.top), animated:true)
            end
          end
        end
      end
      @previousController = viewController
    end
  end
end
