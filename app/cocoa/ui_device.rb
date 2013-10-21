class UIDevice
  def ios7?
    version = UIDevice.currentDevice.systemVersion
    if (version.compare("7.0", options:NSNumericSearch) == NSOrderedSame or
        version.compare("7.0", options:NSNumericSearch) == NSOrderedDescending)
      return true
    end
    return false
  end

  def ios6?
    !ios7?
  end
end
