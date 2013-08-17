# -*- coding: utf-8 -*-
module Formotion
  module RowType
    class AsciiRow <  StringRow
      def keyboardType
        UIKeyboardTypeASCIICapable
      end
    end
  end
end

class AccountConfigViewController < Formotion::FormController
  attr_accessor :allow_cancellation

  def init
    if self
      user = ApplicationUser.sharedUser
      form = Formotion::Form.new({
        sections: [{
              title: "はてなアカウント",
              rows: [
                {
                  title: "はてなID",
                  key: "hatena_id",
                  type: :ascii,
                  placeholder: '必須',
                  auto_correction: :no,
                  auto_capitalization: :none,
                  value: user.configured? ? user.hatena_id : nil
                },
                {
                  title: "パスワード",
                  key: "password",
                  type: :string,
                  secure: true,
                  value: user.configured? ? user.password : nil
                }
              ],
              footer: "非公開設定のIDは利用できません\nブックマーク投稿機能を利用しない場合パスワード入力は不要です"
            }, {
              title: "オプション",
              rows: [
                {
                  title: "新ユーザーページ",
                  key: 'use_timeline',
                  type: 'switch',
                  value: user.use_timeline?
                },
              ],
              footer: "はてな上で新ユーザーページを利用している場合のみ有効にしてください。フィードの読み込み精度が向上します"
            }]
      })
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

    ## BUG: closure から起動しているせいか viewDidLoad では
    ## allow_cancellation == true にならないので viewWillAppear で
    if self.allow_cancellation
      self.navigationItem.leftBarButtonItem  = UIBarButtonItem.alloc.initWithBarButtonSystemItem(
        UIBarButtonSystemItemCancel,
        target:self,
        action:'cancel'
      )
    end

    super
  end

  def cancel
    self.dismissModalViewControllerAnimated(true, completion:nil)
  end

  def save
    data = self.form.render
    if data["hatena_id"].blank?
      App.alert("はてなIDは必須です")
    else
      buser = User.new({ :name => data["hatena_id"] })
      buser.fetch_status do |status|
        if status == 404
          App.alert("指定されたユーザーが見つかりません")
        elsif (status == 403)
          App.alert("非公開設定のアカウントは利用できません")
        else
          user = ApplicationUser.sharedUser
          user.password  = data["password"] || nil
          user.use_timeline = data["use_timeline"]
          user.hatena_id = data["hatena_id"]
          user.save
          self.dismissModalViewControllerAnimated(true, completion:nil)
        end
      end
    end
  end

  def dealloc
    NSLog("dealloc: " + self.class.name)
    super
  end
end
