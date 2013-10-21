# -*- coding: utf-8 -*-
class PocketViewController < HBFav2::UITableViewController
  include HBFav2::MenuTableDelegate

  def viewDidLoad
    super
    self.title = "設定"
    self.initialize_data_source
  end

  def initialize_data_source
    @dataSource = [
      {
        :title => "Pocket",
        :rows => [
          {
            :label  => "Pocket連携を解除",
            :detail => PocketAPI.sharedAPI.username,
            :action => 'logout_pocket'
          },
        ],
      },
    ]
  end

  def logout_pocket
    UIActionSheet.alert('Pocket連携を解除してよろしいですか?', buttons: ['キャンセル', '解除する'],
      cancel: proc { tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow, animated:true) },
      destructive: proc do
        PocketAPI.sharedAPI.logout
        self.navigationController.popViewControllerAnimated(true)
      end,
      success:nil,
    )
  end
end
