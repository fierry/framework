#
# @require:
#   Behavior: fierry/view/behavior
#



class Event extends Behavior

  create: ($, parent) ->
    $.node = parent.node

  update: ($) ->
    $.node.addEventListener($.value) if $.value
    $.node.removeEventListener($.old_value) if $.old_value?

    $.old_value = $.value

  dispose: ($) ->
    $.node.removeEventListener($.value) if $.value?



return new Event()
