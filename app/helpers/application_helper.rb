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

  def nav_link(link_text, link_path)
    class_name = current_page?(link_path) ? 'active' : ''

    content_tag(:li, :class => class_name) do
      link_to link_text, link_path
    end
  end
end
