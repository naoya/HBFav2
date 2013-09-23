class BookmarkLabelAttributes
  attr_reader :attributes

  def self.sharedAttributes
    Dispatch.once { @instance ||= new }
    @instance
  end

  def initialize
    @attributes = {
      :name             => { :color => '#000',    :font => UIFont.boldSystemFontOfSize(16) },
      :title            => { :color => '#3b5998', :font => ApplicationConfig.sharedConfig.fontOfSize(15) },
      :hotentry_title   => { :color => '#000',    :font => ApplicationConfig.sharedConfig.fontOfSize(15) },
      :comment          => { :color => '#000',    :font => ApplicationConfig.sharedConfig.fontOfSize(15) },
      :date             => { :color => '#999',    :font => UIFont.systemFontOfSize(13) },
      :host             => { :color => '#999',    :font => UIFont.systemFontOfSize(13) },
    }
  end
end
