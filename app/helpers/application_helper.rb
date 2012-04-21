module ApplicationHelper

  # Flash stuff comes from http://rubypond.com/blog/useful-flash-messages-in-rails

  FLASH_NOTICE_KEYS = [:error, :notice, :warning, :alert]

  def flash_messages
    messages = flash.keys.select{|k| FLASH_NOTICE_KEYS.include?(k)}
    return unless messages.length > 0
    formatted_messages = messages.map do |type|
      '<div class = "alert alert-' + type.to_s + '"><a class="close" data-dismiss="alert" href="#">&times;</a>' +
          message_for_item(flash[type], flash["#{type}_item".to_sym]) + '</div>'
    end
    '<div class="row"><div class="span6 offset3">'+formatted_messages.join+'</div></div>'
  end

  def message_for_item(message, item = nil)
    if item.is_a?(Array)
      message % link_to(*item)
    else
      message % item
    end
  end

end
