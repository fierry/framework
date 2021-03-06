return class Element

  create: ($) ->
    $.node  = document.createElement($.type())
    $.pnode = $.parent().node


  finalize: ($) ->
    if f = $.next_sibling(Element)
      $.pnode.insertBefore($.node, f.node)

    else
      $.pnode.appendChild($.node)


  dispose: ($) ->
    $.pnode.removeChild($.node)
