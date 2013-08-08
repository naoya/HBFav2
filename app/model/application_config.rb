class ApplicationConfig
  attr_reader :vars

  def self.sharedConfig
    Dispatch.once { @instance ||= new }
    @instance
  end

  def initialize
    if path = NSBundle.mainBundle.pathForResource("config", ofType:"yml")
      @vars = YAML.load File.read path
    end
  end
end
