AsyncTestCase("FillifyTest", {

    "test create an Fillify instance" : function( queue ) {

        // set the height of the sections as the height of the viewport.
        assertTrue( 0 < $(window).width() );
        assertTrue( 0 < $(window).height() );

        var element = $('body').append('<div id="sections"></div>');
        assertTrue( element.is(':visible') );

        $.each( [0, 1, 2], function ( index, item ) {

            $('<div class="section"></div><div class="background"></div><div class="container"><div class="header"></div><div class="content"></div></div></div>')
                .appendTo( element );

        });

        // set html and body margin and padding 0 in order for width to match in future comparisons.
        $( 'html,body' )
            .css( 'margin', 0 )
            .css( 'padding', 0 );

        // set a section that must be 100% of its window.
        $('.section')
            .css( 'width', '100%' );

        // check that the fillify is created.
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

        // check that the correct widths are set.
        var width = $(window).width();
        assertEquals( width, $('.section').width() );
        assertEquals( width, $('.background').width() );
    }

});
