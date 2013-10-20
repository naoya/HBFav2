class UIDevice
  def ios7?
    return @is_ios7 unless @is_ios7.nil?

    version = UIDevice.currentDevice.systemVersion
    if (version.compare("7.0", options:NSNumericSearch) == NSOrderedSame or
        version.compare("7.0", options:NSNumericSearch) == NSOrderedDescending)
      return @is_ios7 = true
    end
    return @is_ios7 = false
  end
end
