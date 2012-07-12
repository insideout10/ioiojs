# ioio.js {{ VERSION }} - Semantic Video UI
# (c) 2012 InsideOut10, Enel SpA, IKS Consortium
# ioiojs may be freely distributed under the MIT license.
# For all details and documentation:
# http://wordlift.insideout.io/
(($) ->

	# create a fake debug object, if the debugger is not instantiated.
	if not (debug = window.debug)?
		debug = {log: -> }

	methods =
		init: (options) ->

			settings = $.extend
				selector: ".content"
				tolerance: 0
		    ,options

			debug.log("initializing", settings, options)

			return @each( ->
				debug.log("initializing on", @)
				element = $(@)
				element.data( settings )
				$(window).on("scroll", null, element, methods.handleScroll);
			)
		align: (element) ->

		handleScroll: (event) ->
			# get the current element.
			element = event.data
			methods.findActiveElement(event)

			# clearTimeout(element.handleScrollTimeout)
			# element.handleScrollTimeout = setTimeout( ( -> methods.findActiveElement(event) ), 100)

		findActiveElement: (event) ->			
			# get the current element.
			element = event.data

			# get the settings.
			settings = element.data()

			# get the children filtered by the selector.
			children = element.find(settings.selector).filter(":visible")

			# check for the active element.
			newActiveElement = null
			children.each (index, item) ->
				# karma = $(item).visibleKarma()
				# if (0.4 < karma.viewport.visible.ratio)
				# 	newActiveElement = item
				# 	return false

				top = $(item).viewportOffset().top
				if top > -settings.tolerance
					newActiveElement = item
					return false

			# triggert the event
			element.trigger("activify.newActiveElement", [newActiveElement]) if newActiveElement isnt settings.activeElement

			# set the new active element.
			settings.activeElement = newActiveElement

			clearTimeout(settings.scrollTimeout)
			settings.scrollTimeout = setTimeout( ( ->
				$("html, body").animate({"scrollTop": $(newActiveElement).offset().top}, "slow") )
			, 1000 )

			element.data(settings)


	$.fn.viewportOffset = ->
		offset = @offset()
		top = offset.top - $(window).scrollTop()
		left = offset.left - $(window).scrollLeft()
		
		return {
			top: top
			left: left
		}

	$.fn.visibleKarma = ->
		# we have different coordinate systems:
		#  1] document
		#  2] viewport

		# we will build an object with the following:
		karma =
			document: # everything related to the document.
				viewport: # coordinates of the viewport.
					top: null
					left: null
				element:
					top: null
					left: null
			viewport:
				width: null
				height: null
				area: null
				element:
					top: null
					left: null
				visible: # visible coordinates of the element.
					top: null
					right: null
					bottom: null
					left: null
					area: null
					ratio: null
			element:
				width: null
				height: null


		# calculate the window visible surface.
		windowSurface = $(window).height() * $(window).width()

		# get the window top/left values.
		karma.document.viewport.top = $(window).scrollTop()
		karma.document.viewport.left = $(window).scrollLeft()

		karma.viewport.width = $(window).width()
		karma.viewport.height = $(window).height()
		karma.viewport.area = (karma.viewport.width * karma.viewport.height)

		# get the element top/left values relative to the viewport.
		karma.document.element = @offset()
		karma.viewport.element.top = karma.document.element.top - karma.document.viewport.top
		karma.viewport.element.left = karma.document.element.left - karma.document.viewport.left

		karma.element.width = @width()
		karma.element.height = @height()

		# get the upper/left corner coordinates relative to the element.
		x1 = if karma.viewport.element.left > 0 then karma.viewport.element.left else 0
		y1 = if karma.viewport.element.top > 0 then karma.viewport.element.top else 0
		x2 = karma.document.element.left + karma.element.width - Math.abs(karma.viewport.element.top)
		x2 = 0 if 0 > x2
		x2 = karma.viewport.width if karma.viewport.width < x2
		y2 = karma.document.element.top + karma.element.height - Math.abs(karma.viewport.element.left)
		y2 = 0 if 0 > y2
		y2 = karma.viewport.height if karma.viewport.height < y2

		karma.viewport.visible = {x1: x1, x2: x2, y1: y1, y2: y2}
		karma.viewport.visible.area = (x2 * y2)

		karma.viewport.visible.ratio = (karma.viewport.visible.area / karma.viewport.area)

		@css("opacity", karma.viewport.visible.ratio)

		karma

	$.fn.activeElement = (method) ->
		debug.log("calling method", method)

		return methods[ method ].apply( @, arguments) if methods[method]?
		return methods.init.apply( @, arguments) if 'object' is typeof method or not method?

		$.error( "Method #{method} does not exist on jQuery.activeElement." )

)(jQuery)