# -*- coding: utf-8 -*-
class BookmarkFastCellContentView < UIView
  def drawRect(rect)
    self.superview.superview.drawRectContent(rect)
  end
end

class BookmarkFastCell < UITableViewCell
  SideWidth = 65
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
    name_size      = bookmark.user.name.sizeWithFont(
      BookmarkLabelAttributes.sharedAttributes.attributes[:name][:font]
    )
    comment_height = self.heightForComment(bookmark.comment, width)

    title_height = 0
    if no_title
      title_height = 0
      margin = 0
    else
      title_height = self.heightForTitle(bookmark.title, width)
      margin = comment_height > 0 ? 3 : 0
    end

    [68, 10 + name_size.height + 3 + comment_height + margin + title_height + 10].max
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
      comment.sizeWithFont(
        BookmarkLabelAttributes.sharedAttributes.attributes[:comment][:font],
        constrainedToSize:constrain,
        lineBreakMode:NSLineBreakByWordWrapping
      )
    else
      [0.0, 0.0]
    end
  end

  def self.heightForTitle(title, width)
    self.sizeForTitle(title, width).height
  end

  def self.sizeForTitle(title, width)
    constrain = CGSize.new(self.bodyWidth(width) - 16, 1000) # 17 ･･･ favicon (14) + margin (3)
    title.sizeWithFont(
      BookmarkLabelAttributes.sharedAttributes.attributes[:title][:font],
      constrainedToSize:constrain,
      lineBreakMode:NSLineBreakByWordWrapping
    )
  end

  def initWithStyle(style, reuseIdentifier:cellid)
    if super
      @contentView = BookmarkFastCellContentView.alloc.initWithFrame(CGRectZero)
      @contentView.backgroundColor = UIColor.whiteColor
      @contentView.opaque = true
      self.contentView << @contentView

      ## プロフィール画像と Star は ImageView を使わないと安定した配信が難しい、ので使う
      self.imageView.layer.tap do |l|
       l.masksToBounds = true
       l.cornerRadius = 5.0
      end
      @starView = HBFav2::HatenaStarView.new

      ## それ以外は UIView を使わない
      @labels  = {}
      @favicon = nil
    end
    self
  end

  def fillWithBookmark(bookmark)
    @labels[:name]    = bookmark.user.name
    @labels[:date]    = bookmark.datetime.timeAgo
    @labels[:comment] = bookmark.comment.length > 0 ? bookmark.comment : nil
    @labels[:title]   = bookmark.title unless self.no_title

    self.imageView.setImageWithURL(bookmark.user.profile_image_url.nsurl, placeholderImage:"profile_placeholder.png".uiimage, options:SDWebImageLowPriority)

    sdmgr = SDWebImageManager.sharedManager
    unless self.no_title
      sdmgr.downloadWithURL(bookmark.favicon_url.nsurl, options:SDWebImageLowPriority, progress:nil, completed:lambda do |image, error, cacheType, finished|
        if image.present?
          @favicon = image
          self.setNeedsDisplay
        end
      end)
    end

    @starView.set_url(bookmark.permalink) do |image, error, cacheType|
      self.setNeedsDisplay
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
    attributes = BookmarkLabelAttributes.sharedAttributes.attributes

    if (self.selected? || self.highlighted?)
      color = {
        :date => '#fff',
        :text => '#fff',
        :link => '#fff',
      }
    else
      color = {
        :date => attributes[:date][:color],
        :text => attributes[:name][:color],
        :link => attributes[:title][:color],
      }
    end

    ## date
    if @labels[:date].present?
      color[:date].uicolor.set
      size = @labels[:date].sizeWithFont(attributes[:date][:font])
      x = self.contentView.frame.size.width - size.width - 7
      y = 10
      @labels[:date].drawInRect([[x, y], size], withFont:attributes[:date][:font])
    end

    ## ここから body (右サイド) ##
    color[:text].uicolor.set
    current_y = 10

    ## name
    size = @labels[:name].sizeWithFont(attributes[:name][:font])
    @labels[:name].drawInRect([[SideWidth, current_y], size], withFont:attributes[:name][:font])

    x = SideWidth + size.width + 3
    y = current_y + 4.5
    @starView.image.drawInRect([[x, y], @starView.size])

    current_y += size.height + 3

    ## comment
    comment_height = 0
    if @labels[:comment]
      size = self.class.sizeForComment(@labels[:comment], self.frame.size.width)
      comment_height = size.height
      @labels[:comment].drawInRect([[SideWidth, current_y], size], withFont:attributes[:comment][:font], lineBreakMode:NSLineBreakByWordWrapping)
    end

    margin = comment_height > 0 ? 3 : 0
    current_y += comment_height + margin

    ## favicon + title
    unless self.no_title
      if @favicon.present?
        @favicon.drawInRect([[SideWidth, current_y + 2], [14, 14]]) if @favicon.present?
      end
      color[:link].uicolor.set
      size = self.class.sizeForTitle(@labels[:title], self.frame.size.width)
      @labels[:title].drawInRect([[SideWidth + 16, current_y], size], withFont:attributes[:title][:font], lineBreakMode:NSLineBreakByWordWrapping)
    end
  end

  def dealloc
    NSLog("dealloc: " + self.class.name)
    super
  end
end
