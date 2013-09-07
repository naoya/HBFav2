# -*- coding: utf-8 -*-
class StarsViewController < HBFav2::UITableViewController
  attr_accessor :url

  def viewDidLoad
    super

    @stars = []
    navigationItem.title = "スター"
    self.tracked_view_name = "Stars"
    view.backgroundColor = UIColor.whiteColor

    BW::HTTP.get('http://s.hatena.com/entry.json', {payload: {uri: url}}) do |response|
      if response.ok?
        data = BW::JSON.parse(response.body.to_str)
        entry = data['entries'].first
        if entry and entry['stars'].present?
          @stars = entry['stars'].collect do |star|
            Star.new(
              {
                :user  => User.new({ name: star["name"]}),
                :url   => entry["uri"],
                :color => nil,
                :quote => star["quote"]
              }
            )
          end
        end
        view.reloadData
      else
        App.alert(response.error_message)
      end
    end
  end

  def viewWillAppear(animated)
    self.navigationItem.leftBarButtonItem  = UIBarButtonItem.stop.tap do |btn|
      btn.target = self
      btn.action = 'on_close'
    end
    super
  end

  def on_close
    self.dismissViewControllerAnimated(true, completion:nil)
  end

  def tableView(tableView, numberOfRowsInSection:section)
    @stars.size
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    StarCell.cellForStar(@stars[indexPath.row], inTableView:tableView)
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    StarCell.heightForStar(@stars[indexPath.row], tableView.frame.size.width)
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    # ProfileViewController.new.tap do |c|
    #  c.user = @stars[indexPath.row].user
    # end

    controller = TimelineViewController.new.tap do |c|
      c.user  = @stars[indexPath.row].user
      c.content_type = :bookmark
      c.title = @stars[indexPath.row].user.name
    end
    self.navigationController.pushViewController(controller, animated:true)
  end

  def dealloc
    NSLog("dealloc: " + self.class.name)
    super
  end
end
