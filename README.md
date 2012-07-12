IOIO.JS
=======

![InsideOut10 logo](https://github.com/insideout10/ioiojs/raw/images/logo.png)

Welcome to **ioio.js**, a semantic UI framework developed in connection with [WordLift](http://wordlift.insideout.io).

The framework consists of several components:

* **ActiveElement**: informs other components when the current active element has changed, useful to determine the active section.
* **ArrowScroller**: takes an scrollable element and draws two arrows on the sides to allow horizontal scrolling similar to the YouTube videos bar.
* **Fillify**: creates a layout composed of stretchable background image, an overlayed container divided into a fixed height header and a variable height content, all controlled via stylesheets.
* **Mapify**: eases the implementation of 3rd geomap libraries (OpenLayers) by providing a simplified façade, and allows easy integration of GeoRSS feeds with custom icons.
* **Menufy**: creates a dynamic menu from a simple list and automatically moves the current selected menu item on the top of the list. Can be combined with ActiveElement to automatically update itself when the user scrolls the browser.
* **PlayerToolbar**: creates a 100% reusable HTML toolbar to manage a video player actions and events created via 3rd party libraries (LongTailVideo).
* **SlidingMenu**: updates the 2nd level navigation menu according to the current section, in combination with ActiveElement, optionally using animations to show the menu.

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

#### Fillify

#### Mapify

#### Menufy

#### PlayerToolbar

#### SlidingMenu

### RoadMap

#### ActiveElement

##### ActiveElement strategy

Users should be able to choose the strategy used by ActiveElement to determine the active element. In addition to the current (checking for the vertical position of the children elements), a new strategy should be implemented that checks over the visible area of children elements in the viewport. The most visible element should be defined as the active element, and its visibility should be passed as well.

##### Auto-positioning

ActiveElement should smoothly scroll the viewport to show the whole active element if configured to do so.