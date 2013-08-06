# -*- coding: utf-8 -*-
class LeftViewController < UITableViewController
  def viewDidLoad
    super
    ApplicationUser.sharedUser.addObserver(self, forKeyPath:'hatena_id', options:0, context:nil)

    self.title = "メニュー"
    # self.view.backgroundColor = [50, 57, 73].uicolor
    self.view.backgroundColor = [41, 47, 59].uicolor
    self.view.separatorColor = [36, 42, 54].uicolor

    @timeline = self.sidePanelController.centerPanel
    @dataSource = initialize_controllers_for(ApplicationUser.sharedUser.to_bookmark_user)
  end

  def initialize_controllers_for(user)
    ## initialize navigation controllers
    @bookmark = HBFav2NavigationController.alloc.initWithRootViewController(
      TimelineViewController.new.tap do |c|
        c.user  = user
        c.content_type = :bookmark
        c.title = user.name
        c.as_home  = true
      end
    )

    @hotentry = HBFav2NavigationController.alloc.initWithRootViewController(
      HotentryViewController.new.tap { |c| c.list_type = :hotentry }
    )

    @entrylist = HBFav2NavigationController.alloc.initWithRootViewController(
      HotentryViewController.new.tap { |c| c.list_type = :entrylist }
    )

    @config = HBFav2NavigationController.alloc.initWithRootViewController(
      AccountViewController.new
    )

    return [
      {
        :title      => user.name,
        :controller => @config,
        :image      => profile_image_for(user)
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

  def profile_image_for(user)
    UIImageView.new.tap do |iv|
      iv.setImageWithURL(
        user.profile_image_url.nsurl,
        placeholderImage:UIImage.imageNamed("profile_placeholder"),
        completed:lambda do |image, error, cacheType|
          ## FIXME: セルだけ更新すればいい
          NSLog("RELOAD")
          self.tableView.reloadData
        end
      )
    end
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

  def observeValueForKeyPath(keyPath, ofObject:object, change:change, context:context)
    if (ApplicationUser.sharedUser == object and keyPath == 'hatena_id')
      ## FIXME: 生データいじりすぎてて微妙
      row = @dataSource[0]
      user = ApplicationUser.sharedUser.to_bookmark_user
      row[:title] = user.name
      row[:image] = profile_image_for(user)
      tableView.reloadData
    end
  end

  def dealloc
    ApplicationUser.sharedUser.removeObserver(self, forKeyPath:'hatena_id')
    super
  end
end
