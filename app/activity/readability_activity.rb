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
    ## TODO: url escape
    token = 'c523147005e6a6af0ec079ebb7035510b3409ee5'
    api = "https://www.readability.com/api/content/v1/parser?url=#{@url}&token=#{token}"

    SVProgressHUD.showWithStatus("変換中...")
    BW::HTTP.get(api) do |response|
      if response.ok?
        SVProgressHUD.dismiss
        data = BW::JSON.parse(response.body.to_str)
        ReadabilityViewController.new.tap do |c|
          c.data = data

          ## debug
          puts data

          self.navigationController.pushViewController(c, animated:true)
        end
      else
        SVProgressHUD.showErrorWithStatus("失敗: " + response.status_code.to_s)
      end
    end
    activityDidFinish(true)
  end
end
