# -*- coding: utf-8 -*-
class LeftViewController < UITableViewController
  def viewDidLoad
    super
    ApplicationUser.sharedUser.addObserver(self, forKeyPath:'hatena_id', options:0, context:nil)

    self.title = "メニュー"
    @dataSource = initialize_controllers_for(ApplicationUser.sharedUser.to_bookmark_user)

    # self.view.backgroundColor = [50, 57, 73].uicolor
    self.view.backgroundColor = [41, 47, 59].uicolor
    self.view.separatorColor = [36, 42, 54].uicolor

    @selected = [0, 1].nsindexpath
  end

  def initialize_controllers_for(user)
    ## initialize navigation controllers
    @timeline = self.sidePanelController.centerPanel

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

    @appinfo = HBFav2NavigationController.alloc.initWithRootViewController(
      AppInfoViewController.new
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
      {
        :title      => "アプリについて",
        :controller => @appinfo,
        :image      => UIImage.imageNamed('default_app_logo')
      }
    ]
  end

  def profile_image_for(user)
    UIImageView.new.tap do |iv|
      iv.setImageWithURL(
        user.profile_image_url.nsurl,
        placeholderImage:UIImage.imageNamed("profile_placeholder"),
        completed:lambda do |image, error, cacheType|
          self.tableView.reloadRowsAtIndexPaths([[0, 0].nsindexpath], withRowAnimation:UITableViewRowAnimationNone)
        end
      )
    end
  end

  def viewWillAppear(animated)
    super
    if tableView.indexPathForSelectedRow.nil?
      tableView.selectRowAtIndexPath(@selected, animated:true, scrollPosition:UITableViewScrollPositionNone);
    end
  end

  def tableView(tableView, numberOfRowsInSection:indexPath)
    if @dataSource.present?
      @dataSource.size
    else
      0
    end
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    row = @dataSource[indexPath.row]
    cell = LeftViewCell.cellForLeftView(tableView)
    cell.fillWithProperties(row)
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    @selected = indexPath
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
