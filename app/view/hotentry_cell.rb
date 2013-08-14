# -*- coding: utf-8 -*-
class HotentryCellContentView < UIView
  def drawRect(rect)
    self.superview.superview.drawRectContent(rect)
  end
end

class HotentryCell < UITableViewCell
  @@blank_image = UIImage.imageNamed('blank')

  def self.cellForBookmark(bookmark, inTableView:tableView)
    cell_id = 'hotentry_cell'
    cell = tableView.dequeueReusableCellWithIdentifier(cell_id) ||
      HotentryCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cell_id)
    cell.fillWithBookmark(bookmark)
    cell
  end

  def self.heightForBookmark(bookmark, width)
    title_size = self.sizeForTitle(bookmark.title, width)
    dt_size  = self.sizeForDateTime(bookmark.datetime.timeAgo)
    [10 + 60 + 10, 10 + title_size.height + 3 + 13 + 3 + dt_size.height + 10].max
  end

  def self.heightForBookmarkNoThumbnail(bookmark, width)
    title_size = self.sizeForTitleNoThubnail(bookmark.title, width)
    dt_size  = self.sizeForDateTime(bookmark.datetime.timeAgo)
    return 10 + title_size.height + 3 + 13 + 3 + dt_size.height + 10
  end

  def self.sizeForDateTime(string)
    string.sizeWithFont(BookmarkLabelAttributes.sharedAttributes.attributes[:date][:font])
  end

  def self.sizeForTitle(title, width)
    constrain = CGSize.new(width - 10 - (5 + 80 + 10), 1000)
    title.sizeWithFont(
      BookmarkLabelAttributes.sharedAttributes.attributes[:title][:font],
      constrainedToSize:constrain,
      lineBreakMode:NSLineBreakByWordWrapping
    )
  end

  def self.sizeForTitleNoThubnail(title, width)
    constrain = CGSize.new(width - 10 - 10, 1000)
    title.sizeWithFont(
      BookmarkLabelAttributes.sharedAttributes.attributes[:title][:font],
      constrainedToSize:constrain,
      lineBreakMode:NSLineBreakByWordWrapping
    )
  end

  def self.sizeForThumbnail(image)
    if image.nil?
      [0, 0]
    else
      if image.landscape?
        [80, 60]
      else
        [60, 80]
      end
    end
  end

  def initWithStyle(style, reuseIdentifier:reuseIdentifier)
    if super
      @contentView = HotentryCellContentView.alloc.initWithFrame(CGRectZero)
      @contentView.backgroundColor = UIColor.whiteColor
      @contentView.opaque = true
      self.contentView << @contentView

      self.imageView.contentMode = UIViewContentModeScaleAspectFit

      @starView = HBFav2::HatenaStarView.new
      @faviconView = UIImageView.new
      @labels   = {}
    end
    self
  end

  def fillWithBookmark(bookmark)
    @labels[:date]     = bookmark.datetime.timeAgo
    @labels[:category] = bookmark.category
    @labels[:title]    = bookmark.title
    @labels[:host]     = bookmark.link.nsurl.host
    @labels[:count]    = bookmark.count.to_s

    if bookmark.thumbnail_url.present?
      self.imageView.setImageWithURL(bookmark.thumbnail_url.nsurl, placeholderImage:@blank_image, options:SDWebImageLowPriority, completed:
        lambda do |image, error, cacheType|
          self.setNeedsDisplay
          self.setNeedsLayout
        end
      )
    else
      self.imageView.image = nil
      self.setNeedsDisplay
    end

    @faviconView.setImageWithURL(bookmark.favicon_url.nsurl, placeholderImage:@@blank_image, options:SDWebImageLowPriority, completed:lambda { |image, error, cacheType| self.setNeedsDisplay })

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

  def layoutSubviews
    super
    @contentView.frame = self.bounds

    if self.imageView.image.nil?
      self.imageView.frame = CGRectZero
    else
      size = self.class.sizeForThumbnail(self.imageView.image)
      self.imageView.frame = [[0, 0], size]
      self.imageView.top   = @contentView.top + 10
      self.imageView.right = @contentView.right - 10
    end
  end

  def drawRectContent(rect)
    attributes = BookmarkLabelAttributes.sharedAttributes.attributes

    if (self.selected? || self.highlighted?)
      color = {
        :date => '#fff',
        :text => '#fff',
        :link => '#fff',
        :host => '#fff',
      }
    else
      color = {
        :date => attributes[:date][:color],
        :text => attributes[:name][:color],
        :link => attributes[:title][:color],
        :host => attributes[:host][:color],
      }
    end

    current_y = 10

    color[:link].uicolor.set
    size = if self.imageView.image.nil?
             self.class.sizeForTitleNoThubnail(@labels[:title], self.frame.size.width)
           else
             self.class.sizeForTitle(@labels[:title], self.frame.size.width)
           end

    @labels[:title].drawInRect([[10, current_y], size], withFont:attributes[:title][:font], lineBreakMode:NSLineBreakByWordWrapping)

    current_y += size.height + 3

    ## favicon + domain
    color[:host].uicolor.set
    @faviconView.image.drawInRect([[10, current_y + 2], [13, 13]])
    size = @labels[:host].sizeWithFont(attributes[:host][:font])
    @labels[:host].drawInRect([[10 + 15, current_y], size], withFont:attributes[:host][:font], lineBreakMode:NSLineBreakByWordWrapping)

    ## star
    x = 10 + 15 + size.width + 3
    y = current_y + 3
    @starView.image.drawInRect([[x, y], @starView.size])

    current_y += size.height + 3

    ## date
    if @labels[:date].present?
      ## 赤くすると目障りなのでしない
      # "#fc3137".uicolor.set
      # size = @labels[:count].sizeWithFont(UIFont.boldSystemFontOfSize(12))
      # @labels[:count].drawInRect([[10 + 18, current_y], size], withFont:UIFont.boldSystemFontOfSize(12))

      # context = UIGraphicsGetCurrentContext()
      # "#fc3137".uicolor(1.0).setStroke
      # CGContextSetLineWidth(context, 1)
      # CGContextMoveToPoint(context, 10 + 18, current_y + size.height)
      # CGContextAddLineToPoint(context, 10 + 18 + size.width, current_y + size.height)
      # CGContextStrokePath(context)

      color[:date].uicolor.set
      str = [ @labels[:count], @labels[:category] ,@labels[:date] ].compact.join(" - ")
      size = self.class.sizeForDateTime(str)
      str.drawInRect([[10 + 15, current_y], size], withFont:attributes[:date][:font])
    end
  end

  def dealloc
    NSLog("dealloc: " + self.class.name)
    super
  end
end
