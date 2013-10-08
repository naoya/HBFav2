class SectionHeaderView < UILabel
  def self.heightForHeader
    21
  end

  def initWithFrame(frame)
    super
    if self
      # self.backgroundColor = '#efeff4'.uicolor(0.9)
      self.backgroundColor = '#66abe0'.uicolor(0.5)
      self.textColor = '#fff'.uicolor
      self.font = UIFont.boldSystemFontOfSize(14)
    end
    self
  end

  def drawTextInRect(rect)
    insets = UIEdgeInsetsMake(0, 8, 0, 8)
    super(UIEdgeInsetsInsetRect(rect, insets))
  end
end
