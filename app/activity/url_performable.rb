module URLPerformable
  def canPerformWithActivityItems(activityItems)
    activityItems.each do |object|
      return true if object.class == NSURL
    end
    false
  end

  def prepareWithActivityItems(activityItems)
    activityItems.each do |object|
      @text = object if object.class == String or object.class == NSString
      @url  = object if object.class == NSURL
    end
  end
end
