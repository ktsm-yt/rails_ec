# frozen_string_literal: true

module ApplicationHelper
  def hidden_field_tag(_name, _value = nil, _options = {})
    raise 'Happiness chainではhidden_field_tagの使用を禁止しています'
  end

  def flash_alert_class(key)
    case key.to_sym
    when :notice then 'alert-success'
    when :alert, :error then 'alert-danger'
    when :warning then 'alert-warning'
    when :info then 'alert-info'
    else 'alert-secondary'
    end
  end
end
