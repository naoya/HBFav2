class ApplicationConfig
  attr_reader :vars

  def self.sharedConfig
    Dispatch.once { @instance ||= new }
    @instance
  end

  def initialize
    @vars = MY_ENV
    @is_ios7 = UIDevice.currentDevice.ios7_or_later?
  end

  def ios7_or_later?
    @is_ios7
  end

  def applicationFontOfSize(size)
    ios7_or_later? ? UIFont.fontWithName("HelveticaNeue", size:size) : UIFont.systemFontOfSize(size)
  end

  def boldApplicationFontOfSize(size)
    ios7_or_later? ? UIFont.fontWithName("HelveticaNeue", size:size) : UIFont.boldSystemFontOfSize(size)
  end

  def systemFontOfSize(size)
    ios7_or_later? ? UIFont.fontWithName("HelveticaNeue", size:size) : UIFont.systemFontOfSize(size)
  end

  def boldSystemFontOfSize(size)
    ios7_or_later? ? UIFont.fontWithName("Helvetica-Bold", size:size) : UIFont.boldSystemFontOfSize(size)
  end
end
