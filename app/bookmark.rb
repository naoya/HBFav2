class Bookmark
  attr_reader :title, :profile_image_url, :link, :user_name, :created_at, :comment
  attr_accessor :profile_image, :row

  def initialize(dict)
    @title             = dict[:title]
    @link              = dict[:link]
    @user_name         = dict[:user][:name]
    @created_at        = dict[:created_at]
    @comment           = dict[:comment]
    @profile_image_url = dict[:user][:profile_image_url]
    @profile_image     = nil
    @row               = nil
  end
end
