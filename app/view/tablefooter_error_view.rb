# -*- coding: utf-8 -*-
class TableFooterErorView < UIView
  def initWithFrame(frame)
    if super
      self.backgroundColor = '#fff'.uicolor

      self << @titleLabel = UILabel.new.tap do |v|
        v.backgroundColor = UIColor.clearColor
        v.text = "フィードの読み込みエラー"
        v.font = UIFont.boldSystemFontOfSize(14)
        v.textColor = '#000'.uicolor
        v.sizeToFit
      end

      self << @subTitleLabel = UILabel.new.tap do |v|
        v.backgroundColor = UIColor.clearColor
        v.text = "タップしてリトライ"
        v.font = UIFont.systemFontOfSize(12)
        v.textColor = '#999'.uicolor
        v.sizeToFit
      end
    end
    self
  end

  def layoutSubviews
    super
    @titleLabel.center = [ bounds.size.width / 2, bounds.size.height / 2 ]
    @titleLabel.top = 5

    @subTitleLabel.center = [ bounds.size.width / 2, bounds.size.height / 2 ]
    @subTitleLabel.top = @titleLabel.bottom + 2
  end
end
