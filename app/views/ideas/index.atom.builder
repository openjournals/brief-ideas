atom_feed do |feed|
  feed.title("Journal of Brief Ideas: Ideas from the last week")
  feed.updated(@ideas[0].created_at) if @ideas.length > 0

  @ideas.each do |idea|
    feed.entry(idea) do |entry|
      entry.title(idea.title)
      entry.doi(idea.doi)
      entry.content(idea.body, type: 'html')

      entry.author do |author|
        author.name(idea.user.name)
      end
    end
  end
end
