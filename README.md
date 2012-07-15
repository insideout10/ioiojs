![ioio.js animated logo](https://github.com/insideout10/ioiojs/raw/master/images/ioiojs-animated-logo.gif)


## IOIO.JS Overview

Welcome to **ioio.js**, a semantic UI framework developed in connection with [WordLift](http://wordlift.insideout.io).

The framework consists of several components:

* **ActiveElement**: informs other components when the current active element has changed, useful to determine the active section.
* **ArrowScroller**: takes an scrollable element and draws two arrows on the sides to allow horizontal scrolling similar to the YouTube videos bar.
* **Fillify**: creates a layout composed of stretchable background image, an overlayed container divided into a fixed height header and a variable height content, all controlled via stylesheets.
* **Mapify**: eases the implementation of 3rd geomap libraries (OpenLayers) by providing a simplified façade, and allows easy integration of GeoRSS feeds with custom icons.
* **Menufy**: creates a dynamic menu from a simple list and automatically moves the current selected menu item on the top of the list. Can be combined with ActiveElement to automatically update itself when the user scrolls the browser.
* **PlayerToolbar**: creates a 100% reusable HTML toolbar to manage a video player actions and events created via 3rd party libraries (LongTailVideo).
* **Scrollbars**: creates non-obstrusive scrollbars that work just anywhere (Firefox included) and don't break your existing CSS.
* **SlidingMenu**: updates the 2nd level navigation menu according to the current section, in combination with ActiveElement, optionally using animations to show the menu.

### Requirements

Requires jQuery 1.7.x and jQuery UI. Tested with jQuery 1.7.2 and jQuery UI 1.8.21.

### How to use

Current version is **0.9.2**: to use it, get a copy of the library from here:

* **minified** version: [https://raw.github.com/insideout10/ioiojs/master/lib/ioio-0.9.2.min.js](https://raw.github.com/insideout10/ioiojs/master/lib/ioio-0.9.2.min.js),
* **non-minified** version: [https://raw.github.com/insideout10/ioiojs/master/lib/ioio-0.9.2.js](https://raw.github.com/insideout10/ioiojs/master/lib/ioio-0.9.2.js),
* **non-minified debug** version: [https://raw.github.com/insideout10/ioiojs/master/lib/ioio-0.9.2.debug.js](https://raw.github.com/insideout10/ioiojs/master/lib/ioio-0.9.2.debug.js).

For the **debug version** in order to see the debug messages, the following library is required:

* **ba-debug.js**: [https://raw.github.com/cowboy/javascript-debug/master/ba-debug.min.js](https://raw.github.com/cowboy/javascript-debug/master/ba-debug.min.js).

### How to test

**IOIO.JS** uses **JsTestDriver** for testing purposes. To run the automated test, clone the code then start the JsTestDriver by running from the project root folder:

```sh
java -jar bin/JsTestDriver-1.3.4.b.jar \
 --config jsTestDriver.conf \
 --port 4224 \
 --browser /Applications/Firefox.app,/Applications/Google\ Chrome.app,/Applications/Safari.app
 ```

Be sure to point at your browsers locations with the ```--browser``` switch.

Then run ```cake test``` to run the automated tests.

### How to report issues

Please use GitHub to report issues: [https://github.com/insideout10/ioiojs/issues](https://github.com/insideout10/ioiojs/issues).

## Components

### ActiveElement

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


### ArrowScroller

ArrowScroller makes it easy to create horizontally scrollable elements by adding a left and a right arrow at the side of the contents and acts as a complete replacement for the standard horizontal scrollbars:

```
before:

    ____________ .container ____________
   | ___________ .content _____________ |
   ||                                  ||
   ||                                  ||
   ||__________________________________||
   |____________________________________|
   

after:

  _ ____________ .container ____________ _
 | | ___________ .content _____________ | |
 | ||                                  || |
 |<||                                  ||>|
 | ||__________________________________|| |
 |_|____________________________________|_|
   

```

To set-up ArrowScroller, call the ```arrowscrollers``` method on any container element (```#container``` in our example), by passing the **arrow.width** parameter with the width of the arrows:

```javascript
$('.container').arrowscrollers({
   settings: {
     arrow: {
       width:36
     }
   } 
});
```

#### Stylesheets

The following stylesheets are required:

```css
.arrowscroller {
  &.left, &.right {
    height: height-of-the-container;
  }

  &.left {
    background: url('url-to-the-left-arrow-image') center center no-repeat;
  }

  &.right {
    background: url('url-to-the-right-arrow-image') center center no-repeat;
  }
}
```

The **container** must have the following styles applied:

```css
.container {
  overflow-x: scroll;
  width: width-of-the-container;
}
```

The **content** must have the following styles applied:

```css
.container .content {
    width: width-of-the-content;
    height: height-of-the-content;

    white-space: nowrap;
}
```

Elements inside the **content** must have the following styles applied:

```css
.container .content > * {
      display: inline-block;
}
```


### Fillify

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

### Mapify

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

#### Methods

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

#### Events

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

### Menufy

Menufy creates a dynamic menu out of a list. The selectors.item parameter specifies the selector for the menu items.

```javascript
$('#container').menufy({
  selectors: {
    item: '.item'
  }
});
```

The menu items in the HTML must define the selectors where to scroll the viewport when the user selects a menu item:

* **data-section-selector**: the selector used to get the element that the viewport shall scroll to,
* **data-menu-selector**: the selector used to identify and highlight the menu item when the user scrolls the viewport.

```html
<nav id="container">
  <ul>
    <li class="item hideable section-1"
      data-section-selector=".section.section-1"
      data-menu-selector=".section-1">Section 1</li>
    <li class="item hideable section-2"
      data-section-selector=".section.section-2"
      data-menu-selector=".section-2">Section 2</li>
    <li class="item hideable section-3"
      data-section-selector=".section.section-3"
      data-menu-selector=".section-3">Section 3</li>
  </ul>
</nav>
```

#### Use in combination with ActiveElement

When used in combination with ActiveElement, the current menu item can be highlighted automatically:

```javascript
$('#sections').on('activify.newActiveElement', function(event, active) {

  var menuSelector = $(active).data('menu-selector');

  if (undefined == menuSelector)
    return;

   var activeMenu = $('#container ' + menuSelector);
   
   $('#container').menufy('select', activeMenu);

});
```

### PlayerToolbar

Creates an HTML toolbar for the video player embedded on the Web page that will take care of these functions:

* start/stop,
* progress,
* volume mute and intensity,
* screen size (normal, larger, full-screen),
* quality (SQ, HQ and HD),
* sharing.

These are the parameters:

* **player**: the player instance must be passed as first parameter,
* **screens**: the size (```{width: xxx, height: xxx}```) of the screens:
  * **normal** screen size (default ```normal: { width:640, height:380 }```),
  * **larger** screen size (default ```larger: { width:960, height:470 }```).
* **urls**: an array of URLs for the standard quality, high quality and high definition streams.

```javascript
$("#video-player").playertools(
  jwplayer('video-player'),{
    screens: {
	  normal: {
	    width:640,
        height:380
      },
	  larger: {
        width:960,
        height:470
      }
	},
	urls: {
	'hd':'http://server/points/to/the/file/at/high/definition.mp4',
	'hq':'http://server/points/to/the/file/at/high/quality.mp4',
	'sq':'http://server/points/to/the/file/at/standard/quality.mp4'
  }
});
```

### Scrollbars

Create horizontal scrollbars on any element:

```javascript
  $('#container').scrollbars();
```

The look of the scrollbars is 100% customizable using few lines of stylesheets (Firefox included):

```css
::-webkit-scrollbar {
  width:0;
  height:0;
}

.container {
  position:relative;
  overflow:auto; /* this must be 'hidden' for non-touch based devices; 'auto' for touch-based devices. */
}

.scrollbar {
  position:absolute; /* required */

  left:0px; /* required */
  bottom:0px; /* required */

  background-image: url('img/scrollbar-1px.png');
  background-position: center center;
  background-repeat: repeat-x;
  background-size: 100% 4px;
  height: 14px;
  margin-bottom: 4px;      
}

.scrollbar .scroller {
    position:relative; /* required */

    width:110px;
    height:14px;
    
    background-image: url('img/scroller-regular.png');
}
```

### SlidingMenu

Creates a sliding menu on the ```#container``` element with specified menu items selector ```#container .item``` and optionally set the minimum width of the menu:

```javascript
var slidingMenu = window.slidingMenu('#container', '#container .item', 1000);
```

SlidingMenu will automatically re-center the menu when the viewport is resized.

#### Use in combination with ActiveElement

When used in combination with ActiveElement, the menu bar can be automatically changed according to the active section:

```javascript
$('#sections').on('activify.newActiveElement', function(event, active) {

  var menuIndex = $(active).data('menu-index');
  slidingMenu.slideTo(menuIndex);
  
});
```

## RoadMap

### ActiveElement

#### ActiveElement strategy

Users should be able to choose the strategy used by ActiveElement to determine the active element. In addition to the current (checking for the vertical position of the children elements), a new strategy should be implemented that checks over the visible area of children elements in the viewport. The most visible element should be defined as the active element, and its visibility should be passed as well.

#### Auto-positioning

ActiveElement should smoothly scroll the viewport to show the whole active element if configured to do so.

### Scrollbars

Support vertical scrolling as well.

### jQuery best-practices

Reorganize the code of ActiveElement, PlayerToolbar, Scrollbars and SlidingMenu to follow the jQuery best practices in plug-in development.

### ActiveElement support

Plugins with predefined patterns should automatically bind themselves to ActiveElement if it is loaded and configured.

## License

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
