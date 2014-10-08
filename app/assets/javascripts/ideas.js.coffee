# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $('a.help').popover({
    placement : 'top',
    html : 'true',
    content : 'GitHub Flavoured Markdown is supported here. Read more about the supported syntax <a href="https://help.github.com/articles/github-flavored-markdown/">here</a>.'});
