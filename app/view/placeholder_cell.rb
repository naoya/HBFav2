# -*- coding: utf-8 -*-
class PlaceholderCell < UITableViewCell
  def self.cellForPlaceholder(placeholder, inTableView:tableView)
    cell_id = 'placeholder_cell'
    cell = tableView.dequeueReusableCellWithIdentifier(cell_id) ||
      PlaceholderCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cell_id)
    cell
  end

  def beginRefreshing
    self.textLabel.hide
    @indicator.startAnimating
  end

  def endRefreshing
    self.textLabel.show
    @indicator.stopAnimating
  end

  def initWithStyle(style, reuseIdentifier:cell_id)
    if super
      shadow = NSShadow.new
      shadow.shadowOffset = [0, 1]
      shadow.shadowColor = UIColor.whiteColor
      self.textLabel.attributedText = 'さらにブックマークを読み込む'.attrd.shadow(shadow).foreground_color("#678").bold(14)
      self.textLabel.backgroundColor = '#e2e7ed'.uicolor
      self.textLabel.textAlignment = NSTextAlignmentCenter
      self.selectionStyle = UITableViewCellSelectionStyleNone
      self.contentView.backgroundColor = '#e2e7ed'.uicolor
      self.contentView << @indicator = UIActivityIndicatorView.gray
    end
    self
  end

  def layoutSubviews
    super
    self.textLabel.frame = self.bounds
    @indicator.center = [self.bounds.size.width / 2, self.bounds.size.height / 2]
  end
end
