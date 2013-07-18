module HBFav2
  class BookmarkView < UIView
    attr_accessor :headerView, :titleLabel, :usersButton

    def initWithFrame(frame)
      if super
        ## header
        @headerView = UITableView.alloc.initWithFrame(CGRectZero, style:UITableViewStyleGrouped)
        self << @headerView

        @profileImageView = UIImageView.new.tap do |v|
          v.frame = CGRectZero
          v.layer.tap do |layer|
            layer.masksToBounds = true
            layer.cornerRadius = 5.0
          end
        end
        @headerView << @profileImageView

        @nameLabel = UILabel.new.tap do |v|
          v.frame = CGRectZero
          v.font  = UIFont.boldSystemFontOfSize(18)
          v.shadowColor = UIColor.whiteColor
          v.shadowOffset = [0, 1]
          v.backgroundColor = UIColor.clearColor
        end
        @headerView << @nameLabel

        @discImageView = UIImageView.new.tap do |v|
          v.image = UIImage.imageNamed('disc2.png')
        end
        @headerView << @discImageView

        @border = UIView.new.tap do |v|
          v.backgroundColor = '#ababab'.uicolor
          self << v
        end

        ## body
        self << @bodyView = UIScrollView.new.tap {|v| v.frame = CGRectZero }

        @bodyView << @commentLabel = UILabel.new.tap do |v|
          v.frame = CGRectZero
          v.numberOfLines = 0
          v.font = UIFont.systemFontOfSize(18)
        end

        @bodyView << @faviconView = UIImageView.new.tap {|v| v.frame = CGRectZero }

        @bodyView << @titleLabel = UILabel.new.tap do |v|
          v.frame = CGRectZero
          v.numberOfLines = 0
          v.numberOfLines = 0
          v.font = UIFont.systemFontOfSize(18)
          v.textColor = '#3B5998'.to_color
        end

        @bodyView << @urlLabel = UILabel.new.tap do |v|
          v.frame = CGRectZero
          v.numberOfLines = 0
          v.font = UIFont.systemFontOfSize(14)
          v.textColor = '#666'.uicolor
        end

        @bodyView << @dateLabel = UILabel.new.tap do |v|
          v.frame = CGRectZero
          v.font = UIFont.systemFontOfSize(14)
          v.textColor = '#666'.uicolor
        end

        @bodyView << @starView = HBFav2::HatenaStarView.new

        @bodyView << @usersButton = UIButton.buttonWithType(UIButtonTypeRoundedRect).tap do |button|
          button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft
          button.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
        end
      end
      self
    end

    def bookmark=(bookmark)
      @nameLabel.text    = bookmark.user.name
      @commentLabel.text = bookmark.comment if bookmark.comment.present?
      @titleLabel.text   = bookmark.title
      @urlLabel.text     = bookmark.link
      @dateLabel.text    = bookmark.datetime.timeAgo
      @starView.url      = bookmark.permalink

      @profileImageView.setImageWithURL(bookmark.user.profile_image_url.nsurl, placeholderImage:nil)
      @faviconView.setImageWithURL(bookmark.favicon_url.nsurl, placeholderImage:nil)
      @usersButton.setTitle(bookmark.count.to_s, forState:UIControlStateNormal)

      self.setNeedsLayout
    end

    ## FIXME: hard to read
    def layoutSubviews
      super

      ## header
      @headerView.frame = [self.bounds.origin, [self.bounds.size.width, 68]]
      @profileImageView.frame = [[10, 10], [48, 48]]
      @nameLabel.frame = [[68, 10], [200, 48]]

      w = @headerView.bounds.size.width
      h = @headerView.bounds.size.height
      @discImageView.frame = [[w - 20, (h / 2) - 8], [12, 17]]
      @border.frame = [[0, 68], [self.bounds.size.width, 1]]

      ## body
      @bodyView.frame = [[0, 69], [self.bounds.size.width, self.bounds.size.height - 69]]
      current_y = 10

      # comment
      if @commentLabel.text.present?
        constrain = CGSize.new(self.frame.size.width - 20, 1000)
        size = @commentLabel.text.sizeWithFont(
          UIFont.systemFontOfSize(18),
          constrainedToSize:constrain,
          lineBreakMode:UILineBreakModeCharacterWrap
        )
        @commentLabel.frame = [[10, current_y], size]
        current_y += size.height + 4
      end

      # favicon
      @faviconView.frame = [[10, current_y + 2], [16, 16]]

      # title
      constrain = CGSize.new(self.frame.size.width - 19 - 20, 1000) # 19 = favicon (16) + margin (3)
      size = @titleLabel.text.sizeWithFont(
        UIFont.systemFontOfSize(18),
        constrainedToSize:constrain,
        lineBreakMode:UILineBreakModeCharacterWrap
      )
      @titleLabel.frame = [[10 + 19, current_y], size]
      current_y += size.height + 4

      # URL
      constrain = CGSize.new(self.frame.size.width - 19 - 20, 1000) # 19 = favicon (16) + margin (3)
      size = @urlLabel.text.sizeWithFont(
        UIFont.systemFontOfSize(14),
        constrainedToSize:constrain,
        lineBreakMode:UILineBreakModeCharacterWrap
      )
      @urlLabel.frame = [[10 + 19, current_y], size]
      current_y += size.height + 4

      # date
      @dateLabel.frame = [[10 + 19, current_y], [0, 0]]
      @dateLabel.sizeToFit
      current_y += @dateLabel.frame.size.height + 10

      # star
      origin = @dateLabel.frame.origin
      @starView.origin = [origin.x + @dateLabel.frame.size.width + 3, origin.y + 3.5]

      # button
      @usersButton.frame = [[10, current_y], [self.frame.size.width - 20, 40]]
      current_y += 40

      @bodyView.contentSize = [self.frame.size.width, current_y + 69]
    end
  end
end
