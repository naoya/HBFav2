# -*- coding: utf-8 -*-
class PocketActivity < UIActivity
  include URLPerformable

  def activityType
    "net.bloghackers.app.PocketActivity"
  end

  def activityImage
    UIImage.imageNamed("NNPocketActivity") # borrowed from NNNetwork (https://github.com/tomazsh/NNNetwork)
  end

  def activityTitle
    "Pocket"
  end

  def performActivity
    PocketAPI.sharedAPI.saveURL(@url, handler: lambda do |api, url, error|
        if error
          App.alert(error.localizedDescription)
        else
#          @toast.done("保存しました")
#          @toast = nil
        end
      end
    )
    activityDidFinish(true)
  end
end
