# -*- coding: utf-8 -*-
class Bookmark
  attr_reader :title, :profile_image_url, :link, :user_name, :created_at, :comment, :user, :count, :datetime
  attr_accessor :profile_image, :favicon, :row

  def self.date_formatter
    @@date_formatter ||= NSDateFormatter.new.tap do |f|
      f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
    end
  end

  def initialize(dict)
    @title             = dict[:title]
    @link              = dict[:link]
    @user_name         = dict[:user][:name]
    @created_at        = dict[:created_at]
    @comment           = dict[:comment]
    @profile_image_url = dict[:user][:profile_image_url]
    @profile_image     = nil
    # @favicon_url       = dict[:favicon_url]
    @favicon           = nil
    @row               = nil

    @count             = Count.new(dict[:count].to_i)
    @user = User.new({:name => @user_name})
    @datetime = self.class.date_formatter.dateFromString(dict[:datetime])
  end

  def id
    @id ||= self.user_name + "-" + self.datetime.timeIntervalSince1970.to_i.to_s
  end

  class Count
    attr_reader :count

    def initialize(n)
      @count = n
    end

    def to_s
      @count == 1 ? "#{@count} user" : "#{@count} users"
    end
  end

  def favicon_url
    return "http://favicon.st-hatena.com/?url=#{@link}"
  end
end
