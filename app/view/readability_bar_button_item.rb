class ReadabilityBarButtonItem < UIBarButtonItem
  def initWithTarget(target, action:action)
    self.initWithCustomView(
      UIButton.custom.tap do |btn|
        btn.frame = [[0, 0], [38, 38]]
        btn.showsTouchWhenHighlighted = true
        btn.setImage(UIImage.imageNamed('readability'), forState: :normal.uicontrolstate)
        btn.addTarget(target, action:action, forControlEvents:UIControlEventTouchUpInside)
      end
    )
    self
  end
end
