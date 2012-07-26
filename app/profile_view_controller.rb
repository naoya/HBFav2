class ProfileViewController < UIViewController
  def init
    if super
      self.navigationItem.title = "naoya"
      self.view.backgroundColor = UIColor.groupTableViewBackgroundColor
    end
    self
  end
end
