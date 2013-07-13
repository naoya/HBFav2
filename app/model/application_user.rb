# -*- coding: utf-8 -*-
class ApplicationUser
  attr_accessor :hatena_id, :password, :use_timeline

  def self.sharedUser
    Dispatch.once { @instance ||= new }
    @instance
  end

  def save
    App::Persistence['hatena_id'] = @hatena_id
    App::Persistence['use_timeline'] = @use_timeline
    if @hatena_id
      if @password
        SSKeychain.setPassword(@password, forService:'HBFav2', account: @hatena_id)
      else
        SSKeychain.deletePasswordForService('HBFav2', account: @hatena_id)
      end
    end
    self
  end

  def load
    self.hatena_id = App::Persistence['hatena_id']
    self.use_timeline = App::Persistence['use_timeline']
    self.password = SSKeychain.passwordForService('HBFav2', account: self.hatena_id)
    self
  end

  def configured?
    self.hatena_id ? true : false
  end

  def use_timeline?
    self.use_timeline ? true : false
  end

  def to_bookmark_user
    User.new({ :name => @hatena_id, :use_timeline => @use_timeline })
  end
end
