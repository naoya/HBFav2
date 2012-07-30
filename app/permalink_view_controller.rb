# -*- coding: utf-8 -*-
class PermalinkViewController < UIViewController
  attr_accessor :bookmark

  def viewDidLoad
    super

    self.navigationItem.title = "ブックマーク"
    self.view.backgroundColor = UIColor.whiteColor

    @headerView = UIView.new.tap do |v|
      v.frame = [[0, 0], [view.frame.size.width, 68]]
      v.backgroundColor = UIColor.groupTableViewBackgroundColor
      view << v
    end

    @imageView = UIImageView.new.tap do |v|
      v.frame = [[10, 10], [48, 48]]
      v.image = @bookmark.profile_image
      v.layer.tap do |l|
        l.masksToBounds = true
        l.cornerRadius  = 5.0
      end
      @headerView << v
    end

    @nameLabel = UILabel.new.tap do |v|
      v.frame = [[68, 10], [200, 48]]
      v.font  = UIFont.boldSystemFontOfSize(18)
      v.text  = @bookmark.user.name
      v.shadowColor = UIColor.whiteColor
      v.shadowOffset = [0, 1]
      v.backgroundColor = UIColor.clearColor
      @headerView << v
    end

    @border = UIView.new.tap do |v|
      v.frame = [[0, 68], [view.frame.size.width, 1]]
      v.backgroundColor = '#ababab'.uicolor
      view << v
    end

    ## ここから以降は ScrollView を作ってそこに add する必要
    current_y = 79
    if @bookmark.comment.length > 0
      constrain = CGSize.new(view.frame.size.width - 20, 1000)
      size = @bookmark.comment.sizeWithFont(
        UIFont.systemFontOfSize(18),
        constrainedToSize:constrain,
        lineBreakMode:UILineBreakModeCharacterWrap
      )
      @commentLabel = UILabel.new.tap do |v|
        v.frame = [[10, current_y], size]
        v.numberOfLines = 0
        v.font  = UIFont.systemFontOfSize(18)
        v.text = @bookmark.comment
        view << v
      end

      current_y += size.height + 10
    end

    @faviconView = UIImageView.new.tap do |v|
      v.frame = [[10, current_y + 2], [16, 16]]
      v.image = bookmark.favicon
      view << v
    end

    @titleLabel = UILabel.new.tap do |v|
      constrain = CGSize.new(view.frame.size.width - 19 - 20, 1000) # 19 = favicon (16) + margin (3)
      size = @bookmark.title.sizeWithFont(
        UIFont.systemFontOfSize(18),
        constrainedToSize:constrain,
        lineBreakMode:UILineBreakModeCharacterWrap
      )

      v.frame = [[10 + 19, current_y], size]
      v.numberOfLines = 0
      v.font = UIFont.systemFontOfSize(18)
      v.text = @bookmark.title
      v.textColor = '#3B5998'.to_color
      view << v

      current_y += size.height + 4

      v.whenTapped do
        WebViewController.new.tap do |c|
          c.bookmark = @bookmark
          navigationController.pushViewController(c, animated:true)
        end
      end
    end

    @urlLabel = UILabel.new.tap do |v|
      constrain = CGSize.new(view.frame.size.width - 19 - 20, 1000) # 19 = favicon (16) + margin (3)
      size = @bookmark.link.sizeWithFont(
        UIFont.systemFontOfSize(14),
        constrainedToSize:constrain,
        lineBreakMode:UILineBreakModeCharacterWrap
      )

      v.frame = [[10 + 19, current_y], size]
      v.numberOfLines = 0
      v.font = UIFont.systemFontOfSize(14)
      v.text = @bookmark.link
      v.textColor = '#666'.uicolor
      view << v

      current_y += size.height + 4
    end

    @dateLabel = UILabel.new.tap do |v|
      v.frame = [[10 + 19, current_y], [0, 0]]
      v.font = UIFont.systemFontOfSize(14)
      v.text = @bookmark.created_at
      v.textColor = '#666'.uicolor
      v.sizeToFit
      view << v

      current_y += v.frame.size.height + 10
    end

    @usersButton = UIButton.buttonWithType(UIButtonTypeRoundedRect).tap do |v|
      v.frame = [[10, current_y], [view.frame.size.width - 20, 40]]
      v.setTitle(bookmark.count + " users", forState:UIControlStateNormal)

      v.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft
      v.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)

      view << v
    end
  end

  def viewWillAppear(animated)
    super(animated)
    self.navigationController.toolbarHidden = true
  end

end
