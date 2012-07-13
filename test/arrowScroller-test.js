AsyncTestCase("ArrowScrollerTest", {

    "test create an ArrowScroller instance" : function( queue ) {

        // set the height of the sections as the height of the viewport.
        assertTrue( 0 < $(window).width() );
        assertTrue( 0 < $(window).height() );

        var element = $('body').append('<div id="container"></div>');
        assertTrue( element.is(':visible') );

        assertNotNull(
            element.arrowscrollers({
                settings: {
                    arrow: {
                        width:36
                    }
                }
            })
        );


    }

});
