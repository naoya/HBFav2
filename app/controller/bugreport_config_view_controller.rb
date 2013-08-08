# -*- coding: utf-8 -*-
class BugreportConfigViewController < Formotion::FormController
  def init
    if self
      user = ApplicationUser.sharedUser
      form = Formotion::Form.new(
        {
          sections: [
            {
              title: "クラッシュレポート",
              rows: [
                {
                  title: "レポートを送信",
                  key: 'send_bugreport',
                  type: 'switch',
                  value: user.send_bugreport?
                },
              ],
              footer: "アプリがクラッシュした際、サーバーにレポートを送信しても良い場合は有効にしてください。設定は再起動後に反映されます。"
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

    ## JASlidePanels の初期化タイミングでボタンスタイルが当たらないので明示的にセット
    if self.navigationItem.leftBarButtonItem
      self.navigationItem.leftBarButtonItem.styleClass = 'navigation-button'
    end

    super
  end

  def cancel
    self.dismissModalViewControllerAnimated(true, completion:nil)
  end

  def save
    data = self.form.render
    user = ApplicationUser.sharedUser
    user.send_bugreport = data["send_bugreport"]
    user.save
    self.dismissModalViewControllerAnimated(true, completion:nil)
  end

  def dealloc
    NSLog("dealloc: " + self.class.name)
    super
  end
end
