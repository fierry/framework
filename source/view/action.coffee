#
# @require:
#   array: fierry/util/array.
#   nodes: fierry/view/nodes.
#
#   Subscriber: fierry/emitter/subscriber
#



#
# Compares two Action instances.
#
COMPARE_FN = (a,b) -> a.uid - b.uid



return class Action

  #
  # Constructor for Action class. Instances of this class are
  # usually created inside array literal that is returned from
  # directly from a function. Because of that, creating an array
  # or function property inside the constructor will compromise
  # the object's initialization performance (by a factor of 2).
  #
  constructor: (@type, @uid, @parent, @behavior_, @value_fn_, @nodes_fn_) ->

  create: ->

    # Getting @parent.finalized makes flat representation 
    # 2.5 times slower. Don't know why, dont care (?)
    @parent.attach(@) if @parent and @parent.finalized

    # Chrome optimalization bug. The following lines makes view
    # 5-7 times faster than running "@update_ = => @update()" 
    # which yields exactly the same results.
    @update_ = (fn = => @update())

    @tracker_ = new Subscriber(@update_)
    @tracker_.start_tracking()

    @value = @value_fn_()
    @nodes = @nodes_fn_()

    @behavior_ ?= @parent.get_behavior_for(@type)
    @behavior_.create(@)
    @behavior_.update(@)
    return


  finalize: ->
    @behavior_.finalize(@) # Teoretically here tracker should be also activated!
    
    @tracker_.stop_tracking()
    @tracker_.subscribe_all()

    @finalized = true
    return @


  update: ->
    return if @disposed

    @tracker_.start_tracking()
    @value = @value_fn_()

    @behavior_.update(@)

    [old_nodes, new_nodes] = @_get_changed_nodes()
    nodes.dispose(node) for node in old_nodes
    nodes.execute(node) for node in new_nodes

    @tracker_.stop_tracking()
    @tracker_.subscribe_all()
    return


  _get_changed_nodes: ->
    old_nodes = []
    new_nodes = []

    a = 0
    b = 0
    arra = @nodes
    arrb = @nodes_fn_()
    
    while a < arra.length and b < arrb.length
      ua = arra[a].uid
      ub = arrb[b].uid

      if ua < ub
        old_nodes.push(arra[a])
        a++

      if ua > ub
        new_nodes.push(arrb[b])
        b++

      if ua is ub
        a++
        b++

    if a < arra.length
      old_nodes = old_nodes.concat(arra.slice(a))

    if b < arrb.length
      new_nodes = new_nodes.concat(arrb.slice(b))
    
    return [old_nodes, new_nodes]


  dispose: ->
    @parent.detach(@) if @parent && not @parent.disposed
    @disposed = true

    @behavior_.dispose(@)
    @tracker_.unsubscribe_all()

    nodes.dispose(node) for node in @nodes
    @nodes = []


  attach: (node) ->
    array.insert_cst(@nodes, node, COMPARE_FN)


  detach: (child) ->
    array.remove(@nodes, child)

  
  get_behavior_for: (type) ->
    behavior = @behavior_.get_cachedbehavior_(type)

    if not behavior
      throw new Error "Behavior for '#{type}' not found."
    return behavior


  # Looks like Array.prototype.filter!
  find: (fn) ->
    return fn(@nodes)
