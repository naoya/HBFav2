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

    # FIXME: この構造いまいちな気が
    # section が番号で渡ってくるんだし、セクションは配列の方がよさそう
    # [0] -> { :title => "hoge", :rows => ["foo", "bar"] }
    @dataSource = {
      "メニュー" => ["ブックマーク", "フォロー"],
      "設定"     => ["はてなID", "Instapaper"]
    }

    Dispatch::Queue.concurrent.async do
      image = RemoteImageFactory.instance(:profile_image).image('http://www.st-hatena.com/users/na/naoya/profile.gif')
      Dispatch::Queue.main.sync do
        @imageView.image = image
      end
    end
  end

  def tableView(tableView, numberOfRowsInSection:section)
    @dataSource[@dataSource.keys[section]].size
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    id = "basis-cell"
    cell = tableView.dequeueReusableCellWithIdentifier(id) || UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:id)
    cell.textLabel.text = @dataSource[@dataSource.keys[indexPath.section]][indexPath.row]
    cell
  end

  def numberOfSectionsInTableView (tableView)
    @dataSource.size
  end

  def tableView(tableView, titleForHeaderInSection:section)
    @dataSource.keys[section]
  end
end
