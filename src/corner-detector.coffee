class Gesture
  @points: null
  @corners: null

  constructor: (@points, {samples, minAngle, minDistance}) ->
    lastIndex = @points.length - 1
    skip = Math.floor lastIndex / Math.min samples, lastIndex
    sample = (point for point in @points by skip)

    angles = for _, i in sample
      [x1, y1] = sample[i]
      [x2, y2] = sample[i + 1] ? sample[0]

      Math.atan2(y2 - y1, x2 - x1) * (180 / Math.PI)

    allCorners = for _, i in angles
      a1 = angles[i]
      a2 = angles[i + 1] ? angles[0]
      diff = Math.abs a2 - a1

      continue unless i in [0, sample.length - 1] or diff > minAngle
      sample[i]

    @corners = for _, i in allCorners
      [x1, y1] = allCorners[i]
      [x2, y2] = allCorners[i + 1] ? allCorners[0]

      a = x2 - x1
      b = y2 - y1
      c = Math.sqrt a * a + b * b

      continue unless c > minDistance
      allCorners[i]

class CornerDetector
  samples: 50
  minAngle: 50
  minDistance: 10

  el: null

  mouseMovements: null

  constructor: (params) ->
    @[property] = value for own property, value of params when property of @

    @el = document.querySelector @el if typeof @el is 'string'
    @el ?= document.createElement 'div'

    @el.addEventListener 'mousedown', @onMouseDown

  onMouseDown: (e) =>
    e.preventDefault()

    @mouseMovements = []

    document.addEventListener 'mousemove', @onDocMouseDrag
    document.addEventListener 'mouseup', @onDocMouseUp

    @onDocMouseDrag e

  onDocMouseDrag: (e) =>
    elOffset = @offsetOf @el
    x = e.pageX - elOffset.left
    y = e.pageY - elOffset.top

    @mouseMovements.push [x, y]
    @onDraw e

  offsetOf: (element) ->
    left = element.offsetLeft
    top = element.offsetTop

    if element.offsetParent?
      parent = @offsetOf element.offsetParent
      left += parent.left
      top += parent.top

    {left, top}

  onDocMouseUp: (e) =>
    document.removeEventListener 'mousemove', @onDocMouseDrag
    document.removeEventListener 'mouseup', @onDocMouseUp

    @onFinishGesture new Gesture @mouseMovements, @
    @mouseMovements = null

  onDraw: (e) -> # Override me!

  onFinishGesture: (gesture) -> # Override me!

module?.exports = CornerDetector
window?.CornerDetector = CornerDetector
