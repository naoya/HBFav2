# -*- coding: utf-8 -*-
class ApplicationUser
  attr_accessor :hatena_id, :password

  def self.sharedUser
    Dispatch.once { @instance ||= new }
    @instance
  end

  def initialize
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
end
