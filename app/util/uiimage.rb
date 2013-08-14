class UIImage
  def landscape?
    size.width > size.height ? true : false
  end

  def portrailt?
    !self.is_landscape?
  end
end
