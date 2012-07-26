class ProfileViewController < UIViewController
  def init
    if super
      self.navigationItem.title = "naoya"
      self.view.backgroundColor = UIColor.groupTableViewBackgroundColor
    end
    self
  end

  def viewDidLoad
    super

    @imageView = UIImageView.new.tap do |v|
      v.frame = [[10, 10], [48, 48]]
      v.layer.tap do |l|
        l.masksToBounds = true
        l.cornerRadius  = 5.0
      end
      view << v
    end

    @nameLabel = UILabel.new.tap do |v|
      v.frame = [[68, 10], [200, 48]]
      v.font  = UIFont.boldSystemFontOfSize(18)
      v.text  = "naoya"
      v.shadowColor = UIColor.whiteColor
      v.shadowOffset = [0, 1]
      v.backgroundColor = UIColor.clearColor
      view << v
    end

    Dispatch::Queue.concurrent.async do
      image = RemoteImageFactory.instance(:profile_image).image('http://www.st-hatena.com/users/na/naoya/profile.gif')
      Dispatch::Queue.main.sync do
        @imageView.image = image
      end
    end
  end
end
