# -*- coding: utf-8 -*-
class NotificationConfigViewController < Formotion::FormController
  def init
    if self
      user = ApplicationUser.sharedUser
      form = Formotion::Form.new(
        {
          sections: [
            {
              title: "プッシュ通知",
              rows: [
                title: "Webhookキー",
                key: "webhook_key",
                type: :ascii,
                placeholder: '必須',
                auto_correction: :no,
                auto_capitalization: :none,
                value: user.webhook_key
              ],
              footer:
              "1. 任意の文字列を指定してください\n" +
              "(平文でやり取りされるのでパスワード文字列は利用しないでください)\n\n" +
              "2. はてなブックマーク本体の Webhook 設定の「イベント通知URL」に http://push.hbfav.com/#{user.hatena_id} を、「キー」にここで入力したのと同じ文字列をそれぞれ設定してください\n\n" +
              "3. 通知して欲しいイベント種類の設定などは、はてなブックマーク本体で行ってください"
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
    # self.view.backgroundColor = UIColor.groupTableViewBackgroundColor
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
    if data["webhook_key"].blank?
      App.alert("キーは必須です")
    else
      user = ApplicationUser.sharedUser
      user.webhook_key = data["webhook_key"]
      user.save

      UIApplication.sharedApplication.registerForRemoteNotificationTypes(
        UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound
      )

      self.dismissModalViewControllerAnimated(true, completion:nil)
    end
  end
end
