class BookmarkLabelAttributes
  attr_reader :attributes

  def self.sharedAttributes
    Dispatch.once { @instance ||= new }
    @instance
  end

  def initialize
    @attributes = {
      :name    => { :color => '#000',    :font => UIFont.boldSystemFontOfSize(15) },
      :title   => { :color => '#3b5998', :font => UIFont.systemFontOfSize(14) },
      :comment => { :color => '#000',    :font => UIFont.systemFontOfSize(14) },
      :date    => { :color => '#999',    :font => UIFont.systemFontOfSize(12) },
    }
  end
end
