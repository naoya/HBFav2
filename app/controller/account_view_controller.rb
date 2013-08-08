# -*- coding: utf-8 -*-
class AccountViewController < UIViewController
  def viewDidLoad
    super

    ApplicationUser.sharedUser.addObserver(self, forKeyPath:'hatena_id', options:0, context:nil)
    @user = ApplicationUser.sharedUser.to_bookmark_user
    self.navigationItem.title = @user.name
    self.navigationItem.backBarButtonItem = UIBarButtonItem.titled("戻る")

    ## 背景
    view << UITableView.alloc.initWithFrame(view.bounds, style:UITableViewStyleGrouped)
    self.initialize_data_source

    @imageView = UIImageView.new.tap do |v|
      v.frame = [[10, 10], [48, 48]]
      v.layer.tap do |l|
        l.masksToBounds = true
        l.cornerRadius  = 5.0
      end
      v.setImageWithURL(@user.profile_image_url.nsurl, placeholderImage:nil)
      view << v
    end

    @nameLabel = UILabel.new.tap do |v|
      v.frame = [[68, 10], [200, 48]]
      v.font  = UIFont.boldSystemFontOfSize(18)
      v.text  = @user.name
      v.shadowColor = UIColor.whiteColor
      v.shadowOffset = [0, 1]
      v.backgroundColor = UIColor.clearColor
      view << v
    end

    @menuTable = UITableView.alloc.initWithFrame([[0, 59], self.view.bounds.size], style:UITableViewStyleGrouped).tap do |v|
      v.dataSource = v.delegate = self
      view << v
    end
  end

  def initialize_data_source
    @dataSource = [
      {
        :title => "設定",
        :rows => [
          {
            :label  => "はてなアカウント",
            :detail => ApplicationUser.sharedUser.hatena_id,
            :action => 'open_hatena_config'
          },
          {
            :label  => 'クラッシュレポート',
            :detail => ApplicationUser.sharedUser.send_bugreport? ? "オン" : "オフ",
            :action => 'open_bugreport_config',
          }
        ],
      },
      {
        :title => "外部サービス",
        :rows => [
          {
            :label  => "Pocket",
            :detail => PocketAPI.sharedAPI.username || "未設定",
            :action => 'open_pocket',
            :accessoryType => PocketAPI.sharedAPI.loggedIn? ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone
          },
        ]
      }
    ]
  end

  def viewWillAppear(animated)
    super
    self.navigationController.setToolbarHidden(true, animated:animated)

    ## JASlidePanels の初期化タイミングでボタンスタイルが当たらないので明示的にセット
    if self.navigationItem.leftBarButtonItem
      self.navigationItem.leftBarButtonItem.styleClass = 'navigation-button'
    end

    indexPath = @menuTable.indexPathForSelectedRow
    self.initialize_data_source
    @menuTable.reloadData
    @menuTable.selectRowAtIndexPath(indexPath, animated:animated, scrollPosition:UITableViewScrollPositionNone);
    @menuTable.deselectRowAtIndexPath(indexPath, animated:animated);
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    id = "basis-cell"
    rowData = @dataSource[indexPath.section][:rows][indexPath.row]

    cell = tableView.dequeueReusableCellWithIdentifier(id) || UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:id)
    cell.textLabel.text = rowData[:label]
    if rowData[:detail]
      cell.detailTextLabel.text = rowData[:detail]
    end

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

  def observeValueForKeyPath(keyPath, ofObject:object, change:change, context:context)
    if (ApplicationUser.sharedUser == object and keyPath == 'hatena_id')
      @user = ApplicationUser.sharedUser.to_bookmark_user
      ## view 更新
      navigationItem.title = @user.name
      @imageView.setImageWithURL(@user.profile_image_url.nsurl, placeholderImage:nil)
      @nameLabel.text = @user.name
      self.initialize_data_source
      @menuTable.reloadData
    end
  end

  def open_hatena_config
    self.presentModalViewController(
      UINavigationController.alloc.initWithRootViewController(
        AccountConfigViewController.new.tap { |c| c.allow_cancellation = true }
      ),
      animated:true
    )
  end

  def open_bugreport_config
    self.presentViewController(
      UINavigationController.alloc.initWithRootViewController(BugreportConfigViewController.new),
      animated:true,
      completion:nil
    )
  end

  def open_website
    bookmark = Bookmark.new({
      :title => 'HBFav2',
      :link  => 'http://hbfav.bloghackers.net/',
      :count => nil
    })
    controller = WebViewController.new
    controller.bookmark = bookmark
    self.navigationController.pushViewController(controller, animated:true)
  end

  def open_review
    "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=477950722&pageNumber=0&sortOrdering=1&type=Purple+Software&mt=8".nsurl.open
  end

  def open_report
    "https://github.com/naoya/HBFav2/issues?state=open".nsurl.open
  end

  def open_pocket
    if PocketAPI.sharedAPI.loggedIn?
      self.navigationController.pushViewController(PocketViewController.alloc.initWithStyle(UITableViewStyleGrouped), animated:true)
    else
      PocketAPI.sharedAPI.loginWithHandler(lambda do |pocket, error|
          if error.nil?
          else
            NSLog(error.localizedDescription)
          end
          self.initialize_data_source
          @menuTable.reloadData
      end)
    end
  end

  def dealloc
    NSLog("dealloc: " + self.class.name)
    ApplicationUser.sharedUser.removeObserver(self, forKeyPath:'hatena_id')
    super
  end
end
