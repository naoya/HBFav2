class SectionHeaderView < UILabel
  def self.heightForHeader
    22
  end

  def initWithFrame(frame)
    super
    if self
      self.backgroundColor = [41, 47, 59].uicolor(0.4)
      self.textColor = '#fff'.uicolor
      self.font = UIFont.systemFontOfSize(16)
    end
    self
  end

  def drawTextInRect(rect)
    insets = UIEdgeInsetsMake(0, 8, 0, 8)
    super(UIEdgeInsetsInsetRect(rect, insets))
  end
end
