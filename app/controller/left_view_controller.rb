# -*- coding: utf-8 -*-
class LeftViewController < UITableViewController
  def viewDidLoad
    super
    self.title = "メニュー"
    self.view.backgroundColor = [50, 57, 73].uicolor
    self.view.separatorColor = [36, 42, 54].uicolor

    @timeline = self.sidePanelController.centerPanel
    @user = ApplicationUser.sharedUser.to_bookmark_user

    @bookmark = HBFav2NavigationController.alloc.initWithRootViewController(
      TimelineViewController.new.tap do |c|
        c.user  = @user
        c.content_type = :bookmark
        c.title = @user.name
      end
    )

    @hotentry = HBFav2NavigationController.alloc.initWithRootViewController(
      HotentryViewController.new.tap { |c| c.list_type = :hotentry }
    )

    @entrylist = HBFav2NavigationController.alloc.initWithRootViewController(
      HotentryViewController.new.tap { |c| c.list_type = :entrylist }
    )

    @config = HBFav2NavigationController.alloc.initWithRootViewController(
      ProfileViewController.new.tap do |c|
        c.user    = @user
        c.as_mine = true
      end
    )

    @dataSource = [
      {
        :title      => @user.name,
        :action     => 'open_config',
        :controller => @config,
        :image      => UIImageView.new.tap do |iv|
          iv.setImageWithURL(@user.profile_image_url.nsurl, placeholderImage:nil)
        end
      },
      {
        :title      => 'タイムライン',
        :action     => 'open_timeline',
        :controller => @timeline,
      },
      {
        :title      => 'ブックマーク',
        :action     => 'open_hotentry',
        :controller => @bookmark,
      },
      {
        :title      => '人気エントリー',
        :action     => 'open_hotentry',
        :controller => @hotentry,
      },
      {
        :title      => '新着エントリー',
        :action     => 'open_entrylist',
        :controller => @entrylist,
      },
    ]
  end

  def tableView(tableView, numberOfRowsInSection:indexPath)
    @dataSource.size
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    row = @dataSource[indexPath.row]
    cell = LeftViewCell.cellForLeftView(tableView)
    cell.textLabel.text = row[:title]
    if row[:image]
      cell.imageView.image = row[:image].image
      cell.imageView.frame = [[10, 10], [24, 24]]
    end
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
    row = @dataSource[indexPath.row]
    controller = row[:controller]
    self.sidePanelController.centerPanel = controller
  end
end
