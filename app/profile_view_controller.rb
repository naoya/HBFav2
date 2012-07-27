# -*- coding: utf-8 -*-
class ProfileViewController < UIViewController
  def init
    if super
      self.navigationItem.title = "naoya"
      self.view.backgroundColor = UIColor.groupTableViewBackgroundColor
    end
    self
  end

  def viewDidLoad
    super

    @dataSource = [
      {
        :title => nil,
        :rows  => [
          {
            :label => "ブックマーク",
          },
          {
            :label => "フォロー",
          }
        ]
      },
      {
        :title => "設定",
        :rows  => [
          {
            :label => "はてなID",
            :color => '#385487'.uicolor
          },
          {
            :label => "Instapaper",
            :color => '#385487'.uicolor
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
      view << v
    end

    @nameLabel = UILabel.new.tap do |v|
      v.frame = [[68, 10], [200, 48]]
      v.font  = UIFont.boldSystemFontOfSize(18)
      v.text  = "naoya"
      v.shadowColor = UIColor.whiteColor
      v.shadowOffset = [0, 1]
      v.backgroundColor = UIColor.clearColor
      view << v
    end

    @menuTable = UITableView.alloc.initWithFrame([[0, 58], self.view.bounds.size], style:UITableViewStyleGrouped).tap do |v|
      v.dataSource = self
      view << v
    end

    Dispatch::Queue.concurrent.async do
      image = RemoteImageFactory.instance(:profile_image).image('http://www.st-hatena.com/users/na/naoya/profile.gif')
      Dispatch::Queue.main.sync do
        @imageView.image = image
      end
    end
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    id = "basis-cell"
    rowData = @dataSource[indexPath.section][:rows][indexPath.row]

    cell = tableView.dequeueReusableCellWithIdentifier(id) || UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:id)
    cell.textLabel.text = rowData[:label]
    if (color = rowData[:color])
      cell.textLabel.textColor = color
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
end
