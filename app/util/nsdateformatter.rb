class NSDateFormatter
  def initWithGregorianCalendar
    if self.init
      calendar = NSCalendar.alloc.initWithCalendarIdentifier(NSGregorianCalendar)
      self.setLocale(NSLocale.systemLocale)
      self.setTimeZone(NSTimeZone.systemTimeZone)
      self.setCalendar(calendar)
    end
    self
  end
end
