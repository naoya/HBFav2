# -*- coding: utf-8 -*-
class ApplicationUser
  attr_accessor :hatena_id, :password

  def self.sharedUser
    Dispatch.once { @instance ||= new }
    @instance
  end

  def save
    App::Persistence['hatena_id'] = @hatena_id
    App::Persistence['hatena_password']  = @password
    self
  end

  def load
    self.hatena_id = App::Persistence['hatena_id']
    self.password  = App::Persistence['hatena_password']
    self
  end

  def configured?
    self.hatena_id ? true : false
  end

  def to_bookmark_user
    User.new({ :name => @hatena_id })
  end
end
