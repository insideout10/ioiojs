AsyncTestCase("SlidingMenuTest", {

    setUp : function() {
        $( 'body' ).append('<div id="container"><div class="item"></div><div class="item"></div><div class="item"></div></div>');

        assertTrue( $('#container').is(':visible') );
    },

    "test create an SlidingMenu instance" : function( queue ) {

        // set the height of the sections as the height of the viewport.
        assertTrue( 0 < $(window).width() );
        assertTrue( 0 < $(window).height() );

        assertNotNull( $('#container') );

        assertNotNull(
            window.slidingMenu('#container', '#container .item', 1000)
        );

    }

});
