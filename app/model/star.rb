class Star
  attr_reader :user, :url, :color, :quote

  def initialize(dict)
    @user  = dict[:user]
    @url   = dict[:url]
    @color = dict[:color]
    @quote = dict[:quote]
  end

  def colored?
    @color.present?
  end
end
