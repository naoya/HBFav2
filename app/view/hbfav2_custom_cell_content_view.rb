module HBFav2
  class CustomCellContentView < UIView
    def drawRect(rect)
      if UIDevice.currentDevice.ios7?
        self.superview.superview.superview.drawRectContent(rect)
      else
        self.superview.superview.drawRectContent(rect)
      end
    end
  end
end
