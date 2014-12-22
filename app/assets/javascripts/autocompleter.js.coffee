username_strategy =
  match: /(^|\s)@(\w*)$/;
  search: (name, callback)->
    search_call = $.getJSON("/user_lookup", {query: name})
    search_call.done (result)->
      callback( result.map (r)-> r.name)
    search_call.fail -> callback([],true)
  replace: (entry)->
    "@#{entry} "
  template: (entry)->
    "@#{entry}"

idea_title_strategy =
  match: /(^|\s)#(\w*)$/;
  search: (name, callback)->
    search_call = $.getJSON("/idea_title_lookup", {query: name})
    search_call.done (result)->
      callback result
    search_call.fail -> callback([],true)
  replace: (entry)->
    "[#{entry.title.substring(0,10).replace(" ","_")}](#{entry.doi}) "
  template: (entry)->
    "#{entry.title}"

strategies = [username_strategy, idea_title_strategy ]

$ ->
  $(".auto-complete").textcomplete(strategies,{})
