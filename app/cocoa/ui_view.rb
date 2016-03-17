class UIView
  include HBFav2::Rectangle

  def resizeToFitWithSubviews
    width = 0
    height = 0

    self.subviews.each do |v|
      dw = v.frame.origin.x + v.frame.size.width
      dh = v.frame.origin.y + v.frame.size.height
      width  = dw if dw > width
      height = dh if dh > height
    end
    self.frame = [self.frame.origin, [width, height]]
  end
end
