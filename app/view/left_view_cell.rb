class LeftViewCellContentView < UIView
  def drawRect(rect)
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
    size =  @title.sizeWithFont(UIFont.systemFontOfSize(18))
    title = @title.attrd.shadow(@titleShadow).foreground_color([196, 204, 217].uicolor).font(UIFont.systemFontOfSize(18))
    title.drawInRect([[self.imageView.right + 8, self.imageView.top + 4], size])

    ## shadowed border line
    context = UIGraphicsGetCurrentContext()
    [62, 69, 84].uicolor(1.0).setStroke
    CGContextSetLineWidth(context, 2)
    CGContextMoveToPoint(context, 0, 0)
    CGContextAddLineToPoint(context, self.right, 0)
    CGContextStrokePath(context)
  end
end
