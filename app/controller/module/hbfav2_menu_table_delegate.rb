module HBFav2
  module MenuTableDelegate
    def tableView(tableView, cellForRowAtIndexPath:indexPath)
      id = "basis-cell"
      rowData = @dataSource[indexPath.section][:rows][indexPath.row]

      cell = tableView.dequeueReusableCellWithIdentifier(id) || UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:id)
      cell.textLabel.text = rowData[:label]
      cell.detailTextLabel.text = rowData[:detail]

      if (color = rowData[:color])
        cell.textLabel.textColor = color
      end

      if (accessory = rowData[:accessoryType])
        cell.accessoryType = accessory
      end

      cell
    end

    def tableView(tableView, titleForHeaderInSection:section)
      if (title = @dataSource[section][:title])
        return title
      end
    end

    def tableView(tableView, numberOfRowsInSection:section)
      @dataSource[section][:rows].size
    end

    def numberOfSectionsInTableView (tableView)
      @dataSource.size
    end

    def tableView(tableView, didSelectRowAtIndexPath:indexPath)
      if (action = @dataSource[indexPath.section][:rows][indexPath.row][:action])
        self.send(action)
      end
    end
  end
end
