# ioio.js {{ VERSION }} - Semantic Video UI
# (c) 2012 InsideOut10, Enel SpA, IKS Consortium
# ioiojs may be freely distributed under the MIT license.
# For all details and documentation:
# http://wordlift.insideout.io/
(($) ->
  
  # a window has a width and a height (really?).
  # we want to tune the contents so that they fill the window.
  # we'll start with the height.
  # our content is structured in this way:
  #  - section -> set a css height on this element.
  #    - background
  #    - container
  #      - header
  #      - content
  #        - ...
  
  # the following elements must match the window's height:
  #  -section, -background, -container.
  # the following elements will change their height according the window's height:
  #  -header: fixed height, -content: window's height - header
  
  # we also have a constraint in width, i.e.
  #  -background, and -container must be fixed at xyz px.
  
  # fake the debug if it doesn't exist.
  if false is (debug = window.debug)?
    debug = {log: -> }

  methods =
    init: (options) ->

      # set-up the settings.
      settings = $.extend
        selectors:
          background: ".background"
          container: ".container"
          content: ".content"
          header: ".header"
      ,options


      ####### R E S I Z E #######
      # recalculate on resize.
      $(window).on("resize scroll", =>
        clearTimeout(@data("resizeTimeout"))
        @data(
          resizeTimeout: setTimeout (=> @fillify("resize", settings)), 200
        )
      )

      @fillify("resize", settings)

    resize: (settings) ->

      return @each (index, item) ->
        # create a reference to the jQuery instance over the element.
        element = $(item)

        windowHeight = methods.getWindowHeight()
        windowWidth = methods.getWindowWidth()

        prevWidth = element.data("windowWidth")
        prevHeight = element.data("windowHeight")

        if windowHeight is prevHeight and windowWidth is prevWidth
          # debug.log("fillify", "skipping resize as size didn't change.")
          return true

        # save current size for future checks.
        element.data( { windowWidth: windowWidth, windowHeight: windowHeight } )

        # attempt to get the background image ratio.
        backgroundImage = element.find("#{settings.selectors.background} img")

        if (0 < backgroundImage.length)
          backgroundRatio = backgroundImage.data("ratio")

          # calculate the background image ratio.
          if not backgroundRatio?
            backgroundRatio = parseInt( backgroundImage.css("width"), 10) / parseInt( backgroundImage.css("height"), 10)
            backgroundImage.data({ratio: backgroundRatio})

        # calculate the desired with of the container using the stylesheets.
        width = element.css("width")

        if "%" is width.charAt(width.length - 1)
          width = $(window).width() * width
        else
          width = parseInt( width, 10 )

        # apply the width to all the children elements.
        element.children().width(width)

        ####### B A C K G R O U N D   A N D   C O N T A I N E R #######
        # set the width and height of the background.
        # set also the margin, as the background has a position:absolute and won't automatically be centered.
        # debug.log "setting the background and container geometry [#{width}/#{windowHeight}][margin:#{margin}]"      

        element.children("#{settings.selectors.background}")
          .css("overflow", "hidden")

        element.children("#{settings.selectors.background}")
          .css("height", windowHeight)
          .css("width", width)
          # .css("margin", margin)

        ##### C O N T A I N E R #####
        container = element.children("#{settings.selectors.container}")
        horizontalMargin = parseInt( container.css("margin-left"), 10) + 
                  parseInt( container.css("margin-right"), 10) +
                  parseInt( container.css("padding-left"), 10) + 
                  parseInt( container.css("padding-right"), 10)

        containerWidth = width - horizontalMargin
        verticalMargin = parseInt( container.css("margin-top"), 10) + 
                  parseInt( container.css("margin-bottom"), 10) +
                  parseInt( container.css("padding-top"), 10) + 
                  parseInt( container.css("padding-bottom"), 10)

        containerHeight = windowHeight - verticalMargin
        container
          .css("width", containerWidth)
          .css("height", containerHeight)


        ####### C O N T E N T #######
        # set the content height.
        contents = element.find("#{settings.selectors.container} #{settings.selectors.content}")
        contentHorizontalMargin = parseInt( contents.css("margin-left"), 10) + 
                  parseInt( contents.css("margin-right"), 10) +
                  parseInt( contents.css("padding-left"), 10) + 
                  parseInt( contents.css("padding-right"), 10)
        contentWidth = containerWidth - contentHorizontalMargin; # methods.getContainerWidth(element, settings)
        contentHeight = methods.getContentHeight(element, settings)

        contents
          .css("width", contentWidth)
          .css("height", contentHeight)
          
        ####### B A C K R O U N D   I M A G E #######
        # set the image background size. if the width is smaller than the minimum width, then
        #  set the width and crop the height.
        if 0 < backgroundImage.length

          backgroundImage
            .height(windowHeight)
            .width(windowHeight * backgroundRatio)

          debug.log("background width and height set.", width, backgroundImage.width())

          if width > backgroundImage.width()
            backgroundImage
              .width(width)
              .height(width / backgroundRatio)

            debug.log("forcing background width and height.")

        element.trigger("fillify.fillify")

    getWindowHeight: ->
      # see http://bugs.jquery.com/ticket/6724
      if window.innerHeight then window.innerHeight else $(window).height()
    getWindowWidth: ->
      $(window).width()
    getContainerWidth: (element, settings) ->
      element.find("#{settings.selectors.container}").width()
    getContentElement: (element, settings) ->
      element.find("#{settings.selectors.container} #{settings.selectors.content}")
    getContentHeight: (element, settings) ->
      containerHeight = element.find("#{settings.selectors.container}").height()
      headerHeight = element.find("#{settings.selectors.container} #{settings.selectors.header}").height()
      contentElement = methods.getContentElement(element, settings)
      contentMargin = contentElement.outerHeight() - contentElement.height() 
      containerHeight - headerHeight - contentMargin


  $.fn.fillify = (method) ->
    return methods[method].apply( @, Array.prototype.slice.call( arguments, 1 )) if ( methods[method] )

    return methods.init.apply( @, arguments ) if 'object' is typeof method or not method?

    $.error( 'Method ' +  method + ' does not exist.' );

)(jQuery)