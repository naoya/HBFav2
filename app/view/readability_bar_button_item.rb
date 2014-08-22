class ReadabilityBarButtonItem < UIBarButtonItem
  def initWithTarget(target, action:action)
    self.initWithCustomView(
      UIButton.custom.tap do |btn|
        if UIDevice.currentDevice.ios7_or_later?
          btn.frame = [[0, 0], [24, 24]]
          btn.setImage(UIImage.imageNamed('readability-ios7'), forState: :normal.uicontrolstate)
        else
          btn.frame = [[0, 0], [38, 38]]
          btn.setImage(UIImage.imageNamed('readability'), forState: :normal.uicontrolstate)
        end
        btn.showsTouchWhenHighlighted = true
        btn.addTarget(target, action:action, forControlEvents:UIControlEventTouchUpInside)
      end
    )
    self
  end
end
