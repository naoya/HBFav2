module HBFav2
  class HatenaStarView < UIImageView
    @@blank_image = UIImage.imageNamed('blank')

    def initWithFrame(frame)
      if super
        self.userInteractionEnabled = true
      end
      self
    end
    # def initWithFrame(frame)
    #   if super
    #     self.frame = CGRectZero
    #     self.backgroundColor = '#fff'.uicolor
    #   end
    #   self
    # end
    def set_url(url, &cb)
      api_url = "http://s.st-hatena.com/entry.count.image?uri=#{url.escape_url}&q=1"
      self.setImageWithURL(
        api_url.nsurl,
        placeholderImage:@@blank_image,
        options:SDWebImageCacheMemoryOnly|SDWebImageLowPriority,
        completed: lambda do |image, error, cacheType|
          if image
            # self.frame = [self.frame.origin, [image.size.width / 2, image.size.height / 2]]
            self.size = [image.size.width / 2, image.size.height / 2]
          end
          cb.call(image, error, cacheType) if cb
        end
      )
    end

    def url=(url)
      self.set_url(url)
    end

    def dealloc
      NSLog("dealloc: " + self.class.name)
      super
    end
  end
end
