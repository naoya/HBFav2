# -*- coding: utf-8 -*-
class NavigationBackButton < UIBarButtonItem
  def self.create
    if UIDevice.currentDevice.ios7_or_later?
      UIBarButtonItem.titled("")
    else
      UIBarButtonItem.titled("戻る")
    end
  end
end
