document.addEventListener "DOMContentLoaded", (event) ->
  event.stopPropagation()
  element = document.querySelector ".cube"
  computedStyle = window.getComputedStyle element
  radiusElementX = parseInt(computedStyle.width) / 2
  radiusElementY = parseInt(computedStyle.height) / 2

  animation = new Animation element
  animation.start "webkitTransform": "rotateX(~0~deg) rotateY(~0~deg)", opacity: 0.5, 60, 3000

  window.addEventListener "mousemove", (event) ->
    event.stopPropagation()
    x = event.pageX - radiusElementX
    y = event.pageY - radiusElementY

    animation.use "webkitTransform": "rotateX(~#{y}~deg) rotateY(~#{x}~deg)", opacity: ( x + y ) / 1000


###
Animation uses for regulate state of the animation
  start - take starts data
  use - take on live new data and save it's
###

class Animation
  constructor: (element) ->
    @style = element.style
    @value = { }
    @lastPosition = { }

  formula: (lastPosition, value) ->
    if value > lastPosition and (Math.ceil(lastPosition) isnt value) or value < lastPosition and (Math.floor(lastPosition) isnt value)
      speed = value - lastPosition
      position = lastPosition + speed * Math.ceil(Math.abs(speed) / @resist * 100) / 100

  live: ->
    for prop, value of @value
      if typeof value is "string"
        components = value.split "~"
        result = ""
        for component, n in components
          propName = component unless n % 2
          if n % 2
            proppers = @lastPosition[prop]
            lastPosition = @lastPosition[prop][propName]
            value = ~~component
            position = @formula proppers[propName], value
            if position
              proppers[propName] = position
              result += propName + position
            else result += propName + proppers[propName]
        @style[prop] = result + propName
      else
        lastPosition = @lastPosition[prop]
        position = @formula lastPosition, value
        @lastPosition[prop] = @style[prop] = position
    if position then setTimeout (=> @live()), @delay
    else
      for prop, value of @value
        proppers = @lastPosition[prop]
        if typeof value is "string"
          components = value.split "~"
          for component, n in components
            propName = component unless n % 2
            proppers[propName] = ~~component if n % 2
        else proppers = value
      @_status = 0

  start: (startData, fps, @resist) ->
    @delay = 1000 / fps
    for prop, value of startData
      @style[prop] = value
      if typeof value is "string"
        components = value.split "~"
        result = ""
        proppers = @lastPosition[prop] = { }
        for component, n in components
          propName = component unless n % 2
          if n % 2
            proppers[propName] = ~~component
            result += propName + component
        @style[prop] = result + propName
      else
        @lastPosition[prop] = @style[prop] = value

  use: (actualData) ->
    @value[prop] = value for prop, value of actualData
    unless @_status
      @_status = 1
      @live()