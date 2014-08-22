class LeftViewCell < UITableViewCell
  def self.cellForLeftView(tableView)
    cell_id = 'left-view-cell'
    cell = tableView.dequeueReusableCellWithIdentifier(cell_id) ||
      LeftViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cell_id)
    cell
  end

  def initWithStyle(style, reuseIdentifier:cell_id)
    if super
      self.selectedBackgroundView = UIView.new.tap do |v|
        v.backgroundColor = [41, 47, 59].uicolor
      end

      @contentView = HBFav2::CustomCellContentView.alloc.initWithFrame(CGRectZero)
      @contentView.backgroundColor = [50, 57, 73].uicolor
      @contentView.opaque = true
      self.contentView << @contentView

      self.imageView.contentMode = UIViewContentModeScaleAspectFit
      self.imageView.layer.tap do |layer|
        layer.cornerRadius = 3.0
        layer.masksToBounds = true
      end

      @titleShadow = NSShadow.new
      @titleShadow.shadowOffset = [0.5, 1]
      @titleShadow.shadowColor = [0, 0, 0].uicolor
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

    if properties[:blank]
      @contentView.backgroundColor = [41, 47, 59].uicolor
    end

    self.setNeedsDisplay
  end

  def layoutSubviews
    super
    @contentView.frame = self.bounds
    if self.imageView.image
      self.imageView.frame = [[8, 8], [28, 28]]
    end
  end

  def drawRectContent(rect)
    size =  @title.sizeWithFont(ApplicationConfig.sharedConfig.applicationFontOfSize(18))
    title = @title.attrd.foreground_color([196, 204, 217].uicolor).font(ApplicationConfig.sharedConfig.applicationFontOfSize(18))

    if not UIDevice.currentDevice.ios7_or_later?
      title = title.shadow(@titleShadow)
    end

    title.drawInRect([[self.imageView.right + 8, self.imageView.top + 4], size])

    if UIDevice.currentDevice.ios7_or_later?
      unless selected?
        context = UIGraphicsGetCurrentContext()
        [36, 42, 54].uicolor(1.0).setStroke
        CGContextSetLineWidth(context, 1)
        CGContextMoveToPoint(context, 42, 0)
        CGContextAddLineToPoint(context, self.right, 0)
        CGContextStrokePath(context)
      end
    else
      unless selected?
        context = UIGraphicsGetCurrentContext()
        [62, 69, 84].uicolor(1.0).setStroke
        CGContextSetLineWidth(context, 2)
        CGContextMoveToPoint(context, 0, 0)
        CGContextAddLineToPoint(context, self.right, 0)
        CGContextStrokePath(context)
      end
    end
  end
end
