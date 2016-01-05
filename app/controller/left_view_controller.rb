# -*- coding: utf-8 -*-
class LeftViewController < UITableViewController
  attr_accessor :controllers

  def viewDidLoad
    super
    ApplicationUser.sharedUser.addObserver(self, forKeyPath:'hatena_id', options:0, context:nil)
    @dataSource = initialize_data_source

    self.configure_separator_color
    @selected = [0, rowForTimeline].nsindexpath
  end

  def configure_separator_color
    self.view.backgroundColor = [41, 47, 59].uicolor
    self.view.backgroundView = nil

    if UIDevice.currentDevice.ios7_or_later?
      self.view.separatorStyle = UITableViewCellSeparatorStyleNone
    else
      self.view.separatorColor = [36, 42, 54].uicolor
    end
  end

  def initialize_data_source
    user = ApplicationUser.sharedUser.to_bookmark_user
    src = [
      {
        :title      => user.name,
        :controller => HBFav2NavigationController.alloc.initWithRootViewController(controllers[:account]),
        :image      => profile_image_for(user)
      },
      {
        :title      => 'タイムライン',
        :controller => self.sidePanelController.centerPanel,
        :image      => UIImage.imageNamed('insignia_star')
      },
      {
        :title      => 'ブックマーク',
        :controller => HBFav2NavigationController.alloc.initWithRootViewController(controllers[:bookmarks]),
        :image      => UIImage.imageNamed('insignia_tags')
      },
      {
        :title      => '人気エントリー',
        :controller => HBFav2NavigationController.alloc.initWithRootViewController(controllers[:hotentry]),
        :image      => UIImage.imageNamed('insignia_heart')
      },
      {
        :title      => 'カテゴリ',
        :controller => HBFav2NavigationController.alloc.initWithRootViewController(controllers[:category]),
        :image      => UIImage.imageNamed('insignia_file')
      },      
#      {
#        :title      => '新着エントリー',
#        :controller => HBFav2NavigationController.alloc.initWithRootViewController(controllers[:entrylist]),
#        :image      => UIImage.imageNamed('insignia_file')
#      },
      {
        :title      => "アプリについて",
        :controller => HBFav2NavigationController.alloc.initWithRootViewController(controllers[:appInfo]),
        :image      => UIImage.imageNamed('default_app_logo')
      }
    ]

    ## FIXME: ステータスバー分を空の row でごまかしている･･･
    if UIDevice.currentDevice.ios7_or_later?
      src.unshift({ :title => "", :blank => true })
    end

    return src
  end

  def profile_image_for(user)
    UIImageView.new.tap do |iv|
      iv.setImageWithURLRequest(user.profile_image_url.nsurl.request, placeholderImage:UIImage.imageNamed("profile_placeholder"),
        success: lambda do |request, response, image|
          iv.image = image
          self.tableView.reloadRowsAtIndexPaths([[0, rowForProfile].nsindexpath], withRowAnimation:UITableViewRowAnimationNone)
        end,
        failure: lambda { |request, response, error| }
      )
    end
  end

  def rowForProfile
    UIDevice.currentDevice.ios7_or_later? ? 1 : 0
  end

  def rowForTimeline
    rowForProfile + 1
  end

  def viewWillAppear(animated)
    super
    self.configure_separator_color
    if tableView.indexPathForSelectedRow.nil?
      tableView.selectRowAtIndexPath(@selected, animated:true, scrollPosition:UITableViewScrollPositionNone);
    end
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    if UIDevice.currentDevice.ios7_or_later? and indexPath.row == 0
      21
    else
      super
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
    self.sidePanelController.centerPanel = controller if controller
  end

  def observeValueForKeyPath(keyPath, ofObject:object, change:change, context:context)
    if (ApplicationUser.sharedUser == object and keyPath == 'hatena_id')
      ## FIXME: 生データいじりすぎてて微妙
      row = if UIDevice.currentDevice.ios7_or_later?
              @dataSource[1]
            else
              @dataSource[0]
            end

      user = ApplicationUser.sharedUser.to_bookmark_user
      row[:title] = user.name
      row[:image] = profile_image_for(user)
      tableView.reloadData
    end
  end

  def willAnimateRotationToInterfaceOrientation(orientation, duration:duration)
    self.view.reloadData
  end

  def viewWillTransitionToSize(size, withTransitionCoordinator:coordinator)
    self.view.reloadData
  end

  def dealloc
    ApplicationUser.sharedUser.removeObserver(self, forKeyPath:'hatena_id')
    super
  end
end
