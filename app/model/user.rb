class User
  attr_accessor :name, :use_timeline

  def initialize(dict)
    @name = dict[:name]
    @use_timeline = dict[:use_timeline]
  end

  def profile_image_url(small = false)
    if small
      return "http://www.st-hatena.com/users/" + @name[0, 2] + "/#{name}/profile_l.gif"
    else
      return "http://www.st-hatena.com/users/" + @name[0, 2] + "/#{name}/profile.gif"
    end
  end

  def fetch_status(&block)
    BW::HTTP.head("http://b.hatena.ne.jp/#{@name}") do |response|
      block.call(response.status_code)
    end
  end

  def use_timeline?
    self.use_timeline ? true : false
  end

  def timeline_feed_url
    return "http://feed.hbfav.com/#{@name}"
  end

  def bookmark_feed_url
    return "http://feed.hbfav.com/#{@name}/bookmark"
  end

  # def dealloc
  #  NSLog("dealloc: " + self.class.name)
  #  super
  # end
end
