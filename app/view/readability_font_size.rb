class ReadabilityFontSize
  attr_reader :sizes

  def self.sharedFontSize
    Dispatch.once { @instance ||= new }
    @instance
  end

  def initialize
    @sizes = [
      100,
      95,
      90,
      100,
      105,
      110,
    ]
  end

  def size
    i = App::Persistence['readability_font_size'] || 0
    @sizes[i]
  end

  def nextSize
    i = App::Persistence['readability_font_size'] || 0
    i += 1
    if (i == @sizes.size)
      i = 0
    end
    App::Persistence['readability_font_size'] = i
    @sizes[i]
  end
end
