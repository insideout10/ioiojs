AsyncTestCase("FillifyTest", {
    setUp : function () {
        // set the height of the sections as the height of the viewport.
        assertTrue( 0 < $(window).width() );
        assertTrue( 0 < $(window).height() );

        var element = $('body').append('<div id="sections"></div>');
        assertTrue( element.is(':visible') );

        $.each( [0, 1, 2], function ( index, item ) {

            $('<div class="section"><div class="background"></div><div class="container"><div class="header"></div><div class="content"></div></div></div>')
                .appendTo( element );

        });

        // set html and body margin and padding 0 in order for width to match in future comparisons.
        $( 'html,body,#sections' )
            .css( 'margin', 0 )
            .css( 'padding', 0 );

        assertTrue( 3 === $('.section .container').length );
    },

    tearDown : function () {
        $('body').empty();
    },

    "test create an Fillify instance" : function( queue ) {

        var element = $('.section');

        // set a section that must be 100% of its window.
        $( element )
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
        assertEquals( width, $('.section .background').width() );
        assertEquals( width, $('.section .container').width() );

    },

    "test create an Fillify instance with fixed section width" : function( queue ) {

        var element = $('.section');
        $('.section .container')
            .css( 'margin', 0 );

        var fixedWidth = 100;

        // set a section that must be 100% of its window.
        element
            .css( 'width', fixedWidth + 'px' );
        assertEquals( fixedWidth + 'px', element.css( 'width' ) );

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
        assertEquals( fixedWidth , element.width() );
        assertEquals( fixedWidth , $('.section .background').width() );
        assertEquals( fixedWidth , $('.section .container').width() );

    },

    "test create an Fillify instance with fixed section width and container margin" : function( queue ) {

        var element = $('.section');

        var containerHorizontalMargin = 10;
        $('.section .container')
            .css( 'margin', '0 ' + containerHorizontalMargin + 'px');

        var fixedWidth = 100;

        // set a section that must be 100% of its window.
        element
            .css( 'width', fixedWidth + 'px' );
        assertEquals( fixedWidth + 'px', element.css( 'width' ) );

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
        var expectedContainerHorizontalWidth = fixedWidth - ( containerHorizontalMargin * 2 );
        assertEquals( fixedWidth , element.width() );
        assertEquals( fixedWidth , $('.section .background').width() );
        assertEquals( expectedContainerHorizontalWidth, $('.section .container').width() );

    }


});
