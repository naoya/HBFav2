# -*- coding: utf-8 -*-
class BookmarkFastCellContentView < UIView
  def drawRect(rect)
    self.superview.superview.drawRectContent(rect)
  end
end

class BookmarkFastCell < UITableViewCell
  SideWidth = 65

  attr_reader :titleLabel, :nameLabel, :commentLabel, :dateLabel, :faviconView, :starView
  attr_accessor :no_title

  def self.cellForBookmark (bookmark, inTableView:tableView)
    cell_id = 'bookmark_cell'
    cell = tableView.dequeueReusableCellWithIdentifier(cell_id) ||
      BookmarkFastCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cell_id)
    cell.no_title = false
    cell.fillWithBookmark(bookmark)
    cell
  end

  def self.cellForBookmarkNoTitle (bookmark, inTableView:tableView)
    cell_id = 'bookmark_cell_no_title'
    cell = tableView.dequeueReusableCellWithIdentifier(cell_id) ||
      BookmarkFastCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cell_id)
    cell.no_title = true
    cell.fillWithBookmark(bookmark)
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
    if comment.length > 0
      self.sizeForComment(comment, width).height
    else
      0.0
    end
  end

  def self.sizeForComment(comment, width)
    constrain = CGSize.new(self.bodyWidth(width), 1000)
    if comment.length > 0
      comment.sizeWithFont(UIFont.systemFontOfSize(16), constrainedToSize:constrain, lineBreakMode:NSLineBreakByWordWrapping)
    else
      [0.0, 0.0]
    end
  end

  def self.heightForTitle(title, width)
    self.sizeForTitle(title, width).height
  end

  def self.sizeForTitle(title, width)
    constrain = CGSize.new(self.bodyWidth(width) - 19, 1000) # 19 ･･･ favicon (16) + margin (3)
    title.sizeWithFont(UIFont.systemFontOfSize(16), constrainedToSize:constrain, lineBreakMode:NSLineBreakByWordWrapping)
  end

  def initWithStyle(style, reuseIdentifier:cellid)
    if super
      @contentView = BookmarkFastCellContentView.alloc.initWithFrame(CGRectZero)
      @contentView.backgroundColor = UIColor.whiteColor
      @contentView.opaque = true
      self.contentView << @contentView

      self.imageView.layer.tap do |l|
       l.masksToBounds = true
       l.cornerRadius = 5.0
      end

      ## 以下はただの入れ物。描画には利用しない
      @starView = HBFav2::HatenaStarView.new.tap do |v|
        v.frame = CGRectZero
        v.backgroundColor = '#fff'.uicolor
      end

      @faviconView = UIImageView.new.tap do |v|
        v.frame = CGRectZero
        v.backgroundColor = '#fff'.uicolor
      end

      @titleLabel = UILabel.new.tap do |v|
        v.frame = CGRectZero
        v.font  = UIFont.systemFontOfSize(16)
      end

      @nameLabel = UILabel.new.tap do |v|
        v.frame = CGRectZero
        v.font  = UIFont.boldSystemFontOfSize(16)
      end

      @commentLabel = UILabel.new.tap do |v|
        v.frame = CGRectZero
        v.font = UIFont.systemFontOfSize(16)
      end

      @dateLabel = UILabel.new.tap do |v|
        v.frame = CGRectZero
        v.font  = UIFont.systemFontOfSize(13)
      end
    end
    self
  end

  def fillWithBookmark(bookmark)
    unless self.no_title
      self.titleLabel.text   = bookmark.title
    end
    self.nameLabel.text    = bookmark.user_name
    self.dateLabel.text    = bookmark.datetime.timeAgo
    self.commentLabel.text = bookmark.comment.length > 0 ? bookmark.comment : nil

    self.imageView.setImageWithURL(bookmark.user.profile_image_url.nsurl, placeholderImage:"photoDefault.png".uiimage)
    self.faviconView.setImageWithURL(bookmark.favicon_url.nsurl, placeholderImage:"photoDefault.png".uiimage, completed:lambda do |image, error, cacheType|
      self.setNeedsDisplay
    end)
    self.starView.set_url(bookmark.permalink) do |image, error, cacheType|
      if image.present? and image.size.height > 1.0
        self.setNeedsDisplay
      end
    end
    self.setNeedsDisplay
  end

  def setNeedsDisplay
    super
    if @contentView.present?
      @contentView.setNeedsDisplay
    end
  end

  ## セルは使い回されるので、この中でbookmarkインスタンスは扱ってはダメ
  def layoutSubviews
    super
    @contentView.frame = self.bounds
    self.imageView.frame = [[10, 10], [48, 48]]
  end

  def drawRectContent(rect)
    body_width = self.class.bodyWidth(self.frame.size.width)

    if (self.selected? || self.highlighted?)
      color = {
        :date => '#fff',
        :text => '#fff',
        :link => '#fff',
      }
    else
      color = {
        :date => '#999',
        :text => '#000',
        :link => '#3B5998',
      }
    end

    ## date
    unless (self.dateLabel.text.nil?)
      color[:date].uicolor.set
      size = self.dateLabel.text.sizeWithFont(self.dateLabel.font)
      x = self.contentView.frame.size.width - size.width - 7
      y = 10
      self.dateLabel.text.drawInRect([[x, y], size], withFont:self.dateLabel.font)
    end

    ## ここから body (右サイド) ##
    color[:text].uicolor.set
    current_y = 10

    ## name
    size = self.nameLabel.text.sizeWithFont(self.nameLabel.font)
    self.nameLabel.text.drawInRect([[SideWidth, current_y], size], withFont:self.nameLabel.font)

    ## Star
    x = SideWidth + size.width + 3
    y = current_y + 4.5
    if starView.image.present?
      star = self.starView.image
      star.drawInRect([[x, y], [star.size.width / 2, star.size.height / 2]])
    end

    current_y += size.height + 5

    ## comment
    comment_height = 0
    if self.commentLabel.text
      size = self.class.sizeForComment(self.commentLabel.text, self.frame.size.width)
      comment_height = size.height
      self.commentLabel.text.drawInRect([[SideWidth, current_y], size], withFont:self.commentLabel.font, lineBreakMode:NSLineBreakByWordWrapping)
    end

    margin = comment_height > 0 ? 10 : 0
    current_y += comment_height + margin

    ## favicon + title
    unless self.no_title
      self.faviconView.image.drawInRect([[SideWidth, current_y + 2], [16, 16]])
      color[:link].uicolor.set
      size = self.class.sizeForTitle(self.titleLabel.text, self.frame.size.width)
      self.titleLabel.text.drawInRect([[SideWidth + 19, current_y], size], withFont:self.titleLabel.font, lineBreakMode:NSLineBreakByWordWrapping)
    end
  end
end
