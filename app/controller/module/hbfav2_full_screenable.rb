# -*- coding: utf-8 -*-
module HBFav2
  module FullScreenable
    def prepare_fullscreen
      @fullscreen = false
      if UIDevice.currentDevice.ios7_or_later?
        # self.extendedLayoutIncludesOpaqueBars = false
      else
        self.navigationController.setToolbarHidden(true, animated:true)
        self.navigationController.setNavigationBarHidden(false, animated:false)
        self.navigationController.navigationBar.translucent = true
        self.navigationController.toolbar.translucent = true
        UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleBlackTranslucent
        self.wantsFullScreenLayout = true
      end
    end

    def cleanup_fullscreen
      @fullscreen = false
      unless UIDevice.currentDevice.ios7_or_later?
        self.navigationController.setNavigationBarHidden(false, animated:false)
        self.navigationController.navigationBar.translucent = false
        self.navigationController.toolbar.translucent = false
        UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleBlackOpaque
        self.wantsFullScreenLayout = false
      end
    end

    def toggle_fullscreen(recog)
      if (recog.state == UIGestureRecognizerStateEnded)
        @fullscreen = !@fullscreen
        @fullscreen ? begin_fullscreen : end_fullscreen
      end
    end

    def begin_fullscreen
      ## navigationController がある == まだ生き残ってる
      if navigationController.present?
        @fullscreen = true

        if UIDevice.currentDevice.ios7_or_later?
          self.navigationController.setNavigationBarHidden(true, animated:true)
          UIApplication.sharedApplication.setStatusBarHidden(true, withAnimation:UIStatusBarAnimationFade)
        else
          UIView.beginAnimations(nil, context:nil)
          UIView.setAnimationDuration(0.3)
          UIApplication.sharedApplication.setStatusBarHidden(true, animated:true)
          navigationController.navigationBar.alpha = 0.0
          UIView.commitAnimations
        end
      end
    end

    def end_fullscreen
      @fullscreen = false
      if UIDevice.currentDevice.ios7_or_later?
        self.navigationController.setNavigationBarHidden(false, animated:true)
        UIApplication.sharedApplication.setStatusBarHidden(false, withAnimation:UIStatusBarAnimationFade)
      else
        UIView.beginAnimations(nil, context:nil)
        UIView.setAnimationDuration(0.3)
        UIApplication.sharedApplication.setStatusBarHidden(false, animated:true)
        if navigationController.present?
          navigationController.navigationBar.alpha = 1.0
        end
        UIView.commitAnimations
      end
    end
  end
end
