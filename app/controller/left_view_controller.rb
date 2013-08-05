# -*- coding: utf-8 -*-
class LeftViewController < UITableViewController
  def viewDidLoad
    super
    self.title = "メニュー"
    self.view.backgroundColor = [50, 57, 73].uicolor
    self.view.separatorColor = [36, 42, 54].uicolor

    @timeline = self.sidePanelController.centerPanel
    @user = ApplicationUser.sharedUser.to_bookmark_user

    ## initialize navigation controllers
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

    @config = HBFav2NavigationController.alloc.initWithRootViewController(AccountViewController.new)

    @dataSource = [
      {
        :title      => @user.name,
        :controller => @config,
        :image      => UIImageView.new.tap do |iv|
          iv.setImageWithURL(@user.profile_image_url.nsurl, placeholderImage:nil)
        end
      },
      {
        :title      => 'タイムライン',
        :controller => @timeline,
        :image      => UIImage.imageNamed('insignia_star')
      },
      {
        :title      => 'ブックマーク',
        :controller => @bookmark,
        :image      => UIImage.imageNamed('insignia_tags')
      },
      {
        :title      => '人気エントリー',
        :controller => @hotentry,
        :image      => UIImage.imageNamed('insignia_heart')
      },
      {
        :title      => '新着エントリー',
        :controller => @entrylist,
        :image      => UIImage.imageNamed('insignia_file')
      },
    ]
  end

  def tableView(tableView, numberOfRowsInSection:indexPath)
    @dataSource.size
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    row = @dataSource[indexPath.row]
    cell = LeftViewCell.cellForLeftView(tableView)
    cell.fillWithProperties(row)
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
    row = @dataSource[indexPath.row]
    controller = row[:controller]
    self.sidePanelController.centerPanel = controller
  end
end
