# -*- coding: utf-8 -*-
#
# Example:
# @v = ToastView.new.tap do |toast|
#   toast.frame = [[0, 0], [200, 40]]
#   toast.center = [view.bounds.size.width / 2, 300]
#   toast.textLabel.text = "保存中です..."
# end
# view << @v
#
# button = UIButton.rounded_rect.on(:touch) do
#   @v.done("完了しました")
# end

class ToastView < UIView
  attr_accessor :textLabel, :indicator

  def initWithFrame(rect)
    super

    ## indicator をテキストのちょうど左に持ってきたいが･･･
    @indicator = UIActivityIndicatorView.white.tap do |i|
      i.startAnimating
    end
    self << @indicator

    @textLabel = UILabel.new.tap do |label|
      label.textColor       = UIColor.whiteColor
      label.backgroundColor = UIColor.clearColor
      label.font            = UIFont.systemFontOfSize(13)
      label.textAlignment   = :center.uialignment
    end
    self << @textLabel

    self.opaque = false
    self.alpha = 0.8
    self.layer.cornerRadius = 10
    self.clipsToBounds = true
    self.backgroundColor = UIColor.blackColor

    return self
  end

  def done(message)
    @textLabel.text = message
    @indicator.stopAnimating
    self.fade_out(duration: 0.6, delay: 0.4) do |completed|
      self.removeFromSuperview
    end
  end

  def layoutSubviews
    @textLabel.frame = self.bounds
    @indicator.center = [ 20 , self.frame.size.height / 2 ]
  end

  def dealloc
    super
  end
end
