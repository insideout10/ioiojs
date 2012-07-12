# ioio.js {{ VERSION }} - Semantic Video UI
# (c) 2012 InsideOut10, Enel SpA, IKS Consortium
# ioiojs may be freely distributed under the MIT license.
# For all details and documentation:
# http://wordlift.insideout.io/
(($) ->

  if not (debug = window.debug)?
    debug = {log: -> }

  methods =
    init: (options) ->

      # set-up the settings.
      settings = $.extend
        selectors:
          item: ".item"
      ,options

      debug.log("menufying.")

      @each (index, item) ->

        # set an explicit reference to the container (i.e. the menu-container.)
        container = $(item)

        # save the settings in the container.
        container.data({settings: settings})

        # make the first item visible.
        container.find(".hideable:first").show()

        container.click( (event) ->
            methods.openClose(container)
          )

        # get a reference to the menu items.
        items = container.find(settings.selectors.item)

        # assign an index to each menu item.
        items.each (index, item) ->
          element = $(item)
          
          # set the menu index to keep the sorting of the menu, when selecting an item.
          element.data({"menu-index": index})

          # get the section selector and the menu selector.
          sectionSelector = element.data("section-selector")
          menuSelector = element.data("menu-selector")

          # set the menu selector on the target section.
          $(sectionSelector).data({"menu-selector": menuSelector}) if menuSelector?

        # bind the click event to the menu.
        items
          .css("cursor", "pointer")
          .click (event)->
            debug.log("menu-item clicked.")
            # set a reference to the event source.
            target = $(event.target)

            # open/close the menu.
            methods.openClose(target)

            # get the associated section.
            sectionSelector = target.data("section-selector")
            debug.log("element's section-selector is [#{sectionSelector}].")

            # do nothing if there's no selector (but pass the event).
            return true if not sectionSelector?

            # get the section element's top, and left
            # return false if 0 is $(sectionSelector).length
            top = $(sectionSelector).offset().top

            # scroll to that element.
            debug.log("scrolling to [#{top}].")
            $("html, body").animate
              scrollTop: top
            ,"slow"

    select: (item) ->
      debug.log("selecting", item.data("menu-selector"))

      # get the parent
      parent = item.parent()

      # do nothing if the selected item is already the first in the list.
      return if item.get(0) is parent.children().first().get(0)

      # get the current active index.
      activeItem = parent.children().first()
      activeIndex = activeItem.data("menu-index")
      debug.log("activeItem", activeItem, "activeIndex", activeIndex)

      # move the clicked item to the first position
      parent.prepend( item.detach() )
      
      # move back the former active item.
      parent.children().each (index, item) ->
        if (activeIndex - 1) is $(item).data("menu-index")
          activeItem.detach()
            .insertAfter(item)

      # switch the visibility of the items.
      activeItem.hide()
      item.show()

    openClose: (item) ->
      target = item
      if "open" is target.data("state")
        target.find(".hideable").css("display", "none")
        # target.find(".hideable:gt(0)").hide()
        first = target.find(".hideable:first")
        target.find(".hideable:first").css("display", "block") if first?
        target.data({state:"close"})
      else
        target.find(".hideable").css("display", "block")
        target.data({state:"open"})



  $.fn.menufy = (method) ->
    return methods[method].apply( @, Array.prototype.slice.call( arguments, 1 )) if ( methods[method] )

    debug.log("initialize.")
    return methods.init.apply( @, arguments ) if 'object' is typeof method or not method?

    $.error( 'Method ' +  method + ' does not exist.' );




)(jQuery)