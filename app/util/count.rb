class Count
  attr_reader :count

  def initialize(n)
    @count = n
  end

  def to_i
    @count
  end

  def to_s(unit = "user")
    @count <= 1 ? "#{@count} #{unit}" : "#{@count} #{unit}s"
  end
end
