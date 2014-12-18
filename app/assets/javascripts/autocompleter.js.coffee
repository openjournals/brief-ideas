username_strategy =
  match: /(^|\s)@(\w*)$/;
  search: (name, callback)->
    search_call = $.getJSON("/user_lookup",{name: name})
    search_call.done (result)->
      callback( result.map (r)-> r.name)
    search_call.fail -> callback([],true)
  replace: (entry)->
    " @#{entry} "
  template: (entry)->
    "@#{entry}"


stratagies = [username_strategy]


$ ->
  $(".auto-complete").textcomplete(stratagies,{})
