AsyncTestCase("ActiveElementTest", {

    "test create an ActiveElement instance" : function( queue ) {

        // set the height of the sections as the height of the viewport.
        assertTrue( 0 < $(window).width() );
        assertTrue( 0 < $(window).height() );

        var element = $('body').append('<div id="sections"></div>');
        assertTrue( element.is(':visible') );

        // append the section elements.
        var width = $(window).width();
        var height = $(window).height();
        $.each( [0, 1, 2], function ( index, item ) {
            $('<div class="section" data-index="' + index + '" style="display:block;width:' + width + 'px;height:' + height + 'px;">&nbsp;</div>').appendTo( element );
        });

        // check over the created sections.
        var sections = element.children('.section');
        assertTrue( 3 === sections.length );
        assertTrue( 0 < sections.width() );
        assertTrue( 0 < sections.height() );

        // assign the top position.
        $.each( sections, function( index, item ) {
            $(item).offset({ top: $(window).height() * index, left: 0 });
        });

        // check for top positions.
        assertTrue( 0 === sections.eq(0).offset().top );
        assertTrue( 0 < sections.eq(1).offset().top );
        assertTrue( sections.eq(1).offset().top < sections.eq(2).offset().top );

        // create the ActiveElement.
        assertNotNull(
            element.activeElement({
                selector: '.section',
                tolerance: 20
            })
        );

        var currentActive = null;

        // hook to the newActiveElement event and scroll down the window.
        queue.call('hook to the event', function() {

            // hook to the event and set the current active element.
            element.on('activify.newActiveElement', function(event, active) {
                currentActive = active;
            });

            // scroll to the 2nd section.
            $('html,body').scrollTop( $('.section').eq(1).offset().top );
        });

        // set the currentActive.
        queue.call('check that active has changed 1', function() {
            console.log('check that active has changed 1');

            assertNotNull( currentActive );
            assertEquals( 1, $(currentActive).data('index') );

            // scroll to the next section.
            $('html,body').scrollTop( $('.section').eq(2).offset().top );
        });

        queue.call('check that active has changed 2', function() {
            console.log('check that active has changed 2');

            assertNotNull( currentActive );
            assertEquals( 2, $(currentActive).data('index') );

        });

    }

});
