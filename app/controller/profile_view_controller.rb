# -*- coding: utf-8 -*-
class ProfileViewController < UIViewController
  attr_accessor :user, :as_mine

  def viewDidLoad
    super

    ApplicationUser.sharedUser.addObserver(self, forKeyPath:'hatena_id', options:0, context:nil)
    self.navigationItem.title = @user.name

    # self.view.backgroundColor = UIColor.groupTableViewBackgroundColor
    view << UITableView.alloc.initWithFrame(view.bounds, style:UITableViewStyleGrouped)

    @dataSource = [
      {
        :title => nil,
        :rows  => [
          {
            :label         => "ブックマーク",
            :accessoryType => UITableViewCellAccessoryDisclosureIndicator,
            :action        => proc {
              self.navigationController.pushViewController(
                TimelineViewController.new.tap do |c|
                  c.feed_url = user.bookmark_feed_url
                  c.title = user.name
                end,
                animated:true
              )
            }
          },
          {
            :label         => "フォロー",
            :accessoryType => UITableViewCellAccessoryDisclosureIndicator,
            :action        => proc {
              self.navigationController.pushViewController(
                TimelineViewController.new.tap do |c|
                  c.feed_url = user.timeline_feed_url
                  c.title = user.name
                end,
                animated:true
              )
            }
          }
        ]
      },
      {
        :title => "設定",
        :rows  => [
          {
            :label => "はてなID",
            :color => '#385487'.uicolor,
            :action        => proc {
              AccountConfigViewController.new.tap do |c|
                c.user = @user
                diag = UINavigationController.alloc.initWithRootViewController(c)
                # diag = UINavigationController.alloc.initWithRootViewController(@form_controller)
                self.presentModalViewController(diag, animated:true)
              end
            }
          },
          {
            :label => "Instapaper",
            :color => '#385487'.uicolor,
            :action        => proc {
              # TODO
              puts "test4"
            }
          }
        ]
      }
    ]

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

  def viewWillAppear(animated)
    @menuTable.deselectRowAtIndexPath(@menuTable.indexPathForSelectedRow, animated:animated)
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
    # @dataSource.size
    # ↓ ちょっとこの書き方はどうかなあ
    mine? ? 2 : 1
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    if (action = @dataSource[indexPath.section][:rows][indexPath.row][:action])
      action.call
    end
  end

  def mine?
    as_mine ? true : false
  end

  def observeValueForKeyPath(keyPath, ofObject:object, change:change, context:context)
    if (ApplicationUser.sharedUser == object and keyPath == 'hatena_id' and self.mine?)
      self.user = ApplicationUser.sharedUser.to_bookmark_user

      # これ手動で書く必要あるのがなあ
      # モデル更新したら自動で update されるようにできないのか
      navigationItem.title = @user.name
      @imageView.setImageWithURL(@user.profile_image_url.nsurl, placeholderImage:nil)
      @nameLabel.text = @user.name
    end
  end

  def dealloc
    ApplicationUser.sharedUser.removeObserver(self, forKeyPath:'hatena_id')
  end
end
