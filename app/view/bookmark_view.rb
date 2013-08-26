# -*- coding: utf-8 -*-
module HBFav2
  class BookmarkView < UIView
    attr_accessor :headerView, :usersButton, :starView, :titleButton

    def initWithFrame(frame)
      if super
        self << @bodyView = UIScrollView.new.tap {|v| v.frame = CGRectZero }

        @bodyView << @headerView = UITableView.alloc.initWithFrame(CGRectZero, style:UITableViewStyleGrouped)

        ## header
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
          v.image = UIImage.imageNamed('chevron')
        end
        @headerView << @discImageView

        @bodyView << @border = UIView.new.tap do |v|
          v.backgroundColor = '#ababab'.uicolor
        end

        ## body
        @bodyView << @commentLabel = TTTAttributedLabel.new.tap do |label|
          label.frame = CGRectZero
          label.numberOfLines = 0
          label.lineBreakMode = NSLineBreakByWordWrapping

          ## workaround: System Font では ParagraphStyle の日本語とASCIIのline height計算が異なっておかしくなる
          label.font = UIFont.fontWithName("HiraKakuProN-W3", size:17)

          label.dataDetectorTypes = NSTextCheckingTypeLink
          label.textAlignment = NSTextAlignmentLeft
          label.lineHeightMultiple = 0.8
          label.verticalAlignment = TTTAttributedLabelVerticalAlignmentCenter

          ## link attributes
          paragraph = NSMutableParagraphStyle.new
          paragraph.lineBreakMode = NSLineBreakByWordWrapping
          paragraph.lineHeightMultiple = 0.8

          label.linkAttributes       = {
            KCTForegroundColorAttributeName => '#3B5998'.uicolor,
            KCTParagraphStyleAttributeName  => paragraph
          }
          label.activeLinkAttributes = {
            KCTForegroundColorAttributeName => '#69c'.uicolor,
            KCTParagraphStyleAttributeName  => paragraph
          }
        end

        @bodyView << @faviconView = UIImageView.new.tap {|v| v.frame = CGRectZero }

        @bodyView << @titleButton = UIButton.buttonWithType(UIButtonTypeCustom).tap do |btn|
          btn.titleLabel.font = UIFont.systemFontOfSize(17)
          btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping
          btn.titleLabel.numberOfLines = 0
          btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft
          btn.backgroundColor = UIColor.whiteColor
          btn.setTitleColor('#3B5998'.uicolor, forState:UIControlStateNormal)
          btn.setTitleColor('#69c'.uicolor, forState:UIControlStateHighlighted)
          btn.setTitle("", forState:UIControlStateNormal)
        end

        @bodyView << @urlLabel = UILabel.new.tap do |v|
          v.frame = CGRectZero
          v.numberOfLines = 0
          v.font = UIFont.systemFontOfSize(14)
          v.textColor = '#666'.uicolor
          v.lineBreakMode = NSLineBreakByCharWrapping
          v.text = ""
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

    def delegate=(delegate)
      @commentLabel.delegate = delegate
    end

    def bookmark=(bookmark)
      @nameLabel.text    = bookmark.user.name


      if bookmark.comment.present?
        @commentLabel.setText(bookmark.comment, afterInheritingLabelAttributesAndConfiguringWithBlock:
          lambda do |string|
            return string
          end
        )
      end

      ## handle Hatena ID
      bookmark.comment.scan(%r{(id:[0-9a-zA-Z\-]{3,32})}) do |match|
        id = match[0]
        range = bookmark.comment.rangeOfString(id)
        id.gsub!(/id:/, '')
        @commentLabel.addLinkToURL("bookmark://#{id}".nsurl, withRange:range)
      end

      ## handle Twitter mention
      bookmark.comment.scan(%r{(@[0-9a-zA-Z_]{1,15})}) do |match|
        mention = match[0]
        range = bookmark.comment.rangeOfString(mention)
        mention.gsub!(/^@/, '')
        @commentLabel.addLinkToURL("twitter://#{mention}".nsurl, withRange:range)
      end

      @titleButton.setTitle(bookmark.title, forState:UIControlStateNormal)
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
      @bodyView.frame = self.bounds

      ## header
      @headerView.frame = [self.bounds.origin, [self.bounds.size.width, 68]]
      @profileImageView.frame = [[10, 10], [48, 48]]
      @nameLabel.frame = [[@profileImageView.right + 10, 10], [200, 48]]

      h = @headerView.bounds.size.height
      @discImageView.frame = [[@headerView.right - 20, (h / 2) - 6], [10, 14]]
      @border.frame = [[0, @headerView.bottom], [self.bounds.size.width, 1]]

      ## body
      if @commentLabel.text.present?
        constrain = CGSize.new(self.frame.size.width - 20, 1000)

        ## workaround: http://stackoverflow.com/questions/13621084/boundingrectwithsize-for-nsattributedstring-returning-wrong-size
        fitSize = CTFramesetterSuggestFrameSizeWithConstraints(
          CTFramesetterCreateWithAttributedString(@commentLabel.attributedText),
          CFRangeMake(0, @commentLabel.attributedText.length),
          nil,
          constrain,
          nil
        )

        ## workaround: 若干上が見きれるので height +10 する
        @commentLabel.frame = [[10, @border.bottom + 10], [fitSize.width, fitSize.height + 10] ]
      end

      y = @commentLabel.text.present? ? @commentLabel.bottom : @border.bottom + 5

      # favicon
      @faviconView.frame = [[10, y + 6], [16, 16]]

      # title
      constrain = CGSize.new(self.frame.size.width - 19 - 20, 1000) # 19 = favicon (16) + margin (3), 20 = margin left,right
      size = @titleButton.titleForState(UIControlStateNormal).sizeWithFont(
        UIFont.systemFontOfSize(17),
        constrainedToSize:constrain,
        lineBreakMode:NSLineBreakByWordWrapping
      )
      @titleButton.frame = [[@faviconView.right + 3, y + 4], size]

      # URL
      constrain = CGSize.new(self.frame.size.width - 19 - 20, 1000)
      size = @urlLabel.text.sizeWithFont(
        UIFont.systemFontOfSize(14),
        constrainedToSize:constrain,
        lineBreakMode:NSLineBreakByCharWrapping
      )
      @urlLabel.frame = [[@titleButton.left, @titleButton.bottom + 4], size]

      # date
      @dateLabel.frame = [[@titleButton.left, @urlLabel.bottom + 4], [0, 0]]
      @dateLabel.sizeToFit

      # star
      origin = @dateLabel.frame.origin
      @starView.origin = [origin.x + @dateLabel.frame.size.width + 3, origin.y + 3.5]

      # button
      @usersButton.frame = [[10, @dateLabel.bottom + 10], [self.frame.size.width - 20, 40]]
      @bodyView.contentSize = [self.frame.size.width, @usersButton.bottom + 142]
    end

    def dealloc
      NSLog("dealloc: " + self.class.name)
      super
    end
  end
end
