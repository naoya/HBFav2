# -*- coding: utf-8 -*-
class CategoryViewController < HBFav2::UITableViewController
  attr_accessor :current_category, :list_type
  def viewDidLoad
    super
    self.title = list_type == :hotentry ? "人気エントリー" : "新着エントリー"
    self.tracked_view_name = "Category"
    @dataSource = CategoryList.sharedCategories.to_datasource
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
    controller = HotentryViewController.new.tap do |c|
      c.list_type = list_type
      c.as_home   = false
      c.category  = self.current_category
    end
    self.navigationController.pushViewController(controller, animated:true)
  end
end
