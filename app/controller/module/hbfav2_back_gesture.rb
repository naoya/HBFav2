module HBFav2
  module BackGesture
    def configure_back_gesture
      if UIDevice.currentDevice.ios7_or_later?
        self.backGestureEnabled = false
        return
      end

      if home?
        self.backGestureEnabled = false
      else
        self.backGestureEnabled = true
      end
    end
  end
end
