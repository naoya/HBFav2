class LeftViewCellContentView < UIView
  def drawRect(rect)
    NSLog("fofofo")
    self.superview.superview.drawRectContent(rect)
  end
end

class LeftViewCell < UITableViewCell
  def self.cellForLeftView(tableView)
    cell_id = 'left-view-cell'
    cell = tableView.dequeueReusableCellWithIdentifier(cell_id) ||
      LeftViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cell_id)
    cell
  end

  def initWithStyle(style, reuseIdentifier:cell_id)
    if super
      @contentView = LeftViewCellContentView.alloc.initWithFrame(CGRectZero)
      @contentView.backgroundColor = [50, 57, 73].uicolor
      @contentView.opaque = true
      self.contentView << @contentView

      self.imageView.contentMode = UIViewContentModeScaleAspectFit
      self.imageView.layer.tap do |layer|
        layer.cornerRadius = 3.0
        layer.masksToBounds = true
      end

      # self.textLabel.font = UIFont.systemFontOfSize(18)
      # self.textLabel.textColor = [196, 204, 217].uicolor
      # self.textLabel.shadowColor = [0, 0, 0].uicolor
      # self.textLabel.shadowOffset = [0.5, 1]

      @titleShadow = NSShadow.new
      @titleShadow.shadowOffset = [0.5, 1]
      @titleShadow.shadowColor = [0, 0, 0].uicolor

      self.contentView << @border = UIView.new.tap do |v|
        v.backgroundColor = [62, 69, 84].uicolor
      end
    end
    self
  end

  def setNeedsDisplay
    super
    if @contentView.present?
      @contentView.setNeedsDisplay
    end
  end

  def fillWithProperties(properties)
    @title = properties[:title]
    if image = properties[:image]
      i = image.kind_of?(UIImageView) ? image.image : image
      self.imageView.image = i
    end
    self.setNeedsDisplay
  end

  def layoutSubviews
    super
    @contentView.frame = self.bounds
    @border.frame = [[0, 0], [self.bounds.size.width, 1]]
    if self.imageView.image
      self.imageView.frame = [[8, 8], [28, 28]]
    end
    # self.textLabel.origin = [self.imageView.right + 8, self.textLabel.origin.y ]
  end

  def drawRectContent(rect)
    NSLog(@title)
    size =  @title.sizeWithFont(UIFont.systemFontOfSize(18))
    title = @title.attrd.shadow(@titleShadow).foreground_color([196, 204, 217].uicolor).font(UIFont.systemFontOfSize(18))
    title.drawInRect([[self.imageView.right + 8, self.imageView.top + 4], size])
  end
end
