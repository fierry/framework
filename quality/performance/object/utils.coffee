performance '/object.utils'

  'Object keys':
    before: -> @h = {a:0, b:1, c:2, d:3, e:4, f:5, g:6, h:7, i:8, j:9}
    run:    -> Object.keys(h)
