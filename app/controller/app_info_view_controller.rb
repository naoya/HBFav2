# -*- coding: utf-8 -*-
class AppInfoViewController < UIViewController
  include HBFav2::ApplicationSwitchNotification

  def viewDidLoad
    super
    self.title = "アプリについて"
    self.navigationItem.backBarButtonItem = UIBarButtonItem.titled("戻る")

    ## 背景
    view << UITableView.alloc.initWithFrame(view.bounds, style:UITableViewStyleGrouped)

    @dataSource = [
      {
        :rows => [
          {
            :label  => "ご意見・ご要望",
            :detail => "Github",
            :action => 'open_report'
          },
          {
            :label  => "レビューを書く",
            :detail => "App Store",
            :action => 'open_review'
          },
          {
            :label  => "アプリのWebサイト",
            :accessoryType => UITableViewCellAccessoryDisclosureIndicator,
            :action => 'open_website'
          },
          {
            :label => "クレジット",
            :accessoryType => UITableViewCellAccessoryDisclosureIndicator,
            :action => 'open_credit'
          },
          {
            :label => "開発者ブログ",
            :accessoryType => UITableViewCellAccessoryDisclosureIndicator,
            :action => 'open_blog'
          }
        ],
      }
    ]

    view << @imageView = UIImageView.new.tap do |v|
      v.frame = [[10, 10], [48, 48]]
      v.layer.tap do |l|
        l.masksToBounds = true
        l.cornerRadius  = 5.0
      end
      v.image = UIImage.imageNamed('default_app_logo')
    end

    view << @nameLabel = UILabel.new.tap do |v|
      version = NSBundle.mainBundle.infoDictionary.objectForKey('CFBundleShortVersionString')

      v.frame = [[68, 10], [200, 48]]
      v.font  = UIFont.boldSystemFontOfSize(18)
      v.text  = "HBFav #{version}"
      v.shadowColor = UIColor.whiteColor
      v.shadowOffset = [0, 1]
      v.backgroundColor = UIColor.clearColor
    end

    view << @menuTable = UITableView.alloc.initWithFrame([[0, 59], self.view.bounds.size], style:UITableViewStyleGrouped).tap do |v|
      v.dataSource = v.delegate = self
    end
  end

  def viewWillAppear(animated)
    super
    self.receive_application_switch_notifcation
    self.navigationController.setToolbarHidden(true, animated:animated)

    ## JASlidePanels の初期化タイミングでボタンスタイルが当たらないので明示的にセット
    if self.navigationItem.leftBarButtonItem
      self.navigationItem.leftBarButtonItem.styleClass = 'navigation-button'
    end

    @menuTable.deselectRowAtIndexPath(@menuTable.indexPathForSelectedRow, animated:animated)
  end

  def viewWillDisappear(animated)
    self.unreceive_application_switch_notification
    super
  end

  ## AccountViewController とコードが被ってる
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

  def open_blog
    bookmark = Bookmark.new({
      :title => 'HBFav2',
      :link  => "http://d.hatena.ne.jp/naoya/",
      :count => nil
    })
    controller = WebViewController.new
    controller.bookmark = bookmark
    self.navigationController.pushViewController(controller, animated:true)
  end

  def open_credit
    controller = CreditViewController.new
    self.navigationController.pushViewController(controller, animated:true)
  end

  def dealloc
    NSLog("dealloc: " + self.class.name)
    super
  end

  def applicationWillEnterForeground
    @menuTable.deselectRowAtIndexPath(@menuTable.indexPathForSelectedRow, animated:true)
  end
end
