class LeftViewCell < UITableViewCell
  def self.cellForLeftView(tableView)
    cell_id = 'left-view-cell'
    cell = tableView.dequeueReusableCellWithIdentifier(cell_id) ||
      LeftViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cell_id)
    cell
  end

  def initWithStyle(style, reuseIdentifier:cell_id)
    if super
      self.imageView.contentMode = UIViewContentModeScaleAspectFit
      self.imageView.layer.tap do |layer|
        layer.cornerRadius = 3.0
        layer.masksToBounds = true
      end

      self.textLabel.font = UIFont.systemFontOfSize(18)
      self.textLabel.textColor = [196, 204, 217].uicolor
      self.textLabel.shadowColor = [0, 0, 0].uicolor
      self.textLabel.shadowOffset = [0.5, 1]

      self.contentView << @border = UIView.new.tap do |v|
        v.backgroundColor = [62, 69, 84].uicolor
      end
    end
    self
  end

  def layoutSubviews
    super
    @border.frame = [[0, 0], [self.bounds.size.width, 1]]
    if self.imageView.image
      self.imageView.frame = [[8, 8], [28, 28]]
    end
    self.textLabel.origin = [self.imageView.right + 8, self.textLabel.origin.y ]
  end
end
