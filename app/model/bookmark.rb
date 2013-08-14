# -*- coding: utf-8 -*-
class Bookmark
  attr_reader :title, :profile_image_url, :link, :user_name, :created_at, :comment, :user, :count, :datetime, :thumbnail_url, :category

  def self.date_formatter
    @@date_formatter ||= NSDateFormatter.new.tap do |f|
      f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
    end
  end

  def initialize(dict)
    @eid          = dict[:eid]
    @title        = dict[:title]
    @link         = dict[:link]
    @created_at   = dict[:created_at]
    @comment      = dict[:comment]
    @permalink    = dict[:permalink]
    @thumbnail_url = dict[:thumbnail_url]
    @category     = dict[:category]

    unless dict[:count].nil?
      @count = Count.new(dict[:count].to_i)
    end

    if dict[:user]
      @user              = User.new({:name => dict[:user][:name]})
      @user_name         = dict[:user][:name]
      @profile_image_url = dict[:user][:profile_image_url]
    end

    if dict[:datetime]
      @datetime = self.class.date_formatter.dateFromString(dict[:datetime])
    end
  end

  def id
    @id ||= self.permalink
  end

  def permalink
    if @permalink.present?
      return @permalink
    else
      formatter = NSDateFormatter.new
      formatter.dateFormat = "yyyyMMdd"
      yyyymmdd = formatter.stringFromDate(self.datetime)
      @permalink = "http://b.hatena.ne.jp/#{@user_name}/#{yyyymmdd}#bookmark-#{@eid}"
    end
  end

  class Count
    attr_reader :count

    def initialize(n)
      @count = n
    end

    def to_i
      @count
    end

    def to_s
      @count == 1 ? "#{@count} user" : "#{@count} users"
    end
  end

  def favicon_url
    return "http://favicon.st-hatena.com/?url=#{@link}"
  end

  def dealloc
    NSLog("dealloc: " + self.class.name)
    super
  end
end
