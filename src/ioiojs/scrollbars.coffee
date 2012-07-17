# ioio.js {{ VERSION }} - Semantic Video UI
# (c) 2012 InsideOut10, Enel SpA, IKS Consortium
# ioiojs may be freely distributed under the MIT license.
# For all details and documentation:
# http://wordlift.insideout.io/
(($) ->

  $.fn.contentWidth = ->
    Math.max.apply( Math, @children().map( ->
        return $(@).width()
      ).get()
    )

  $.fn.maxScrollLeft = ->
    @get(0).scrollWidth - @width()


  methods =
    init: (options) ->
      @each (index, item) ->

        # get references to actual jQuery objects:
        #  1] the $container, i.e. the element on which scrollbars() is called and that will scroll.
        #  2] the $scrollbar, i.e. the long line that will contain the scroller.
        #  3] the $scroller, i.e. that tiny button that the user will drag around to scroll the $container.
        $container = $(item)

        # skip this item if scrolling is not necessary.
        # debug.log(item.scrollWidth, $container.width())
        return true if item.scrollWidth <= $container.width()

        # set the class-name of the scroller element.
        scroller = "scroller"
        # set the class-name of the scrollbar element.
        scrollbar = "scrollbar"

        $container.children("#{scrollbar}").remove()

        $scrollbar = $("<div class=\"#{scrollbar}\"></div>").appendTo($container)
        $scroller = $("<div class=\"#{scroller}\"></div>").appendTo($scrollbar)

        $container.addClass("scroll-container")
        $scrollbar.css("left", $container.scrollLeft())
        $scrollbar.css("width", $container.width())

        # remove the ugly scrollbars, unless we're on a touchy device to avoid the user loosing the possibility
        # to scroll with his fingers.
        $container.css("overflow", "hidden") if false is Modernizr?.touch

        # calculate the constraints for dragging the scroller around, to be passed to the jQuery UI draggable.
        x1 = $container.offset().left
        y1 = $scroller.offset().top
        x2 = x1 + $container.width() - $scroller.width()
        y2 = y1
        containment = [x1, y1, x2, y2]

        scrollLeft = (scrollerLeft, container, scroller) ->

          # the maximum left coordinate of the scroller.
          scrollerMaxLeft = container.width() - scroller.width()

          # the position of the scroller in a scale 0-1.
          scrollerLeftRatio = (scrollerLeft / scrollerMaxLeft)

          # the contained width - or the container scrollwidth.
          # containerScrollWidth =  container.get(0).scrollWidth

          # the container width.
          # containerWidth = container.width()

          # the maximum scrollLeft value.
          containerMaxScrollLeft = container.maxScrollLeft()

          # the scrollleft.
          (scrollerLeftRatio * containerMaxScrollLeft)

        scrollerLeft = (container, scroller) ->

          # the current scroll-left.
          scrollLeft = container.scrollLeft()

          # the maximum scroll-left.
          scrollMaxLeft = container.maxScrollLeft()

          # the scroll-left to scroll-max-left ratio.
          scrollLeftRatio = (scrollLeft / scrollMaxLeft)

          # the maximum left coordinate of the scroller.
          scrollerMaxLeft = container.width() - scroller.width()

          (scrollerMaxLeft * scrollLeftRatio)

        # set-up the draggable behaviour on the $scroller.
        $scroller.draggable
          axis : "x"
          containment : containment
          # handle the start dragging event, by setting the user is dragging.
          start : (event, ui) ->
            $target = $(event.target)
            $target.data( "dragging", true)
          # handle the stop dragging event, by setting the user is NOT dragging.
          stop : (event, ui) ->
            $target = $(event.target)
            $target.data( "dragging", false)

          # the user is dragging, scroll the $container.
          drag : (event, ui) ->
            $scroller = $(event.target)
            $scrollbar = $scroller.parent()
            $container = $scrollbar.parent()

            scrollerLeft = (ui.offset.left - $container.offset().left)

            left = scrollLeft(scrollerLeft, $container, $scroller)

            # realign the scrollbar to the visible left border.
            $scrollbar.css( "left", left ) if "hidden" is $container.css( "overflow" )

            # scroll the container.
            $container.scrollLeft(left)

        $container.mousewheel (event, delta, deltaX, deltaY) ->

          $target = $(event.target)
          $container = if $target.hasClass( "scroll-container" ) then $target else $target.parents( ".scroll-container" )
          $scrollbar = $container.children( ".#{scrollbar}" )
          $scroller = $scrollbar.children( ".#{scroller}" )

          left = $container.scrollLeft() + (deltaX * 10)

          # check if out of boundaries.
          left = 0 if (0 > left)
          left = $container.maxScrollLeft() if $container.maxScrollLeft() < left

          # scroll the container.
          $container.scrollLeft(left)
          $scrollbar.css( "left", left)

          # prevent default handling of this event especially to avoid Chrome shaking the page
          #  and move across history.
          event.preventDefault()


        $container.scroll (event) ->
          $container = $(event.target)
          $scrollbar = $container.children( ".#{scrollbar}" )
          $scroller = $scrollbar.children( ".#{scroller}" )

          # if the user is dragging, we don't move the $scroller.
          return if true is $scroller.data( "dragging" )

          $scrollbar.css('left', $container.scrollLeft() )
          $scroller.css('left', scrollerLeft($container, $scroller) )


  $.fn.scrollbars = ( method ) ->
    # Method calling logic
    return methods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 )) if methods[method]?
    return methods.init.apply( this, arguments ) if "object" is typeof method or not method?
    $.error( "Method #{method }does not exist on scrollbars" )

)(jQuery)
