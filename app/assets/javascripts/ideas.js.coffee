# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $(".auto-replace").focus ->
    val = $(this).val()
    if val is $(this).attr('data-default')
      $(this).val('')
    else
      console.log "Not replacing because value is " + val

  $(".auto-replace").blur ->
    val = $(this).val()
    if val is ""
      $(this).val($(this).attr('data-default'))
    else
      console.log "Not replacing because value is " + val

  counter = ->
    value = $("#idea-body").val()
    if value.length is 0
      $("#word-count").html 0
      return
    regex = /\s+/g
    wordCount = value.trim().replace(/\[[^\]]*\]|\([^\)]*\)/g,'').replace(regex, " ").split(" ").length
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
  $("#idea-body").focus counter

  $("#preview-button").on 'click', (e) ->
    e.preventDefault()

  $('#myModal').on 'show.bs.modal', (e) ->
    md_title = $('#idea_title').val()
    md_body = $('#idea-body').val()
    $.ajax '/ideas/preview',
      data :
        idea : md_body
      success  : (res, status, xhr) ->
        $(e.currentTarget).find('#modalIdeaTitle').html(md_title)
        $(e.currentTarget).find('#modalIdeaBody').html(res)
      error    : (xhr, status, err) ->
        alert "There was a problem with the idea preview"
      complete : (xhr, status) ->
