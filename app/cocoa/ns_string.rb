# -*- coding: utf-8 -*-
class NSString
  def truncate(truncate_at, options = {})
    return dup unless length > truncate_at
    options[:omission] ||= '...'
    length_with_room_for_omission = truncate_at - options[:omission].length
    stop = if options[:separator]
             rindex(options[:separator], length_with_room_for_omission) || length_with_room_for_omission
           else
             length_with_room_for_omission
           end

    "#{self[0...stop]}#{options[:omission]}"
  end
end
