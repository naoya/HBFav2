class TitleLabel < UILabel
  def initWithFrame(frame)
    if super
      self.font = UIFont.boldSystemFontOfSize(14.0)
      self.backgroundColor = UIColor.clearColor
      self.shadowColor = UIColor.colorWithWhite(0.0, alpha: 0.5)
      self.textAlignment = UITextAlignmentCenter
      self.textColor = UIColor.whiteColor
    end
    self
  end
end
