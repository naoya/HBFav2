class BookmarkBarButtonItem < UIBarButtonItem
  def initWithTarget(target, action:action)
    self.initWithCustomView(
      UIButton.custom.tap do |btn|
        btn.frame = [[0, 0], [25, 25]]
        btn.showsTouchWhenHighlighted = true
        btn.setImage(UIImage.imageNamed('bookmark-add-icon-mini'), forState: :normal.uicontrolstate)
        btn.addTarget(target, action:action, forControlEvents:UIControlEventTouchUpInside)
      end
    )
    self
  end
end
