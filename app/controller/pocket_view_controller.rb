# -*- coding: utf-8 -*-
class PocketViewController < UITableViewController
  def viewDidLoad
    super
    self.title = "設定"
    self.backGestureEnabled = true
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

  ## 以下コピペで良くない
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    id = "basis-cell"
    row = @dataSource[indexPath.section][:rows][indexPath.row]
    cell = tableView.dequeueReusableCellWithIdentifier(id) || UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:id)
    cell.textLabel.text = row[:label]
    if row[:detail]
      cell.detailTextLabel.text = row[:detail]
    end

    if (color = row[:color])
      cell.textLabel.textColor = color
    end

    if (accessory = row[:accessoryType])
      cell.accessoryType = accessory
    end

    cell
  end

  def tableView(tableView, titleForHeaderInSection:section)
    if (title = @dataSource[section][:title])
      return title
    end
  end

  def tableView(tableView, numberOfRowsInSection:section)
    @dataSource[section][:rows].size
  end

  def numberOfSectionsInTableView(tableView)
    @dataSource.size
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    if (action = @dataSource[indexPath.section][:rows][indexPath.row][:action])
      self.send(action)
    end
  end
end
