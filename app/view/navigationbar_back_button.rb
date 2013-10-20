# -*- coding: utf-8 -*-
class NavigationBackButton < UIBarButtonItem
  def self.create
    if UIDevice.currentDevice.ios7?
      UIBarButtonItem.titled("")
    else
      UIBarButtonItem.titled("戻る")
    end
  end
end
