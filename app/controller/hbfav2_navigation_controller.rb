# -*- coding: utf-8 -*-
# Hack: 戻るボタン長押しを検知したい
# UIBarButtonItem には addGestureRecognizer できないので navigationBar 全体に引っかけて
# 実際に押下されたらその地点がボタンの上かどうかを調べる
class HBFav2NavigationController < UINavigationController
  def viewDidLoad
    super
    longPressGesture = UILongPressGestureRecognizer.alloc.initWithTarget(self, action:'backToRoot:')
    longPressGesture.delegate = self
    self.navigationBar.addGestureRecognizer(longPressGesture)
  end

  def gestureRecognizerShouldBegin(gestureRecognizer)
    ## 戻るボタンらしきものを探す
    v = self.navigationBar.subviews.find do |subview|
      subview.class.description.lowercaseString.rangeOfString("itembutton").location != NSNotFound
    end

    ## そのボタンの枠内が押されていたら true
    if v
      point = gestureRecognizer.locationInView(v)
      NSLog("[#{point.x}, #{point.y}]")
      NSLog("[#{v.frame.origin.x}, #{v.frame.origin.y}], [#{v.frame.size.width}, #{v.frame.size.height}]")

      # Quick Hack: ボタンは押せてるけど point が枠内に入ってないこともあるので枠を少し広げて計算させる
      # (取得できるのがあくまで中心位置なので)
      # 横幅は思いの他広い
      rect = [ [v.frame.origin.x - 5.0 , v.frame.origin.y - 6.0 ], [ v.bounds.size.width + 40, v.bounds.size.height + 15 ] ]

      # 上記理由により v.pointInside(point, withEvent:nil) ではダメ
      if CGRectContainsPoint(rect, point)
        return true
      else
        NSLog("おおっと")
      end
    end
    false
  end

  def backToRoot(recog)
    if (recog.state == UIGestureRecognizerStateBegan)
      self.popToRootViewControllerAnimated(true)
    end
  end
end
