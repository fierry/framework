#
# @require:
#   view:     fierry-pfc/view_2/create/p1x1x1x3x3.
#
#   View:     fierry/view_3/view
#   Behavior: fierry/view_3/behavior   
#



behavior = new Behavior()
return new View(null, behavior, (_, world) -> view.use(_, @, world))
