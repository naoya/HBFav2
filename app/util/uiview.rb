class UIView
  def top
    self.frame.origin.y
  end

  def top= (y)
    f = self.frame
    f.origin.y = y
    self.frame = f
  end

  def right
    self.frame.origin.x + self.frame.size.width
  end

  def right= (right)
    f = self.frame
    f.origin.x = right - self.frame.size.width
    self.frame = f
  end

  def bottom
    self.frame.origin.y + self.frame.size.height
  end

  def bottom= (bottom)
    f = self.frame
    f.origin.y = bottom - self.frame.size.height
    self.frame = f
  end

  def left
    self.frame.origin.x
  end

  def left= (x)
    f = self.frame
    f.origin.x = x
    self.frame = f
  end
end
