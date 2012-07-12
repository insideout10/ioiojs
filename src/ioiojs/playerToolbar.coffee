# ioio.js {{ VERSION }} - Semantic Video UI
# (c) 2012 InsideOut10, Enel SpA, IKS Consortium
# ioiojs may be freely distributed under the MIT license.
# For all details and documentation:
# http://wordlift.insideout.io/
(($) ->

  $.fn.playertools = (player, options) ->
    
    # create a fake debug object.
    if false is (debug = window.debug)?
      debug = {log: ->}
    
    debug.log "loading playertools."

    settings = $.extend
      screens:
        normal:
          width:640
          height:480
        larger:
          width:960
          height:720
      urls: null
    ,options

    # create an instance with the methods.
    playertools =
      isFlash: (element) ->
        return "OBJECT" is element.get(0).tagName
      playPause: (player) ->
        debug.log(player.getWidth() + "/" + player.getHeight())
        # pause the play if the player is playing.
        return player.pause(true) if "BUFFERING" is player.getState() or "PLAYING" is player.getState()
        
        # play if the player is paused/stopped.
        player.play(true)
      share: ->
        debug.log("share")


    @each ->
      element = $(@)
            
      toolbar = $("<div class=\"insideout-playertools toolbar\"></div>")
        .width(player.getWidth())

      playButton = $("<div class=\"button play\"></div>")
        .appendTo(toolbar)
        .click( -> playertools.playPause(player) )
        
      timeSlider = $("<div class=\"slider time\"></div>")
        .appendTo(toolbar)
        
      progressBar = $("<div class=\"progress-container\"><div class=\"progress\"></div></div>")
        .appendTo(timeSlider)
        .click( (event) ->
          # get the max width.
          maxWidth = progressBar.width()
          # get the clicked X.
          x = event.pageX - progressBar.offset().left
          debug.log x
          # get the duration.
          duration = player.getDuration()
          # get the clicked position.
          position = x * (duration / maxWidth)
          # set the position.
          player.seek(position) 
        )
      
      # add a separator.
      $("<div class=\"separator\"></div>")
        .appendTo(toolbar)

      volumeButton = $("<div class=\"button volume\"></div>")
        .appendTo(toolbar)
        .click( ->
          player.setMute()
        )
        
      volumeButton.addClass("mute") if true is player.getMute()

      volumeSlider = $("<div class=\"slider volume\"><div class=\"container\"><div id=\"volume-slider\"></div></div></div>")
        .appendTo(toolbar)

      volumeSlider.find("#volume-slider").slider(
          min:0
          max:100
          range:"min"
          value: player.getVolume()
          slide: (event, ui) ->
            # debug.log(event)
            # debug.log(ui)
            player.setVolume(ui.value)
        )
      
      # add a separator.
      $("<div class=\"separator\"></div>")
        .appendTo(toolbar)
      
      normalScreenButton = $("<div class=\"button normal-screen selected\"></div>")
        .appendTo(toolbar)
        .click( ->
          element.trigger("playertools.willresize", "normal")

          player.resize( settings.screens.normal.width, settings.screens.normal.height)
          normalScreenButton.addClass("selected")
          largerScreenButton.removeClass("selected")
          fullScreenButton.removeClass("selected")

          element.trigger("playertools.resize", "normal")
        )

      $(document.documentElement).keyup (event) ->
        normalScreenButton.trigger("click") if 27 is event.keyCode
      
      largerScreenButton = $("<div class=\"button larger-screen\"></div>")
        .appendTo(toolbar)
        .click( ->
          element.trigger("playertools.willresize", "large")

          player.resize( settings.screens.larger.width, settings.screens.larger.height)
          largerScreenButton.addClass("selected")
          normalScreenButton.removeClass("selected")
          fullScreenButton.removeClass("selected")

          element.trigger("playertools.resize", "large")
        )
      
      fullScreenButton = $("<div class=\"button full-screen\"></div>")
        .appendTo(toolbar)
        .click( ->
          element.trigger("playertools.willresize", "full")

          width = $(window).width()
          height = $(window).height() - toolbar.height() - element.position().top
          player.resize( width, height )
          # if playertools.isFlash(element)
          #   ...
          # else
          #   player.setFullscreen(true)

          fullScreenButton.addClass("selected")
          largerScreenButton.removeClass("selected")
          normalScreenButton.removeClass("selected")

          element.trigger("playertools.resize", "full")
        )

      qualitySelector = $("<div id=\"video-quality\"><ul><li class=\"item selected sq\" data-quality=\"sq\"></li><li class=\"item hq\" data-quality=\"hq\"></li><li class=\"item hd\" data-quality=\"hd\"></li></ul></div>")
        .appendTo(toolbar)

      qualitySelector
        .mouseenter( (event) ->
          width = qualitySelector.width()
          qualitySelector.find("li").show()
          add = qualitySelector.width() - width
          qualitySelector.css("margin-left", -add)
        )
        .mouseleave( (event) ->
          qualitySelector.find("li").not(".selected").hide()
          qualitySelector.css("margin-left", 0)
        )
        .find(".item")
          .click( (event) ->
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
          )
          .not(".selected")
            .hide()

      # add a separator.
      $("<div class=\"separator\"></div>")
        .appendTo(toolbar)

      shareButton = $("<div class=\"button share\"></div>")
        .appendTo(toolbar)
        .click( ->
          playertools.share()
        )

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
        @updateProgressTimeout = setTimeout( =>
            # get the max position
            maxWidth = timeSlider.children(".progress-container").width()
            timeSlider.find(".progress").width( event.position * (maxWidth / event.duration) )
            @updateProgressTimeout = null
        ,500)
          
      updateMute = (event) ->
        if true is event.mute
          volumeButton.addClass("mute")
        else
          volumeButton.removeClass("mute")

      sizeTimeSlider = ->
        playerWidth = player.getWidth()
        toolbar.width(playerWidth)

        sliderWith = playerWidth
        toolbar.children().not(".slider.time").each (index, item) ->
          sliderWith -= $(item).outerWidth(true)

        timeSlider
          .width( sliderWith )
            # playerWidth \
            #  - playButton.outerWidth(true) \
            #  - volumeButton.outerWidth(true) \
            #  - volumeSlider.outerWidth(true) \
            #  # - separator.outerWidth(true) \
            #  - normalScreenButton.outerWidth(true) \
            #  - largerScreenButton.outerWidth(true) \
            #  - fullScreenButton.outerWidth(true) \
            #  - qualitySelector.outerWidth(true) \
            #  - shareButton.outerWidth(true))
        margin = parseInt( progressBar.css('margin-left'), 10) + parseInt( progressBar.css('margin-right') )
        progressBar.width(timeSlider.width() - margin)
        updateProgress({position:player.getPosition(), duration:player.getDuration()})
 
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

)(jQuery)
