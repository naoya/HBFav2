# -*- coding: utf-8 -*-
## 最終的に iOS の Keychain に切り替える
class ApplicationUser
  attr_accessor :hatena_id, :password

  def initialize
  end

  def save
    App::Persistence['hatena_id'] = @hatena_id
    App::Persistence['password']  = @password
    self
  end

  def load
    user = App::Persistence['applicatoin_user'] || {}
    self.hatena_id = App::Persistence['hatena_id']
    self.password  = App::Persistence['password']
    self
  end

  # def reset
  # end
end
