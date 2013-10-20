class SectionHeaderView < UILabel
  def self.heightForHeader
    24
  end

  def initWithFrame(frame)
    super
    if self
      self.backgroundColor = '#99a0aa'.uicolor(0.6)
      self.textColor = '#fff'.uicolor
      self.font = UIFont.boldSystemFontOfSize(16)
    end
    self
  end

  def drawTextInRect(rect)
    insets = UIEdgeInsetsMake(0, 8, 0, 8)
    super(UIEdgeInsetsInsetRect(rect, insets))
  end
end
