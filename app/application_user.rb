# -*- coding: utf-8 -*-
## 最終的に iOS の Keychain に切り替える
class ApplicationUser
  attr_accessor :hatena_id, :password

  def initialize
  end

  def save
    App::Persistence['applicatoin_user'] = {
      :hatena_id => @hatena_id,
      :password  => @password
    }
    self
  end

  def load
    user = App::Persistence['applicatoin_user'] || {}
    self.hatena_id = user[:hatena_id]
    self.password  = user[:password]
    self
  end

  # def reset
  # end
end
