module HBFav2
  module HomeCondition
    attr_accessor :as_home
    def home?
      as_home ? true : false
    end
  end
end
