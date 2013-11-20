class Placeholder
  attr_accessor :datetime

  def initialize(id, dt)
    @id_      = id
    @datetime = dt
  end

  def id
    @id ||= "placeholder-#{@id_}"
  end
end
