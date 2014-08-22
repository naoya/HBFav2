module HBFav2
  class CustomCellContentView < UIView
    def drawRect(rect)
      if UIDevice.currentDevice.ios8_or_later?
        self.superview.superview.drawRectContent(rect)
      elsif UIDevice.currentDevice.ios7_or_later?
        self.superview.superview.superview.drawRectContent(rect)
      else
        self.superview.superview.drawRectContent(rect)
      end
    end
  end
end
