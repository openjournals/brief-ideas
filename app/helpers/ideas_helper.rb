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
end
