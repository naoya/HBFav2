# -*- coding: utf-8 -*-
class CategoryViewController < UITableViewController
  attr_accessor :current_category, :hotentry_controller
  def viewDidLoad
    super
    self.title = "カテゴリ"
    @dataSource = CategoryList.sharedCategories.to_datasource
  end

  def viewWillAppear(animated)
    super
    self.navigationItem.leftBarButtonItem  = UIBarButtonItem.titled("戻る").tap do |btn|
      btn.action = 'on_close'
      btn.target = self
      btn.styleClass = 'navigation-button'
    end
  end

  def tableView(tableView, numberOfRowsInSection:indexPath)
    @dataSource.size
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    id = "category-cell"
    row = @dataSource[indexPath.row]

    cell = tableView.dequeueReusableCellWithIdentifier(id) ||
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:id)
    cell.textLabel.text = row[:title]

    if self.current_category == row[:key]
      cell.accessoryType = UITableViewCellAccessoryCheckmark
    else
      cell.accessoryType = UITableViewCellAccessoryNone
    end
    cell
  end

  def tableView(tableView, titleForHeaderInSection:section)
    "カテゴリを選択"
  end

  def numberOfSectionsInTableView(tableView)
    1
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    row = @dataSource[indexPath.row]
    self.current_category = row[:key]

    ## ここでシステムのカテゴリ切り替え
    # Observer の方がいいかな
    self.hotentry_controller.category = self.current_category
    self.hotentry_controller.clear_entries
    self.dismissViewControllerAnimated(true, completion:lambda do
      self.hotentry_controller.load_hotentry
    end)
  end

  def on_close
    self.dismissViewControllerAnimated(true, completion:nil)
  end

  def dealloc
    NSLog("dealloc: " + self.class.name)
    super
  end
end
