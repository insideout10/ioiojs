AsyncTestCase("MenufyTest", {

    setUp : function() {
        $( 'body' ).append('<nav id="container"> \
            <ul> \
                <li class="item hideable section-1" \
                data-section-selector=".section.section-1" \
                data-menu-selector=".section-1">Section 1</li> \
                <li class="item hideable section-2" \
                data-section-selector=".section.section-2" \
                data-menu-selector=".section-2">Section 2</li> \
                <li class="item hideable section-3" \
                data-section-selector=".section.section-3" \
                data-menu-selector=".section-3">Section 3</li> \
            </ul> \
        </nav>');

        assertTrue( $('#container').is(':visible') );
    },

    "test create an Menufy instance" : function( queue ) {

        // set the height of the sections as the height of the viewport.
        assertTrue( 0 < $(window).width() );
        assertTrue( 0 < $(window).height() );

        assertNotNull( $('#container') );

        assertNotNull(
            $('#container').menufy({
                selectors: {
                    item: '.item'
                }
            })
        );

    }

});
