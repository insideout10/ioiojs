AsyncTestCase("MapifyTest", {

    "test create an Mapify instance" : function( queue ) {

        // set the height of the sections as the height of the viewport.
        assertTrue( 0 < $(window).width() );
        assertTrue( 0 < $(window).height() );

        var element = $('body').append('<div id="container"></div>');
        assertTrue( element.is(':visible') );

        assertNotNull(
            element.mapify({
                elementId: 'map',
                openLayersURL: 'http://dev.openlayers.org/releases/OpenLayers-2.11/OpenLayers.js',
                cache: true,
                zoom: 5,
                title: 'World Map',
                location: {latitude:41.91613, longitude:12.503052}
            })
        );

    }

});
