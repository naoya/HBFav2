# -*- coding: utf-8 -*-
class HBFav2PanelController < JASidePanelController
  def self.sharedController
    Dispatch.once { @instance ||= new }
    @instance
  end

  ## 上角だけ丸める : 有効にすると画面全体が Offscreen Rendered になって重い･･･
  def stylePanel(panel)
    # maskPath = UIBezierPath.bezierPathWithRoundedRect(
    #   panel.bounds,
    #   byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight),
    #   cornerRadii:CGSizeMake(5.0, 5.0)
    # )

    # maskLayer = CAShapeLayer.alloc.init
    # maskLayer.frame = panel.bounds
    # maskLayer.path = maskPath.CGPath;
    # panel.layer.mask = maskLayer
    # panel.clipsToBounds = true
  end
end
