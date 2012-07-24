# -*- coding: utf-8 -*-
class BookmarkCell < UITableViewCell
  CellID = 'CellIdentifier'

  attr_reader :nameLabel, :commentLabel, :dateLabel

  def self.cellForBookmark (bookmark, inTableView:tableView)
    cell = tableView.dequeueReusableCellWithIdentifier(BookmarkCell::CellID) ||
      BookmarkCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:CellID)
    cell.fillWithBookmark(bookmark, inTableView:tableView)
    return cell
  end

  def initWithStyle(style, reuseIdentifier:cellid)
    if super
      self.textLabel.tap do |v|
        v.numberOfLines = 0
        v.font = UIFont.systemFontOfSize(16)
        v.textColor = '#3B5998'.to_color
      end

      @nameLabel = UILabel.new.tap do |v|
        v.frame = CGRectZero
        v.font  = UIFont.boldSystemFontOfSize(16)
        self.contentView << v
      end

      @commentLabel = UILabel.new.tap do |v|
        v.frame = CGRectZero
        self.contentView << v
      end

      @dateLabel = UILabel.new.tap do |v|
        v.frame = CGRectZero
        self.contentView << v
      end
    end
    self
  end

  def fillWithBookmark(bookmark, inTableView:tableView)
    self.textLabel.text = bookmark.title
    self.nameLabel.text = bookmark.user_name
    # self.commentLabel.text = bookmark.comment
    self.dateLabel.text = bookmark.created_at

    if not bookmark.profile_image
      self.imageView.image = nil
      Dispatch::Queue.concurrent.async do
        data = NSData.dataWithContentsOfURL(bookmark.profile_image_url.nsurl)
        bookmark.profile_image = UIImage.alloc.initWithData(data)
        Dispatch::Queue.main.sync do
          self.imageView.image = bookmark.profile_image
          ## FIXME: bookmark.row に代入しているのださいなあ
          tableView.reloadRowsAtIndexPaths([NSIndexPath.indexPathForRow(bookmark.row, inSection: 0)], withRowAnimation:false)
        end
      end
    else
      self.imageView.image = bookmark.profile_image
    end
  end

  def layoutSubviews
    super
    self.imageView.frame = [[10, 10], [48, 48]]
    label_size = self.frame.size
    self.nameLabel.frame = [[65, 10], [label_size.width - 65 - 10, 16]]
    self.textLabel.frame = [[65, 10 + 16 + 5], [label_size.width - 65 - 10, label_size.height]]
  end
end
