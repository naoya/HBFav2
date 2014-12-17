module HBFav2
  class HatenaStarView < UIImageView
    @@blank_image = UIImage.imageNamed('blank')
    @@is_retina   = UIScreen.mainScreen.scale >= 2.0

    def initWithFrame(frame)
      if super
        self.userInteractionEnabled = true
      end
      self
    end

    def set_url(url, &block)
      api_url = "http://s.st-hatena.com/entry.count.image?uri=#{url.escape_url}&q=1"

      self.setImageWithURLRequest(api_url.nsurl.request, placeholderImage:@@blank_image,
        success: lambda do |request, response, image|
          self.image = image
          if @@is_retina
            self.size = image.size
          else
            self.size = [image.size.width / 2, image.size.height / 2]
          end
          block.call(request, response, image) if block
        end,
        failure: lambda { |request, response, error| }
      )
    end

    def url=(url)
      self.set_url(url)
    end
  end
end
