## IOIO.JS

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

ActiveElement listens for *scroll events* in the browser window.

```javascript
$('#sections').activeElement({
  selector: '.section',
  tolerance:20
});
```

#### ArrowScroller

#### Fillify

#### Mapify

#### Menufy

#### PlayerToolbar

#### SlidingMenu