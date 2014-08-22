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

  def ios7_or_later?
    gt?("7.0")
  end

  def ios8_or_later?
    gt?("8.0")
  end

  def ios6_or_earlier?
    !ios7_or_later?
  end
end
