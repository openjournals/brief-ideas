# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $(".auto-replace").focus ->
    val = $(this).val()
    if val is $(this).attr('data-default')
      $(this).val('')

  $(".auto-replace").blur ->
    val = $(this).val()
    if val is ""
      $(this).val($(this).attr('data-default'))

  $('a.help').popover({
    placement : 'top',
    html : 'true',
    content : 'GitHub Flavoured Markdown is supported here. Read more about the supported syntax <a href="https://help.github.com/articles/github-flavored-markdown/">here</a>.'});

  check_body_contents = ->
    idea = $("#idea-body")
    if match = /consectetur adipiscing elit/.test(idea.val())
      idea.empty()

  counter = ->
    value = $("#idea-body").val()
    if value.length is 0
      $("#word-count").html 0
      return
    regex = /\s+/g
    wordCount = value.trim().replace(regex, " ").split(" ").length
    if wordCount > 200
      $("#word-count").addClass("warning")
      $("form#new_idea button").attr("disabled", "disabled")
    else
      $("#word-count").removeClass("warning")
      $("form#new_idea button").removeAttr("disabled")
    $("#word-count").html wordCount
    return

  $("#idea-body").change counter
  $("#idea-body").keydown counter
  $("#idea-body").keypress counter
  $("#idea-body").keyup counter
  $("#idea-body").blur counter
  $("#idea-body").focus counter, check_body_contents
