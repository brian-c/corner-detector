drawingSurface = document.getElementById 'drawing-surface'

draw = (className, left, top, parent = document.body) ->
  point = document.createElement 'div'
  point.classList.add className
  point.style.left = "#{left}px"
  point.style.top = "#{top}px"
  parent.appendChild point

new CornerDetector
  el: drawingSurface

  onDraw: (e) ->
    draw 'track', e.pageX, e.pageY

  onFinishGesture: (gesture) ->
    console.log gesture
    for [left, top] in gesture.corners
      draw 'corner', left, top, drawingSurface
