class UIDevice
  @@gt = {}

  def gt?(version)
    return @@gt[version] if not @@gt[version].nil?
    v = UIDevice.currentDevice.systemVersion
    if (v.compare(version, options:NSNumericSearch) == NSOrderedSame or
        v.compare(version, options:NSNumericSearch) == NSOrderedDescending)
      @@gt[version] = true
    else
      @@gt[version] = false
    end
    return @@gt[version]
  end

  def ios8?
    gt?("8.0")
  end

  def ios7?
    gt?("7.0")
  end

  def ios6?
    !ios7?
  end
end
