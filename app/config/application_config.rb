class ApplicationConfig
  attr_reader :vars

  def self.sharedConfig
    Dispatch.once { @instance ||= new }
    @instance
  end

  def initialize
    @vars = MY_ENV
    @is_ios7 = UIDevice.currentDevice.ios7?
  end

  def ios7?
    @is_ios7
  end

  def applicationFontOfSize(size)
    ios7? ? UIFont.fontWithName("HelveticaNeue", size:size) : UIFont.systemFontOfSize(size)
  end

  def boldApplicationFontOfSize(size)
    ios7? ? UIFont.fontWithName("HelveticaNeue", size:size) : UIFont.boldSystemFontOfSize(size)
  end

  def systemFontOfSize(size)
    ios7? ? UIFont.fontWithName("HelveticaNeue", size:size) : UIFont.systemFontOfSize(size)
  end

  def boldSystemFontOfSize(size)
    ios7? ? UIFont.fontWithName("Helvetica-Bold", size:size) : UIFont.boldSystemFontOfSize(size)
  end
end
