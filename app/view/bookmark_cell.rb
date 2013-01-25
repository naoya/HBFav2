# -*- coding: utf-8 -*-
class BookmarkCell < UITableViewCell
  SideWidth = 65

  attr_reader :nameLabel, :commentLabel, :dateLabel, :faviconView
  attr_accessor :no_title

  def self.cellForBookmark (bookmark, inTableView:tableView)
    cell_id = 'bookmark_cell'
    cell = tableView.dequeueReusableCellWithIdentifier(cell_id) ||
      BookmarkCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cell_id)
    cell.no_title = false
    cell.fillWithBookmark(bookmark, inTableView:tableView)
    cell
  end

  def self.cellForBookmarkNoTitle (bookmark, inTableView:tableView)
    cell_id = 'bookmark_cell_no_title'
    cell = tableView.dequeueReusableCellWithIdentifier(cell_id) ||
      BookmarkCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cell_id)
    cell.no_title = true
    cell.fillWithBookmark(bookmark, inTableView:tableView)
    cell
  end

  def self.bodyWidth(width)
    width - SideWidth - 10
  end

  def self.heightForBookmark(bookmark, width, no_title = false)
    name_size      = bookmark.user_name.sizeWithFont(UIFont.boldSystemFontOfSize(16))
    comment_height = self.heightForComment(bookmark.comment, width)

    title_height = 0
    if no_title
      title_height = 0
      margin = 0
    else
      title_height   = self.heightForTitle(bookmark.title, width)
      margin = comment_height > 0 ? 10 : 0
    end

    [68, 10 + name_size.height + 5 + comment_height + margin + title_height + 10].max
  end

  def self.heightForComment(comment, width)
    height     = 0
    constrain = CGSize.new(self.bodyWidth(width), 1000)
    if comment.length > 0
      height = comment.sizeWithFont(UIFont.systemFontOfSize(16), constrainedToSize:constrain, lineBreakMode:UILineBreakModeCharacterWrap).height
    end
    height
  end

  def self.heightForTitle(title, width)
    height     = 0
    constrain = CGSize.new(self.bodyWidth(width) - 19, 1000) # 19 ･･･ favicon (16) + margin (3)
    title.sizeWithFont(UIFont.systemFontOfSize(16), constrainedToSize:constrain, lineBreakMode:UILineBreakModeCharacterWrap).height
  end

  def initWithStyle(style, reuseIdentifier:cellid)
    if super
      self.textLabel.tap do |v|
        v.numberOfLines = 0
        v.font = UIFont.systemFontOfSize(16)
        v.textColor = '#3B5998'.to_color
      end

      self.imageView.layer.tap do |l|
        l.masksToBounds = true
        l.cornerRadius = 5.0
      end

      @nameLabel = UILabel.new.tap do |v|
        v.frame = CGRectZero
        v.font  = UIFont.boldSystemFontOfSize(16)
        self.contentView << v
      end

      @commentLabel = UILabel.new.tap do |v|
        v.numberOfLines = 0
        v.font = UIFont.systemFontOfSize(16)
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

      @faviconView = UIImageView.new.tap do |v|
        v.frame = CGRectZero
        self.contentView << v
      end
    end
    self
  end

  def fillWithBookmark(bookmark, inTableView:tableView)
    self.textLabel.text    = self.no_title ? nil : bookmark.title
    self.nameLabel.text    = bookmark.user_name
    self.dateLabel.text    = bookmark.created_at
    self.commentLabel.text = bookmark.comment.length > 0 ? bookmark.comment : nil

    ## FIXME: Dispatch Group で書き換える
    if not bookmark.profile_image or not bookmark.favicon
      self.imageView.image   = nil
      self.faviconView.image = nil

      Dispatch::Queue.concurrent.async do
        profile_factory = RemoteImageFactory.instance(:profile_image)
        bookmark.profile_image = profile_factory.image(bookmark.user.profile_image_url)

        favicon_factory = RemoteImageFactory.instance(:favicon)
        bookmark.favicon = favicon_factory.image(bookmark.favicon_url)

        Dispatch::Queue.main.sync do
          self.imageView.image   = bookmark.profile_image
          self.faviconView.image = bookmark.favicon

          ## FIXME: bookmark.row に代入しているのださいなあ
          tableView.reloadRowsAtIndexPaths([NSIndexPath.indexPathForRow(bookmark.row, inSection: 0)], withRowAnimation:false)
        end
      end
    else
      self.imageView.image   = bookmark.profile_image
      self.faviconView.image = bookmark.favicon
    end
  end

  ## セルは使い回されるので、この中でbookmarkインスタンスは扱ってはダメ
  def layoutSubviews
    super
    frame_size = self.frame.size
    body_width = self.class.bodyWidth(frame_size.width)

    ## image
    self.imageView.frame = [[10, 10], [48, 48]]

    ## date (150決めうちとかだめすぎる･･･)
    date_size = self.dateLabel.text.sizeWithFont(UIFont.systemFontOfSize(14))
    self.dateLabel.frame = [[SideWidth + 150, 10], [body_width - 150, date_size.height]]
    self.dateLabel.textAlignment = UITextAlignmentRight

    ## ここから body (右サイド) ##
    current_y = 10

    ## name
    name_size = self.nameLabel.text.sizeWithFont(UIFont.boldSystemFontOfSize(16))
    self.nameLabel.frame = [[SideWidth, current_y], [body_width, name_size.height]]
    current_y += name_size.height + 5

    ## comment
    comment_height = 0
    if self.commentLabel.text
      comment_height = self.class.heightForComment(self.commentLabel.text, frame_size.width)
      self.commentLabel.frame = [[SideWidth, current_y], [body_width, comment_height]]
    else
      self.commentLabel.frame = CGRectZero
    end
    margin = comment_height > 0 ? 10 : 0
    current_y += comment_height + margin

    ## favicon + title
    unless self.no_title
      self.faviconView.frame = [[SideWidth, current_y + 2], [16, 16]]
      title_height = self.class.heightForTitle(self.textLabel.text, frame_size.width)
      self.textLabel.frame = [[SideWidth + 19, current_y], [body_width - 19, title_height]]
    end
  end

end
