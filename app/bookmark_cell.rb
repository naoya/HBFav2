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

  ## FIXME: layoutSubviews の中とDRYじゃない
  def self.heightForBookmark(bookmark, width)
    name_size = bookmark.user_name.sizeWithFont(UIFont.boldSystemFontOfSize(16))

    constrain = CGSize.new(width - 65 - 10, 1000)

    comment_height = 0
    if bookmark.comment.length > 0
      comment_size = bookmark.comment.sizeWithFont(UIFont.systemFontOfSize(16), constrainedToSize:constrain, lineBreakMode:UILineBreakModeCharacterWrap)
      comment_height = comment_size.height + 10 # 10はmargin分
    end

    text_size = bookmark.title.sizeWithFont(UIFont.systemFontOfSize(16), constrainedToSize:constrain, lineBreakMode:UILineBreakModeCharacterWrap)
    [68, 10 + name_size.height + 5 + comment_height + text_size.height + 10].max
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
        v.numberOfLines = 0
        v.frame = CGRectZero
        v.text  = nil
        self.contentView << v
      end

      @dateLabel = UILabel.new.tap do |v|
        v.frame = CGRectZero
        v.font  = UIFont.systemFontOfSize(14)
        v.textColor = '#999'.to_color
        self.contentView << v
      end
    end
    self
  end

  def fillWithBookmark(bookmark, inTableView:tableView)
    self.textLabel.text    = bookmark.title
    self.nameLabel.text    = bookmark.user_name
    self.dateLabel.text    = bookmark.created_at
    self.commentLabel.text = bookmark.comment.length > 0 ? bookmark.comment : nil

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

    frame_size = self.frame.size
    side_width = 65
    body_width = frame_size.width - side_width - 10 # 10は右サイドのpad
    constrain = CGSize.new(body_width, 1000)

    ## image
    self.imageView.frame = [[10, 10], [48, 48]]

    ## date (150決めうちとかだめすぎる･･･)
    date_size = self.dateLabel.text.sizeWithFont(UIFont.systemFontOfSize(14))
    self.dateLabel.frame = [[side_width + 150, 10], [body_width - 150, date_size.height]]
    self.dateLabel.textAlignment = UITextAlignmentRight
    # self.dateLabel.sizeToFit

    ## name
    name_size = self.nameLabel.text.sizeWithFont(UIFont.boldSystemFontOfSize(16))
    self.nameLabel.frame = [[side_width, 10], [body_width, name_size.height]]

    ## comment
    comment_height = 0
    if self.commentLabel.text
      comment_size = self.commentLabel.text.sizeWithFont(UIFont.systemFontOfSize(16), constrainedToSize:constrain, lineBreakMode:UILineBreakModeCharacterWrap)
      comment_height = comment_size.height
      self.commentLabel.frame = [[side_width, 10 + name_size.height + 5], [body_width, comment_height]]
    else
      self.commentLabel.frame = CGRectZero
    end

    ## title
    margin = comment_height > 0 ? 10 : 0
    text_size = self.textLabel.text.sizeWithFont(UIFont.systemFontOfSize(16), constrainedToSize:constrain, lineBreakMode:UILineBreakModeCharacterWrap)
    self.textLabel.frame = [[side_width, 10 + name_size.height + 5 + comment_height + margin], [body_width, text_size.height]]
  end
end
