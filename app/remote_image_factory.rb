# -*- coding: utf-8 -*-
class RemoteImageFactory
  private_class_method:new
  @@obj = {}

  ## named singleton
  def self.instance(id)
    @@obj[id] ||= new
  end

  def initialize
    @pool = {}
    @semaphore = Dispatch::Semaphore.new(1)
  end

  ## FIXME: キャッシュするインスタンス数に上限を設ける必要
  def image (url)
    if not @pool[url]
      @semaphore.wait(Dispatch::TIME_FOREVER)
      @pool[url] = UIImage.alloc.initWithData(NSData.dataWithContentsOfURL(url.nsurl))
      @semaphore.signal
    end
    return @pool[url]
  end
end
