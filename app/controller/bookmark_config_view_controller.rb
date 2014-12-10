# -*- coding: utf-8 -*-
class BookmarkConfigViewController < Formotion::FormController
  def init
    if self
      user = ApplicationUser.sharedUser
      form = Formotion::Form.new(
        {
          sections: [
            {
              title: "コメントなし非表示",
              rows: [
                {
                  title: "コメントなしを非表示",
                  key: 'hide_nocomment_bookmarks',
                  type: 'switch',
                  value: user.hide_nocomment_bookmarks?
                },
              ],
              footer: "有効にすると、ブックマークの一覧ページでコメントが記載されていないブックマークを非表示にします。"
            }
          ]
        }
      )
      return self.class.alloc.initWithForm(form)
    end
  end

  def viewDidLoad
    super
    self.navigationItem.title = "設定"
    self.view.backgroundColor = UIColor.groupTableViewBackgroundColor
  end

  def viewWillAppear(animated)
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

    super
  end

  def cancel
    self.dismissModalViewControllerAnimated(true, completion:nil)
  end

  def save
    data = self.form.render
    user = ApplicationUser.sharedUser
    user.hide_nocomment_bookmarks = data["hide_nocomment_bookmarks"]
    user.save
    self.dismissModalViewControllerAnimated(true, completion:nil)
  end

  def dealloc
    NSLog("dealloc: " + self.class.name)
    super
  end
end
