class ProfileView < UIView
  attr_reader :menuTable

  def initWithFrame(frame)
    if super
      self.initialize_views
    end
    super
  end

  def initialize_views
    self << @backgroundView = UITableView.alloc.initWithFrame(CGRectZero, style:UITableViewStyleGrouped)

    self << @imageView = UIImageView.new.tap do |v|
      v.layer.tap do |l|
        l.masksToBounds = true
        l.cornerRadius  = 5.0
      end
    end

    self << @nameLabel = UILabel.new.tap do |v|
      v.font  = UIFont.boldSystemFontOfSize(18)
      v.shadowColor = UIColor.whiteColor
      v.shadowOffset = [0, 1]
      v.backgroundColor = UIColor.clearColor
    end

    self << @menuTable = UITableView.alloc.initWithFrame(CGRectZero, style:UITableViewStyleGrouped)
  end

  def user=(user)
    @user = user
    @imageView.setImageWithURL(@user.profile_image_url.nsurl, placeholderImage:nil)
    @nameLabel.text  = @user.name
    self.setNeedsLayout
  end

  def layoutSubviews
    super
    @backgroundView.frame = self.bounds
    @imageView.frame = [[10, 10], [48, 48]]
    @nameLabel.frame = [[68, 10], [200, 48]]
    @menuTable.frame = [[0, 59], self.bounds.size]
  end
end
