class SectionHeaderView < UILabel
  def self.heightForHeader
    24
  end

  def initWithFrame(frame)
    super
    if self
      self.backgroundColor = [179, 189, 197].uicolor(0.8)
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
