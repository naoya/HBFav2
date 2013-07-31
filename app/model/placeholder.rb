class Placeholder
  attr_accessor :datetime, :index

  def initialize(i, dt)
    @index    = i
    @datetime = dt
  end

  def id
    @id ||= "placeholder-#{@index}"
  end
end
