# -*- coding: utf-8 -*-
class Bookmark
  attr_reader :title, :profile_image_url, :link, :user_name, :created_at, :comment, :favicon_url, :user, :count
  attr_accessor :profile_image, :favicon, :row

  def initialize(dict)
    @title             = dict[:title]
    @link              = dict[:link]
    @user_name         = dict[:user][:name]
    @created_at        = dict[:created_at]
    @comment           = dict[:comment]
    @profile_image_url = dict[:user][:profile_image_url]
    @profile_image     = nil
    @favicon_url       = dict[:favicon_url]
    @favicon           = nil
    @row               = nil
    @count             = Count.new(dict[:count].to_i)

    @user = User.new({:name => @user_name})
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
end
