# -*- coding: utf-8 -*-
class ApplicationUser
  attr_accessor :hatena_id, :password

  def self.sharedUser
    Dispatch.once { @instance ||= new }
    @instance
  end

  def save
    App::Persistence['hatena_id'] = @hatena_id
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
    self.password = SSKeychain.passwordForService('HBFav2', account: self.hatena_id)
    self
  end

  def configured?
    self.hatena_id ? true : false
  end

  def to_bookmark_user
    User.new({ :name => @hatena_id })
  end
end
