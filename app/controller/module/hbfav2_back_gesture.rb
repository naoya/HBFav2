module HBFav2
  module BackGesture
    def configure_back_gesture
      if UIDevice.currentDevice.ios7?
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
