# -*- coding: utf-8 -*-
# Hack: 戻るボタン長押しを検知したい
# UIBarButtonItem には addGestureRecognizer できないので navigationBar 全体に引っかけて
# 実際に押下されたらその地点がボタンの上かどうかを調べる
class HBFav2NavigationController < UINavigationController
  attr_accessor :rounded_corners

  def initWithRootViewController(controller)
    if super
      @rounded_corners = true
    end
    self
  end

  def viewDidLoad
    super
    longPressGesture = UILongPressGestureRecognizer.alloc.initWithTarget(self, action:'backToRoot:')
    longPressGesture.delegate = self
    self.navigationBar.addGestureRecognizer(longPressGesture)
  end

  def viewWillAppear(animated)
    super

    ## naviBar の上部を丸める
    if not UIDevice.currentDevice.ios7_or_later? and self.rounded_corners
      layer = self.navigationBar.layer
      maskPath = UIBezierPath.bezierPathWithRoundedRect(
        layer.bounds,
        byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight),
        cornerRadii:CGSizeMake(5.0, 5.0)
      )
      maskLayer = CAShapeLayer.alloc.init
      maskLayer.frame = layer.bounds
      maskLayer.path = maskPath.CGPath;
      layer.addSublayer(maskLayer)
      layer.mask = maskLayer
    end
  end

  def gestureRecognizerShouldBegin(gestureRecognizer)
    ## 戻るボタンらしきものを探す
    v = self.navigationBar.subviews.find do |subview|
      subview.class.description.lowercaseString.rangeOfString("itembutton").location != NSNotFound
    end

    ## leftBarButtonItem を探す
    unless v
      v = self.navigationBar.subviews
        .select { |subview| subview.class.description =~ /button/i }
        .inject { |memo, item| memo.frame.origin.x < item.frame.origin.x ? memo : item }
    end

    if v
      point = gestureRecognizer.locationInView(v)

      # Quick Hack: ボタンは押せてるけど point が枠内に入ってないこともあるので枠を少し広げて計算させる
      # (取得できるのがあくまで中心位置なので)
      # 横幅は思いの他広い
      rect = [ [v.frame.origin.x - 5.0 , v.frame.origin.y - 6.0 ], [ v.bounds.size.width + 40, v.bounds.size.height + 15 ] ]

      # 上記理由により v.pointInside(point, withEvent:nil) ではダメ
      if CGRectContainsPoint(rect, point)
        return true
      end
    end
    false
  end

  def backToRoot(recog)
    if (recog.state == UIGestureRecognizerStateBegan)
      controller = HBFav2PanelController.sharedController.centerPanel
      if controller.presentedViewController.nil?
        self.popToRootViewControllerAnimated(true)
      else
        controller.dismissViewControllerAnimated(true, completion:
          lambda {
            controller.popToRootViewControllerAnimated(true)
          }
        )
      end
    end
  end
end
