# -*- coding: utf-8 -*-
class HatenaConfigViewController < UITableViewController
  include HBFav2::MenuTableDelegate

  def viewDidLoad
    super
    self.title = "設定"
    self.backGestureEnabled = true
    self.initialize_data_source
  end

  def initialize_data_source
    @dataSource = [
      {
        :title => "はてなブックマーク",
        :rows => [
          {
            :label  => "連携を解除",
            :detail => HTBHatenaBookmarkManager.sharedManager.username,
            :action => 'logout_hatena'
          },
        ],
      },
    ]
  end

  def logout_hatena
    UIActionSheet.alert('はてなブックマーク連携を解除してよろしいですか?', buttons: ['キャンセル', '解除する'],
      cancel: proc { tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow, animated:true) },
      destructive: proc do
        HTBHatenaBookmarkManager.sharedManager.logout
        self.navigationController.popViewControllerAnimated(true)
      end,
      success:nil,
    )
  end
end
