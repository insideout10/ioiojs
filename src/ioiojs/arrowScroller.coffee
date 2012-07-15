# ioio.js {{ VERSION }} - Semantic Video UI
# (c) 2012 InsideOut10, Enel SpA, IKS Consortium
# ioiojs may be freely distributed under the MIT license.
# For all details and documentation:
# http://wordlift.insideout.io/
(($) ->
  
  methods =
    init: (options) ->

      settings = $.extend
        classNames:
          arrowscroller: 'arrowscroller'
          arrow: 'arrow'
          left: 'left'
          right: 'right'
        arrow:
          width:36
        marginTop: true
      ,options

      # create a fake debug if the debug does not exist.
      if false is (debug = window.debug)?
        debug = {log: -> }

      debug.log "InSideOut10 Arrow Scrollers", @, settings

      return @each ->

        element = $(@)

        doScrollLeft = =>
          # scroll by page:
          #  1] get the 'current page'.
          page = element.scrollLeft() / element.width()
          #  2, 3] add one page and calculate scrollLeft.
          scrollLeft = element.width() * ++page
          #  4] check that new scrollLeft is valid.
          return if scrollLeft > element.get(0).scrollWidth
          #  5] scroll.
          element.animate({scrollLeft: scrollLeft})

        doScrollRight = =>
          # scroll by page:
          #  1] get the 'current page'.
          page = element.scrollLeft() / element.width()
          #  2, 3] add one page and calculate scrollLeft.
          scrollLeft = element.width() * --page
          #  4] set the scrollLeft to zero if the scrollLeft is minus 0.
          scrollLeft = 0 if 0 > scrollLeft
          #  5] scroll.
          element.animate({scrollLeft: scrollLeft})


        element
          .css("overflow", "hidden")

        height = element.height()
        width = element.width()

        margin = settings.arrow.width / 2

        arrowLeft = $("<div class=\"#{settings.classNames.arrowscroller} #{settings.classNames.arrow} #{settings.classNames.left}\"></div>")
          .css('width',settings.arrow.width)
          .css('height',height)
          .css('cursor','pointer')
          .css('margin-left', -margin)
          .click(doScrollRight)

        arrowRight = $("<div class=\"#{settings.classNames.arrowscroller} #{settings.classNames.arrow} #{settings.classNames.right}\"></div>")
          .css('width',settings.arrow.width)
          .css('height',height)
          .css('margin-left',width + margin)
          .css('cursor','pointer')
          .css('margin-top',-height)
          .click(doScrollLeft)

        element
          .css('margin-left',margin)
          .before(arrowLeft)
          .after(arrowRight)

        if (true is settings.marginTop)
          element.css('margin-top',-height)


  $.fn.arrowscrollers = ( method ) ->

    # Method calling logic
    return methods[ method ].apply( @, Array.prototype.slice.call( arguments, 1 )) if methods[method]?

    return methods.init.apply( this, arguments ) if "object" is typeof method or method?

    $.error( "Method #{method} does not exist on arrowscrollers." )



)(jQuery)
