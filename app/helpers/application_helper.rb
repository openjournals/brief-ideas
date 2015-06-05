module ApplicationHelper
  def flash_class_for(flash_level)
    case flash_level
    when 'error'
      'alert-danger'
    when 'warning'
      'alert-warning'
    when 'notice'
      'alert-success'
    else
      'alert-info'
    end
  end

  def nav_link(link_text, link_path)
    class_name = current_page?(link_path) ? 'active' : ''

    content_tag(:li, :class => class_name) do
      link_to link_text, link_path
    end
  end

  def linked_authors(idea, orcid_links)
    result = []
    idea.authors.each do |author|
      if orcid_links
        result << link_to(author.nice_name, author.orcid_url, :target => "_blank")
      else
        result << link_to(author.nice_name, user_path(author))
      end
    end
    result.join(', ').html_safe
  end
end
