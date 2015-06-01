atom_feed do |feed|
  feed.title("Journal of Brief Ideas: Collection #{@collection.name}")
  feed.updated(@collection.collection_ideas.last.created_at) if @collection.ideas.length > 0

  @collection.ideas.each do |idea|
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
