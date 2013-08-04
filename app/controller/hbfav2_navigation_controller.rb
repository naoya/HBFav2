class HBFav2NavigationController < UINavigationController
  def viewDidLoad
    super
    longPressGesture = UILongPressGestureRecognizer.alloc.initWithTarget(self, action:'backToRoot:')
    longPressGesture.delegate = self
    self.navigationBar.addGestureRecognizer(longPressGesture)
  end

  def gestureRecognizerShouldBegin(gestureRecognizer)
    v = self.navigationBar.subviews.lastObject;
    if (v.class.description.lowercaseString.rangeOfString("itembutton").location != NSNotFound)
      p = gestureRecognizer.locationInView(v)
      if (CGRectContainsPoint(v.bounds, p))
        return true;
      end
    end
    return false
  end

  def backToRoot(recog)
    if (recog.state == UIGestureRecognizerStateBegan)
      self.popToRootViewControllerAnimated(true)
    end
  end
end
