class TitleLabel < UILabel
  def initWithFrame(frame)
    if super
      self.font = UIFont.boldSystemFontOfSize(14.0)
      self.backgroundColor = UIColor.clearColor
      self.textAlignment = UITextAlignmentCenter
      self.textColor = UIColor.whiteColor

      unless UIDevice.currentDevice.ios7?
        self.shadowColor = UIColor.colorWithWhite(0.0, alpha: 0.5)
      end
    end
    self
  end
end
