module ApplicationHelper
  def flash_class_for(flash_level)
    case flash_level
    when 'error'
      'bg-danger'
    when 'warning'
      'bg-warning'
    when 'notice'
      'bg-success'
    else
      'bg-info'
    end
  end
end
