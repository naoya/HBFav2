class StarCell < UITableViewCell
  SideWidth = 65
  attr_reader :nameLabel

  def self.cellForStar(star, inTableView:tableView)
    cell_id = 'star_cell'
    cell = tableView.dequeueReusableCellWithIdentifier(cell_id) ||
      StarCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cell_id)
    cell.fillWithStar(star)
    cell
  end

  def self.heightForStar(star, width)
    68 #FIXME
  end

  def self.bodyWidth(width)
    width - SideWidth - 10
  end

  def initWithStyle(style, reuseIdentifier:cellid)
    if super
      self.imageView.layer.tap do |l|
        l.masksToBounds = true
        l.cornerRadius  = 5.0
      end

      @nameLabel = UILabel.new.tap do |v|
        v.frame = CGRectZero
        v.font  = UIFont.boldSystemFontOfSize(16)
        v.backgroundColor = '#fff'.uicolor
        self.contentView << v
      end
    end
    self
  end

  def fillWithStar(star)
    self.nameLabel.text    = star.user.name
    self.imageView.setImageWithURL(star.user.profile_image_url.nsurl, placeholderImage:"profile_placeholder.png.png".uiimage)
  end

  def layoutSubviews
    super
    frame_size = self.frame.size
    body_width = self.class.bodyWidth(frame_size.width)

    self.imageView.frame = [[10, 10], [48, 48]]

    current_y = 10

    ## name
    name_size = self.nameLabel.text.sizeWithFont(UIFont.boldSystemFontOfSize(16))
    self.nameLabel.frame = [[SideWidth, current_y], [body_width, name_size.height]]
    self.nameLabel.sizeToFit
    current_y += name_size.height + 5
  end

  def dealloc
    NSLog("dealloc: " + self.class.name)
    super
  end
end
