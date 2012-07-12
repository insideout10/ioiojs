# ioio.js {{ VERSION }} - Semantic Video UI
# (c) 2012 InsideOut10, Enel SpA, IKS Consortium
# ioiojs may be freely distributed under the MIT license.
# For all details and documentation:
# http://wordlift.insideout.io/
(($) ->
  window.slidingMenu = (containerSelector, menuSelector, minimumWidth = null) ->
    
    # check for the debug library and fake if it does not exist.
    if not (debug = window.debug)?
      debug = { log: -> }
    
    slidingMenu =
      # hold a reference to the container of the menus.
      containerSelector: containerSelector,
      
      # hold a reference to the class identifying the menu items.
      menuSelector: menuSelector,
      
      # center the menus.
      center: ->
        debug.log('center')
        
        # get the window width.
        windowWidth = @getWidth()
        
        # calculate the margin to center each menu.
        $(@menuSelector).each (index, item) =>
          # get the menu width.
          itemWidth = $(item).width()
          
          # get the margin.
          margin = Math.floor((windowWidth - itemWidth) / 2)
          leftDelta = (windowWidth % 2)
          
          # assign the margin.
          $(item).animate
              'margin-left': margin + leftDelta
              'margin-right': margin

        # recenter the container.
        debug.log "now centering the menu at index [currentIndex:#{@currentIndex}][windowWidth:#{windowWidth}]"
        @slideTo()
      ,
      
      # move to the menu marked by the index.
      slideTo: (index = @currentIndex) ->
        return if 0 > index > (@menuCount() - 1)

        # set the margin left to align the menu.
        $(@containerSelector)
          .css("margin-left", - @getWidth() * index)

        # set the current index.
        @currentIndex = index;

        # $(@containerSelector).animate(
        #   'margin-left':
        #     - @getWidth() * index
        # ,
        #   complete: =>
        #     # update the current menu index.
        #     @currentIndex = index;
        # )                   
      ,
      
      # move to the next menu, if any.
      slideNext: ->
        # stop if we are at the last item.
        return if (@menuCount() - 1) <= @currentIndex
        @slideTo(++@currentIndex)
      ,
      
      # move to the previous menum, if any.
      slidePrevious: ->
        # stop if we're already at the first item.
        return if 0 >= @currentIndex
        
        # animate to the previous item.
        @slideTo(--@currentIndex)
      ,
      # keep track of the current menu index.
      currentIndex: 0,
      
      menuCount: ->
        return $(@menuSelector).length
      ,
      getWidth: ->
        # get the window width.
        windowWidth = $(window).width()
        
        # return the minimumWidth if the windowWidth is too small.
        if null isnt minimumWidth and windowWidth < minimumWidth
          minimumWidth 
        else
          windowWidth

    
    slidingMenu.center()
  
    $(window).resize ->
      clearTimeout(@resizeTimeout)
      @resizeTimeout = setTimeout (-> slidingMenu.center()), 100
      
    return slidingMenu

)(jQuery)