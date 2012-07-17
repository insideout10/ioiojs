# ioio.js {{ VERSION }} - Semantic Video UI
# (c) 2012 InsideOut10, Enel SpA, IKS Consortium
# ioiojs may be freely distributed under the MIT license.
# For all details and documentation:
# http://wordlift.insideout.io/
(($) ->

  # create a fake debug object.
  if false is (debug = window.debug)?
    debug = {log: ->}

  methods =
    init: (options) ->

      settings = $.extend
          screens:
            normal:
              width:640
              height:480
            larger:
              width:960
              height:720
          urls: null
          player: null
          webtrends: { host: null, path: null, title: null }
        , options

      player = settings.player

      debug.log( "PlayerTools initializing.", player, settings )

      @each (index, item) ->
        # ...
        element = $(item)

        # save the settings.
        element.data
          settings: settings

        toolbar = $("<div class=\"insideout-playertools toolbar\"></div>")
          .width(player.getWidth())

        playButton = $("<div class=\"button play\"></div>")
          .appendTo(toolbar)
          .click ->
            # pause the play if the player is playing.
            return player.pause(true) if "BUFFERING" is player.getState() or "PLAYING" is player.getState()
            # play if the player is paused/stopped.
            player.play(true)

        timeSlider = $("<div class=\"slider time\"></div>")
          .appendTo(toolbar)

        progressBar = $("<div class=\"progress-container\"><div class=\"progress\"></div></div>")
          .appendTo(timeSlider)
          .click (event) ->
            # get the max width.
            maxWidth = progressBar.width()
            # get the clicked X.
            x = event.pageX - progressBar.offset().left
            # get the duration.
            duration = player.getDuration()
            # get the clicked position.
            position = x * (duration / maxWidth)
            # set the position.
            player.seek(position)

        # add a separator.
        $("<div class=\"separator\"></div>")
          .appendTo(toolbar)

        volumeButton = $("<div class=\"button volume\"></div>")
          .appendTo(toolbar)
          .click ->
            player.setMute()

        volumeButton.addClass("mute") if true is player.getMute()

        volumeSlider = $("<div class=\"slider volume\"><div class=\"container\"><div id=\"volume-slider\"></div></div></div>")
          .appendTo(toolbar)

        volumeSlider.find("#volume-slider").slider
          min:0
          max:100
          range:"min"
          value: player.getVolume()
          slide: (event, ui) ->
            # debug.log(event)
            # debug.log(ui)
            player.setVolume( ui.value )

        # add a separator.
        $("<div class=\"separator\"></div>")
          .appendTo(toolbar)

        normalScreenButton = $("<div class=\"button normal-screen selected\"></div>")
          .appendTo(toolbar)
          .click ->
            element.trigger("playertools.willresize", "normal")

            player.resize( settings.screens.normal.width, settings.screens.normal.height)
            normalScreenButton.addClass("selected")
            largerScreenButton.removeClass("selected")
            fullScreenButton.removeClass("selected")

            element.trigger("playertools.resize", "normal")

        $(document.documentElement).keyup (event) ->
          normalScreenButton.trigger("click") if 27 is event.keyCode

        largerScreenButton = $("<div class=\"button larger-screen\"></div>")
          .appendTo(toolbar)
          .click ->
            element.trigger("playertools.willresize", "large")

            player.resize( settings.screens.larger.width, settings.screens.larger.height)
            largerScreenButton.addClass("selected")
            normalScreenButton.removeClass("selected")
            fullScreenButton.removeClass("selected")

            element.trigger("playertools.resize", "large")

        fullScreenButton = $("<div class=\"button full-screen\"></div>")
          .appendTo(toolbar)
          .click ->
            element.trigger("playertools.willresize", "full")

            width = $(window).width()
            height = $(window).height() - toolbar.height() - element.position().top
            player.resize( width, height )
            fullScreenButton.addClass("selected")
            largerScreenButton.removeClass("selected")
            normalScreenButton.removeClass("selected")

            element.trigger("playertools.resize", "full")

        qualitySelector = $("<div id=\"video-quality\"><ul><li class=\"item selected sq\" data-quality=\"sq\"></li><li class=\"item hq\" data-quality=\"hq\"></li><li class=\"item hd\" data-quality=\"hd\"></li></ul></div>")
          .appendTo(toolbar)

        qualitySelector
          .mouseenter (event) ->
            width = qualitySelector.width()
            qualitySelector.find("li").show()
            add = qualitySelector.width() - width
            qualitySelector.css("margin-left", -add)

          .mouseleave (event) ->
            qualitySelector.find("li").not(".selected").hide()
            qualitySelector.css("margin-left", 0)

          .find(".item")
          .click (event) ->
            target = $(event.target)

            target
              .addClass("selected")
              .siblings()
              .removeClass("selected")

            qualitySelector.trigger("mouseleave")

            # get the urls.
            urls = settings.urls

            # get the selector.
            selector = target.data("quality")

            # get the url.
            url = urls[ selector ]

            # get the current position.
            position = player.getPosition()

            # play the url.
            player.load
              file:url
              start:position
          .not(".selected")
            .hide()

        # add a separator.
        $("<div class=\"separator\"></div>")
          .appendTo(toolbar)

        shareButton = $("<div class=\"button share\"></div>")
          .appendTo(toolbar)
          .click ->
            playertools.share()

        switchToPause =  ->
          playButton
            .removeClass("play")
            .addClass("pause")

        switchToPlay = ->
          playButton
            .removeClass("pause")
            .addClass("play")

        updateProgress = (event) =>
          return if @updateProgressTimeout?
          @updateProgressTimeout = setTimeout =>
              # get the max position
              maxWidth = timeSlider.children(".progress-container").width()
              timeSlider.find(".progress").width( event.position * (maxWidth / event.duration) )
              @updateProgressTimeout = null

              # save the current position.
              element.data
                position: event.position

            , 500

        updateMute = (event) ->
          if true is event.mute
            volumeButton.addClass("mute")
          else
            volumeButton.removeClass("mute")

        sizeTimeSlider = ->
          sliderWidth = playerWidth = player.getWidth()
          toolbar.width(playerWidth)

          toolbar.children().not(".slider.time").each (index, item) ->
            sliderWidth -= $(item).outerWidth(true)

          timeSlider
            .width( sliderWidth )

          margin = parseInt( progressBar.css('margin-left'), 10) + parseInt( progressBar.css('margin-right') )
          progressBar.width(timeSlider.width() - margin)
          updateProgress
            position:player.getPosition()
            duration:player.getDuration()

        element
          .after(toolbar)

        sizeTimeSlider()

        player
          .onPlay( -> switchToPause() )
          .onPause( -> switchToPlay() )
          .onBuffer( -> switchToPause() )
          .onIdle( -> switchToPlay() )
          .onResize( -> sizeTimeSlider() )
          .onTime( -> updateProgress(arguments...) )
          .onMute( -> updateMute(arguments...) )

        $(window).unload ->
          element.playertools( "log" )

    log: ->

      @each (index, item) ->
        element = $( item )
        position = element.data( "position" )
        settings = element.data( "settings" )
        console.log( "will log [position :: #{position}][WebTrends :: #{Webtrends?}]", settings.webtrends)

        Webtrends?.multiTrack
          args:
            "DCS.dcssip": settings.webtrends.host
            "DCS.dcsuri": settings.webtrends.path
            "WT.clip_n": settings.webtrends.title
            "WT.dl": "7"
            "WT.clip_ev": "#{position}SEC"

    close: ->

      @playertools( "log" )

  $.fn.playertools = ( method ) ->
    # Method calling logic
    return methods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 )) if methods[method]?
    return methods.init.apply( this, arguments ) if "object" is typeof method or not method?
    $.error( "Method #{method} does not exist on playertools" )

)(jQuery)
