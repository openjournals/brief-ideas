username_strategy =
  match: /(^|\s)@(\w*)$/;
  search: (name, callback)->
    search_call = $.getJSON("/user_lookup", {query: name})
    search_call.done (result)->
      callback result
    search_call.fail -> callback([],true)
  replace: (entry)->
    "[#{entry.nice_name}](/users/#{entry.sha}) "
  template: (entry)->
    "@#{entry.nice_name}"

idea_title_strategy =
  match: /(^|\s)#(\w*)$/;
  search: (name, callback)->
    search_call = $.getJSON("/idea_title_lookup", {query: name})
    search_call.done (result)->
      callback result
    search_call.fail -> callback([],true)
  replace: (entry)->
    "[#{entry.title.substring(0,10).replace(" ","_")}](/ideas/#{entry.sha}) "
  template: (entry)->
    "#{entry.title}"

strategies = [username_strategy, idea_title_strategy ]

$ ->
  $(".auto-complete").textcomplete(strategies,{})
