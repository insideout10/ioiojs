AsyncTestCase("FillifyTest", {

    "test create an Fillify instance" : function( queue ) {

        // set the height of the sections as the height of the viewport.
        assertTrue( 0 < $(window).width() );
        assertTrue( 0 < $(window).height() );

        var element = $('body').append('<div id="sections"></div>');
        assertTrue( element.is(':visible') );

        $.each( [0, 1, 2], function ( index, item ) {

            $('<div class="background"></div><div class="container"><div class="header"></div><div class="content"></div></div>')
                .appendTo( element );

        });

        assertNotNull(
            element.fillify({
                selectors: {
                    background: ".background",
                    container: ".container",
                    content: ".content",
                    header: ".header"
                }
            })
        );


    }

});
