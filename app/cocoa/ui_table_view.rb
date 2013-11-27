class UITableView
  def reloadDataWithKeepingSelectedRowAnimated(animated)
    indexPath = self.indexPathForSelectedRow
    self.reloadData
    # self.reloadDataWithRowAnimation(UITableViewRowAnimationNone)
    self.selectRowAtIndexPath(indexPath, animated:animated, scrollPosition:UITableViewScrollPositionNone);
  end

  def reloadDataWithRowAnimation(animation)
    indexSet = NSIndexSet.indexSetWithIndex(0)
    self.reloadSections(indexSet, withRowAnimation:animation)
  end

  def reloadDataWithDeselectingRowAnimated(animated)
    indexPath = self.indexPathForSelectedRow
    self.reloadData
    # self.reloadDataWithRowAnimation(UITableViewRowAnimationNone)
    self.selectRowAtIndexPath(indexPath, animated:animated, scrollPosition:UITableViewScrollPositionNone);
    self.deselectRowAtIndexPath(indexPath, animated:animated);
  end
end
