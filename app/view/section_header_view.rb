class SectionHeaderView < UILabel
  def self.heightForHeader
    26
  end

  def initWithFrame(frame)
    super
    if self
      self.backgroundColor = [36, 66, 88].uicolor(0.35)
      self.textColor = '#fff'.uicolor
      self.font = UIFont.systemFontOfSize(18)
    end
    self
  end

  def drawTextInRect(rect)
    insets = UIEdgeInsetsMake(0, 8, 0, 8)
    super(UIEdgeInsetsInsetRect(rect, insets))
  end
end
