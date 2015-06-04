module IdeasHelper
  # TODO adapt formatted_body to accept a length?
  def truncated_formatted_body(idea)
    pipeline = HTML::Pipeline.new [
      HTML::Pipeline::MarkdownFilter,
      HTML::Pipeline::SanitizationFilter
    ]

    truncated_body = idea.body.truncate(250, separator: /\s/) + " " + link_to('continue reading', idea_path(idea))
    result = pipeline.call(truncated_body)
    result[:output].to_s.html_safe
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
