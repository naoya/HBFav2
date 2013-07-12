# -*- coding: utf-8 -*-
class ReadabilityActivity < UIActivity
  attr_accessor :navigationController
  include URLPerformable

  def activityType
    "net.bloghackers.app.ReadabilityActivity"
  end

  def activityImage
    UIImage.imageNamed("Readability-activity")
  end

  def activityTitle
    "Readability"
  end

  def performActivity
    self.navigationController.pushViewController(
      ReadabilityViewController.new.tap { |c| c.url = @url.absoluteString },
      animated:true
    )
    activityDidFinish(true)
  end
end
