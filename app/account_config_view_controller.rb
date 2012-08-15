# -*- coding: utf-8 -*-
class AccountConfigViewController < UIViewController
  def viewDidLoad
    super

    self.navigationItem.title = "設定"
    self.view.backgroundColor = UIColor.groupTableViewBackgroundColor

    self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(
      UIBarButtonSystemItemSave,
      target:self,
      action:'save'
    )

    self.navigationItem.leftBarButtonItem  = UIBarButtonItem.alloc.initWithBarButtonSystemItem(
      UIBarButtonSystemItemCancel,
      target:self,
      action:'cancel'
    )
  end

  def cancel
    self.dismissModalViewControllerAnimated(true)
  end

  def save
    self.dismissModalViewControllerAnimated(true)
  end
end
