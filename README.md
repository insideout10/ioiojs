# IOIO.JS 

## Overview

Welcome to **ioio.js**, a semantic UI framework developed in connection with [WordLift](http://wordlift.insideout.io).

The framework consists of several components:

* **ActiveElement**: informs other components when the current active element has changed, useful to determine the active section.
* **ArrowScroller**: takes an scrollable element and draws two arrows on the sides to allow horizontal scrolling similar to the YouTube videos bar.
* **Fillify**: creates a layout composed of stretchable background image, an overlayed container divided into a fixed height header and a variable height content, all controlled via stylesheets.
* **Mapify**: eases the implementation of 3rd geomap libraries (OpenLayers) by providing a simplified façade, and allows easy integration of GeoRSS feeds with custom icons.
* **Menufy**: creates a dynamic menu from a simple list and automatically moves the current selected menu item on the top of the list. Can be combined with ActiveElement to automatically update itself when the user scrolls the browser.
* **PlayerToolbar**: creates a 100% reusable HTML toolbar to manage a video player actions and events created via 3rd party libraries (LongTailVideo).
* **SlidingMenu**: updates the 2nd level navigation menu according to the current section, in combination with ActiveElement, optionally using animations to show the menu.

### Requirements

Requires jQuery 1.7.x and jQuery UI. Tested with jQuery 1.7.2 and jQuery UI 1.8.21.


#### ActiveElement

ActiveElement listens for *scroll events* in the browser window and checks for the position of children elements inside the container. The first visible child element is considered the active element:

```
   ____________ #sections ____________
  | ___________ .section ____________ |
  ||                                 ||
  ||     (previous active section)   ||
  ||                                 ||
  ||                                 ||
 ╔═════════════ [viewport] ════════════╗
 ║||_________________________________||║
 ║| ___________ .section ____________ |║
 ║||                                 ||║
 ║||  (this is the active section)   ||║
 ║||                                 ||║
 ║||                                 ||║
 ╚═════════════════════════════════════╝
  ||_________________________________||
  | ___________ .section ____________ |
  ||                                 ||
  ||                                 ||
  ||      (next active section)      ||
  ||                                 ||
  ||                                 ||
  ||_________________________________||
  :                                   :
  :                                   :
  .                                   .

```

In order to set-up ActiveElement, you can configure it on the container element (```#sections``` in our example) with two parameters:

* **selector**: the selector for children elements,
* **tolerance**: an optional tolerance to be applied to the top of the child elements:

```javascript
$('#sections').activeElement({
  selector: '.section',
  tolerance: 20
});
```

One ActiveElement is set-up, you can listen for ```activify.newActiveElement``` events on the container:

```javascript
$('#sections').on('activify.newActiveElement', function(event, active) {
	// your code here...
};
```

The event will pass two parameters:

* **event**: a jQuery event instance,
* **active**: the DOM element of the active section.


#### ArrowScroller

ArrowScroller makes it easy to create horizontally scrollable elements by adding a left and a right arrow at the side of the contents and acts as a complete replacement for the standard horizontal scrollbars:

```
before:

    ____________ #container ____________
   |                                    |
   |                                    |
   |____________________________________|
   

after:

  _ ____________ #container ____________ _
 | |                                    | |
 |<|                                    |>|
 |_|____________________________________|_|
   

```

To set-up ArrowScroller, call the ```arrowscrollers``` method on any container element (```#container``` in our example), by passing the **arrow.width** parameter with the width of the arrows:

```javascript
('#container').arrowscrollers({
   settings: {
     arrow: {
       width:36
     }
   } 
});
```



#### Fillify

Fillify sets the geometry of the different elements of a layout that consists of:

* a **background** which must be stretched according to the size of the viewport, while respecting defined constraints and maintaining the background aspect ratio,
* a **container** which is split in a:
  * a **header** of predefined height,
  * a **content** that must fill the remaining available space.

```
 _______________ .section ________________
|    ___________ .background ___________  |
|   /                                  /| |
|  /____________ .container __________/ | | 
| | ____________ .header ____________ | | |
| ||                                 || | |
| ||                                 || | |
| ||_________________________________|| | |
| | ____________ .content ___________ | | |
| ||                                 || | |
| ||                                 || | |
| ||                                 || | |
| ||                                 || | |
| ||                                 || | |
| ||                                 || | |
| ||_________________________________|| / |
| |___________________________________|/  |
|_________________________________________|
:                                         :
:                                         :
.                                         .

```

To set-up Fillify, call the ```fillify``` method on a container.

```javascript
$(".section").fillify();
```

The ```fillify``` method takes the following parameters to customize the element selectors:
```javascript
$(".section").fillify({
  selectors: {
    background: ".background",
    container: ".container",
    content: ".content",
    header: ".header"
  }
});
```

#### Mapify

Mapify greatly simplifies the task of embedding geomaps on a Web page by hiding the underlying complexity of 3rd party libraries such as OpenLayers. With Mapify you can virtually embed any kind of geomap provider, from Google to Bing, from OpenStreetMap to WMS.

To create a map on a ```#container``` element, call the ```mapify``` method with the following parameters:

* **openLayersURL** (default ```http://openlayers.org/api/OpenLayers.js```): the URL to the OpenLayers JavaScript file,
* **cache** (default ```true```): whether to cache the OpenLayer.js file or not,
* **projection** (default ```EPSG:4326```): the projection to use to translate coordinates,
* **elementId** (default ```map```): the id of the element that will be created to hold the map,
* **zoom** (default ```0```): the starting zoom level for the map,
* **title** (default ```Map```): the map's title,
* **location**: the starting point of the map expressed as latitude and longitude (i.e. ```{latitude:41.91613, longitude:12.503052}```),
* **layerSwitcher** (default ```true```): whether to display the layer switcher on the map.

```javascript
$('#container').mapify({
  elementId: 'map',
  openLayersURL: 'http://dev.openlayers.org/releases/OpenLayers-2.11/OpenLayers.js',
  cache: true,
  zoom: 5,
  title: 'World Map',
  location: {latitude:41.91613, longitude:12.503052}
});
```

##### Methods

A mapified element supports different methods:

* **geoRSS**: to load a remote GeoRSS file and show its points as markers on the map, it supports the following parameters:
  * **url** (*required*, default *none*): the URL to the GeoRSS file,
  * **title** (default ```GeoRSS```): the layer's title,
  * **className** (default *none*): the name of the element and attribute that define the stylesheets class name that will be used for later use (in Popup Controls),
  * **radius** (default ```{default: 15, select: 25}```): the size of the marker when unselected and selected,
  * **externalGraphic**: the configuration for the markers graphic, can contain placeholders that will be filled with data loaded from the GeoRSS file, ex: ```{url: 'wp-content/uploads/img/marker.png', width: 9, height: 17, select: { width: 14, height: 26 } }```.

```javascript
$('#container').mapify( 'geoRSS', {
  url: 'wp-admin/admin-ajax.php?action=weeotv.geo_rss&categories=' + value,
  title: key,
  className: {
    tag: 'category',
    attribute: 'term'
  },
  externalGraphic: {
    url: 'wp-content/uploads/img/marker_' + value + '.png',
    width: 9,
    height: 17,
    select: {
   	    width: 14,
  	    height: 26
   	}
  }
});
```

* **popupControl**: to configure a customized popup control that will appear when the user clicks on a marker on the map; it accepts the following parameters:
  * **layer** (*required*, default *none*): the layer to which to bind the popup control,
  * **size** (default ```{width: 230, height: 250}```): the size of the popup,
  * **content** (*required*, default *none*): the HTML contents of the popup control, placeholders can be used here.

```javascript
$('#container').mapify('popupControl', {
  layer: layer,
  size: {
    width: 210,
    height: 250
  },
  content: '<div class="{className}"><a href="{link}">{title}<img src="{thumbnail}" /></a></div>'
});
```

##### Events

Mapify supports several events that allow to load the different layers (maps, GeoRSS feeds and popup controls) in connection one to the other:

* **mapify.create**: a new map has been created,

Load a GeoRSS feed once the map has been created:

```javascript
$('#container').on('mapify.create', function (event) {

  var that = this;

  $.each( geoRSS, function (key, value) {

    $(that).mapify( 'geoRSS', {
      url: 'wp-admin/admin-ajax.php?action=weeotv.geo_rss&categories=' + value,
      title: key,
      className: {
        tag: 'category',
        attribute: 'term'
      },
      externalGraphic: {
        url: 'wp-content/uploads/img/marker_' + value + '.png',
        width: 9,
        height: 17,
        select: {
          width: 14,
          height: 26
        }
      }
    });

  });

});
```

* **mapify.loadStart**: a layer is loading data,

Update a status message while the layers are loading:
```javascript
$('#container').on('mapify.loadStart', function (event) {

  loads = $('#map-status').data('loads') || 0;
  
  $('#map-status .message').html('Loading (' + ++loads + ')...');
  $('#map-status').show();
  $('#map-status').data({
    loads: loads
  });
  
});
```

* **mapify.loadEnd**: a layer finished loading data,

Update and finally hide the status message when the loading is complete:

```javascript
$('#container').on('mapify.loadEnd', function (event) {

  loads = $('#map-status').data('loads') || 1;

  $('#map-status .message').html('Loading (' + --loads + ')...');
  
  if (0 === loads)
    $('#map-status').hide();
    
  $('#map-status').data({
    loads: loads
  });
});
```

* **mapify.georss**: a GeoRSS layer has been loaded, the event will deliver the related layer as a parameter to the event.

Load the popup control once the GeoRSS layer has been loaded:

```javascript
$('#container').on('mapify.georss', function (event, layer) {
						
  $(this).mapify('popupControl', {
    layer: layer,
    size: {
      width: 210,
      height: 250
    },
    content: '<div class="{className}"><a href="{link}">{title}<img src="{thumbnail}" /></a></div>'
  });

});
```

#### Menufy

#### PlayerToolbar

#### SlidingMenu

### RoadMap

#### ActiveElement

##### ActiveElement strategy

Users should be able to choose the strategy used by ActiveElement to determine the active element. In addition to the current (checking for the vertical position of the children elements), a new strategy should be implemented that checks over the visible area of children elements in the viewport. The most visible element should be defined as the active element, and its visibility should be passed as well.

##### Auto-positioning

ActiveElement should smoothly scroll the viewport to show the whole active element if configured to do so.

#### ArrowScroller

##### jQuery best-practices

Reorganize the code to follow the jQuery best practices in plug-in development.

### License

Copyright (c) 2012 InSideOut10 srl [www.insideout.io](http://www.insideout.io)

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.