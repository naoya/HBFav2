# -*- coding: utf-8 -*-
class ProfileViewController < UIViewController
  attr_accessor :user

  def viewDidLoad
    super

    self.navigationItem.title = @user.name
    self.backGestureEnabled = true
    self.navigationItem.backBarButtonItem = UIBarButtonItem.titled("戻る")

    @dataSource = [
      {
        :title => nil,
        :rows  => [
          {
            :label         => "ブックマーク",
            :accessoryType => UITableViewCellAccessoryDisclosureIndicator,
            :action        => 'open_bookmarks'
          },
          {
            :label         => "フォロー",
            :accessoryType => UITableViewCellAccessoryDisclosureIndicator,
            :action        => 'open_timeline'
          },
        ]
      },
    ]

    @profile_view = HBFav2::ProfileView.new
    @profile_view.menuTable.dataSource = @profile_view.menuTable.delegate = self
    view << @profile_view
  end

  def viewWillAppear(animated)
    super
    self.navigationController.setToolbarHidden(true, animated:animated)
    @profile_view.frame = self.view.bounds
    @profile_view.user  = @user
    @profile_view.menuTable.deselectRowAtIndexPath(@profile_view.menuTable.indexPathForSelectedRow, animated:animated)
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    id = "basis-cell"
    rowData = @dataSource[indexPath.section][:rows][indexPath.row]

    cell = tableView.dequeueReusableCellWithIdentifier(id) || UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:id)
    cell.textLabel.text = rowData[:label]

    if (color = rowData[:color])
      cell.textLabel.textColor = color
    end

    if (accessory = rowData[:accessoryType])
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

  def numberOfSectionsInTableView (tableView)
    @dataSource.size
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    if (action = @dataSource[indexPath.section][:rows][indexPath.row][:action])
      self.send(action)
    end
  end

  def open_bookmarks
    self.navigationController.pushViewController(
      TimelineViewController.new.tap do |c|
        c.user  = user
        c.content_type = :bookmark
        c.title = user.name
      end,
      animated:true
    )
  end

  def open_timeline
    self.navigationController.pushViewController(
      TimelineViewController.new.tap do |c|
        c.user  = user
        c.title = user.name
      end,
      animated:true
    )
  end

  def dealloc
    NSLog("dealloc: " + self.class.name)
    super
  end
end
