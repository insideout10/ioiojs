# ioio.js {{ VERSION }} - Semantic Video UI
# (c) 2012 InsideOut10, Enel SpA, IKS Consortium
# ioiojs may be freely distributed under the MIT license.
# For all details and documentation:
# http://wordlift.insideout.io/
(($) ->
  
  # check for the debug library and fake if it does not exist.
  if not (debug = window.debug)?
    debug = { log: -> }

  methods =
    init: (options) ->

      settings = $.extend
        openLayersURL: "http://openlayers.org/api/OpenLayers.js"
        projection: "EPSG:4326"
        container: @
        elementId: "map"
        location: null
        zoom: 0
        namespace: "mapify"
        layerSwitcher: true
        cache: true
        title: "Map"
      ,options

      debug.log("loading OpenLayers from [#{settings.openLayersURL}].")

      $.ajax settings.openLayersURL,
        cache: settings.cache
        context: @
        dataType: "script"
        complete: (jqXHR, textStatus) ->
          debug.log("OpenLayers load completed with #{textStatus}")
        error: (jqXHR, textStatus, errorThrown) ->
          debug.log("OpenLayers load error with #{textStatus}")
        success: (data, textStatus, jqXHR) ->
          methods.create.apply(@, [settings])

      return @

    create: (options) ->
      debug.log("create with options: ", options, @)

      return @each (index, item) ->

        container = $(item)
        elementId = options.elementId
        location = options.location
        zoom = options.zoom
        projection = options.projection
        title = options.title

        debug.log("adding [#{elementId}] to the document.")

        # create an element that will hold the map.
        $("<div id=\"#{elementId}\" style=\"width:100%;height:100%;\"></div>").appendTo(container)


        debug.log("creating the map's instance.")
        map = new OpenLayers.Map(elementId, {maxResolution: "auto"})

        debug.log("adding the basic layer.")
        osm = new OpenLayers.Layer.OSM( title )
        map.addLayer(osm)

        # debug.log("creating the map layer.")

        # wms = new OpenLayers.Layer.WMS( "OpenLayers WMS", "http://vmap0.tiles.osgeo.org/wms/vmap0", {layers: 'basic'} )
        # map.addLayer(wms)

        # set the map center.    
        if location? and location.latitude? and location.longitude?
          debug.log("setting the location.")
  
          map.setCenter(
            new OpenLayers.LonLat(location.longitude, location.latitude).transform(
                new OpenLayers.Projection(projection),
                map.getProjectionObject()
            )
          )


        debug.log("zooming.")

        # zoom the map.
        if 0 is zoom
          map.zoomToMaxExtent()
        else
          map.zoomTo(zoom)

        map.addControl(new OpenLayers.Control.LayerSwitcher()) if true is options.layerSwitcher

        # save a reference to the map.
        container.data({map: map, options: options})

        # fire the create event on the jQuery elements array.
        $(item).trigger( "#{options.namespace}.create" )


    geoRSS: (options) ->

      settings = $.extend
        thumbnail: {tag: "thumbnail", attribute: "url"}
        className: null
        radius: {default: 15, select: 25}
        url: null
        title: "GeoRSS"
        id: "id"
        externalGraphic: {url: null, width: null, height: null, select: { width: null, height: null }}
      ,options

      debug.log("creating GeoRSS layer.", options, settings)

      $.error( "url has not been set.") if not settings.url?
      $.error( "thumbnail tag has not been set.") if not settings.thumbnail?.tag?
      $.error( "thumbnail attribute has not been set.") if not settings.thumbnail?.attribute?
      $.error( "id attribute has not been set.") if not settings.id?
      $.error( "title has not been set.") if not settings.title?
      $.error( "radius default has not been set.") if not settings.radius?.default?
      $.error( "radius select has not been set.") if not settings.radius?.select?

      # save the layers in order to trigger the event later on.
      layers = []

      return @each (index, item) ->

        # get the reference to the map.
        map = $(item).data("map")

        $.error( "this element is not mapified." ) if not map?

        debug.log("creating a new GeoRSS layer with title [#{settings.title}] and url [#{settings.url}].", settings)

        debug.log("creating a new style with [externalGraphic :: #{settings.externalGraphic}].")

        # create a property style that reads the externalGraphic url from
        # the thumbail attribute of the rss item
        style = new OpenLayers.Style
          externalGraphic: settings.externalGraphic.url
          graphicWidth: settings.externalGraphic.width
          graphicHeight: settings.externalGraphic.height
          graphicXOffset: -settings.externalGraphic.width/2
          graphicYOffset: -settings.externalGraphic.height/2
          # externalGraphic: '${thumbnail}'
          # pointRadius: settings.radius.default

        selectStyle = new OpenLayers.Style
          graphicWidth: settings.externalGraphic.select.width
          graphicHeight: settings.externalGraphic.select.height
          graphicXOffset: -settings.externalGraphic.select.width/2
          graphicYOffset: -settings.externalGraphic.select.height/2

        layer = new OpenLayers.Layer.GML( settings.title, settings.url, {
          format: OpenLayers.Format.GeoRSS
          formatOptions:
            createFeatureFromItem: (item) ->
              feature = OpenLayers.Format.GeoRSS.prototype.createFeatureFromItem.apply(@, arguments)

              # standard GeoRSS tag.
              feature.attributes.link = escape( @getElementsByTagNameNS(item, "*", "link")[0].getAttribute("href") )

              feature.attributes.id = @getElementsByTagNameNS(item, "*", settings.id)[0].textContent
              feature.attributes.thumbnail = @getElementsByTagNameNS(item, "*", settings.thumbnail.tag)[0].getAttribute(settings.thumbnail.attribute)

              feature.attributes.summary = if 0 < @getElementsByTagNameNS(item, "*", "summary").length then @getElementsByTagNameNS(item, "*", "summary")[0].textContent

              # add the class name if we have configuration.
              if settings.className?.tag? and settings.className?.attribute?
                feature.attributes.className = @getElementsByTagNameNS(item, "*", settings.className.tag)[0].getAttribute(settings.className.attribute)

              feature
          styleMap: new OpenLayers.StyleMap
            default: style
            select: selectStyle
        })

        options = $(item).data("options")

        layer.events.on(
            "loadstart": (event) ->
              $(item).trigger("#{options.namespace}.loadStart")
            "loadend": (event) ->
              $(item).trigger("#{options.namespace}.loadEnd")
            scope: @
          )


        # layer.events.register("addlayer", map, ->
        #     $(item).trigger("#{options.namespace}.addLayer")
        #   );
        # layer.events.register("changelayer", map, ->
        #     $(item).trigger("#{options.namespace}.changeLayer")
        #   );

        map.addLayer(layer)

        # get the options and trigger the event.
        $(item).trigger( "#{options.namespace}.georss", [layer] )

    popupControl: (options) ->

      settings = $.extend
        layer: null
        size: {width: 230, height: 250}
        content: null
      ,options

      $.error( "need to specify a layer." ) if not settings.layer?

      debug.log("creating a popupControl.", settings);

      return @each (index, item) ->

        # get the reference to the map.
        map = $(item).data("map")

        $.error( "this element is not mapified." ) if not map?

        # remove an existing popupControl, as we cannot have 2+.
        # @get('map').removeControl @get('popupControl'), false if @get('popupControl')?

        # control that will show a popup when clicking on a thumbnail.
        popupControl = new OpenLayers.Control.SelectFeature settings.layer,
          onSelect: (feature) =>
              position = feature.geometry
              # map.removePopup(popup) if popup?

              debug.log( "Popup will interpolate with the following attributes:", feature )

              popup = new OpenLayers.Popup(
                "popup",
                new OpenLayers.LonLat( position.x, position.y),
                new OpenLayers.Size( settings.size.width, settings.size.height ),
                methods.interpolate( settings.content, feature.attributes),
                true
              )
              # set the class name for the popup.
              popup.closeDiv.className = feature.attributes.className

              map.addPopup( popup, true)
              feature.popup = popup

          onUnselect: (feature) =>
            if feature.popup?
              map.removePopup( feature.popup )
              feature.popup.destroy()
              feature.popup = null

        map.addControl(popupControl)
        popupControl.activate()

        options = $(item).data("options")
        $(item).trigger( "#{options.namespace}.popupControl" )

    interpolate: (value, variables) ->
      value.replace(/{([^{}]*)}/g,
        (a, b) ->
          r = variables[b]
          if "string" is typeof r or "number"  is typeof r then r else a
      )

  $.fn.mapify = (method) ->

    # Method calling logic
    return methods[ method ].apply( @, Array.prototype.slice.call( arguments, 1 ) ) if methods[method]?
      
    return methods.init.apply( @, arguments ) if typeof method is 'object' or not method?

    $.error( "Method #{method} does not exist on jQuery.mapify" )

#   return null



#   settings =
#     openLayersUrl: "http://openlayers.org/api/OpenLayers.js"
#     projection: "EPSG:4326"

#   # create the map when the OpenLayers library is available.
#   mapCallback = (zoom = 0, startLocation = null, elementId = "map", container = this, projection = settings.projection) ->
#     debug.log "Paving the map...", zoom, startLocation, elementId, container.get(0).id, projection

#     # create an element that will hold the map.
#     $("<div id=\"#{elementId}\" style=\"width:100%;height:100%;\"></div>").appendTo(container)

#     map = new OpenLayers.Map(elementId)
#     osm = new OpenLayers.Layer.OSM("OpenStreetMap")
#     map.addLayer(osm)

#     # set the map center.    
#     if startLocation? and startLocation.latitude? and startLocation.longitude?
#       debug.log "Centering map.", startLocation 
#       map.setCenter(
#         new OpenLayers.LonLat(startLocation.longitude, startLocation.latitude).transform(
#             new OpenLayers.Projection(projection),
#             map.getProjectionObject()
#         )
#       )

#     # zoom the map.
#     if 0 is zoom
#       map.zoomToMaxExtent()
#     else
#       map.zoomTo(zoom)

#     return null
      
#     # create a property style that reads the externalGraphic url from
#     # the thumbail attribute of the rss item
#     style = new OpenLayers.Style
#       externalGraphic: '${thumbnail}'
#       pointRadius: 15

#     # Create a GML layer with GeoRSS format and a style map.
#     category = container.data("category")
#     markerLayer = new OpenLayers.Layer.GML('GeoRSS', "#{Settings.urls.GEO_RSS}&categories=#{category}",
#       format: OpenLayers.Format.GeoRSS
#       formatOptions:
#         # adds the thumbnail attribute to the feature
#         createFeatureFromItem: (item) ->
#           feature = OpenLayers.Format.GeoRSS.prototype.createFeatureFromItem.apply(@, arguments)
#           feature.attributes.id = @getElementsByTagNameNS(item, "*", "id")[0].textContent
#           feature.attributes.thumbnail = @getElementsByTagNameNS(item, "*", "thumbnail")[0].getAttribute("url")
#           # slug = @getElementsByTagNameNS(item, "*", "category")[0].getAttribute("term")
#           # category = window.App.get('categoriesController').findBySlug slug
#           # feature.attributes.className = category.get('parent').get('slug')
#           # feature.attributes.category = category.get('path') 
#           feature
#       # Giving the style map keys for "default" and "select"
#       # rendering intent, to make the image larger when selected
#       styleMap: new OpenLayers.StyleMap
#         default: style
#         select: new OpenLayers.Style({pointRadius: 25})
#     )
    
#     map.addLayer markerLayer

    


#   $.fn.mapify = (zoom = 0, startLocation = null, elementId = "map", container = this, openLayersUrl = settings.openLayersUrl, projection = settings.projection) ->
    
#     # prepare the callback.
#     callback = ->
#       mapCallback zoom, startLocation, elementId, container, projection

#     # check if the OpenLayers library is loaded, otherwise load it.
#     if OpenLayers?
#       callback()

#     else
#       debug.log "Loading the OpenLayers library from #{openLayersUrl}, hold on please..."

#       # load the OpenLayers library.
#       $.getScript openLayersUrl, ->
#         debug.log "OpenLayers has been loaded!"
#         callback()
  


#   # layer = ->
#     # options =
#       # url: null
#       # id: ->
#         # @getElementsByTagNameNS(item, "*", "id")[0].textContent
#       # className: ->
# #         
# #       
# #     
#     # # create a property style that reads the externalGraphic url from
#     # # the thumbail attribute of the rss item
#     # style = new OpenLayers.Style
#       # externalGraphic: '${thumbnail}'
#       # pointRadius: 15
# # 
#     # # Create a GML layer with GeoRSS format and a style map.
#     # markerLayer = new OpenLayers.Layer.GML('GeoRSS', @get('markersUrl'),
#       # format: OpenLayers.Format.GeoRSS
#       # formatOptions:
#         # # adds the thumbnail attribute to the feature
#         # createFeatureFromItem: (item) ->
#           # feature = OpenLayers.Format.GeoRSS.prototype.createFeatureFromItem.apply(@, arguments)
#           # slug = @getElementsByTagNameNS(item, "*", "category")[0].getAttribute("term")
#           # category = window.App.get('categoriesController').findBySlug slug
#           # feature.attributes.id = @getElementsByTagNameNS(item, "*", "id")[0].textContent
#           # feature.attributes.className = category.get('parent').get('slug')
#           # feature.attributes.category = category.get('path') 
#           # feature.attributes.thumbnail = @getElementsByTagNameNS(item, "*", "thumbnail")[0].getAttribute("url")
#           # feature
#       # # Giving the style map keys for "default" and "select"
#       # # rendering intent, to make the image larger when selected
#       # styleMap: new OpenLayers.StyleMap
#         # default: style
#         # select: new OpenLayers.Style({pointRadius: 25})
#     # )

)(jQuery)