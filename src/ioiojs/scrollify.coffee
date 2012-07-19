$ = jQuery

$ ->

  # create a fake debug object if it doesn't exists.
  debug = window.debug ?= { log: -> }

  methods =

    init: (options) ->

      @each (index, item) ->

        container = $( item )

        # remove any existing scrollbars.
        container.remove( ".scrollbar.vertical" )

        #
        scrollHeight = container.get(0).scrollHeight

        # check if the area needs vertical scrolling
        return if scrollHeight <= container.height()

        container.css( "overflow-y", "hidden" ) unless true is Modernizr?.cssscrollbar

        # add the scrollbar container.
        html = "<div class=\"scrollbar vertical\" style=\"position: absolute; top: 0px; right: 0px; height: #{container.get(0).scrollHeight}px;\">
                  <div class=\"scroller\"></div>
                </div>
               "
        $( html )
          .appendTo( container )

        scroller = container.find( ".scrollbar.vertical .scroller" )

        scroller
          .draggable
            axis: "y"
            containment: "parent"
            drag: (event, ui) ->
              container.scrollTop ( container.get(0).scrollHeight - container.height() ) * ( ui.position.top / ( container.get(0).scrollHeight - scroller.height() ) )
            start: ->
              container.data
                dragging: true
            stop: ->
              container.data
                dragging: false

        container.scroll (event) ->
          return if container.data( "dragging" )
          container.scrollify( "alignScroller" )

        # resize the scrollbar if the container or the content are resized.
        container
          .resize -> container.scrollify( "resize" )
          .children()
            .resize -> container.scrollify( "resize" )

    alignScroller: ->

      @each (index, item) ->
        container = $( item )
        scroller = container.find( ".scrollbar.vertical .scroller" )
        scroller.css( "top" , ( container.get(0).scrollHeight - scroller.height() ) * ( container.scrollTop() / ( container.get(0).scrollHeight - container.height() ) ) )

    resize: ->

      @each (index, item) ->
        container = $( item )
        container.children( ".scrollbar" )
          .css( "height", container.get(0).scrollHeight )
        container.scrollify( "alignScroller" )

  $.fn.scrollify = ( method ) ->
    # Method calling logic
    return methods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 )) if methods[method]?
    return methods.init.apply( this, arguments ) if "object" is typeof method or not method?
    $.error( "Method #{method} does not exist on scrollbars" )
