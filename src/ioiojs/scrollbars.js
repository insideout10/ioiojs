// ioio.js {{ VERSION }} - Semantic Video UI
// (c) 2012 InsideOut10, Enel SpA, IKS Consortium
// ioiojs may be freely distributed under the MIT license.
// For all details and documentation:
// http://wordlift.insideout.io/
(function($) {
	$.fn.contentWidth = function() {
		return Math.max.apply(Math, this.children().map(function() {
			return $(this).width();
		}).get());
	}

	$.fn.maxScrollLeft = function() {
		return (this.get(0).scrollWidth - this.width());
	}

	$.fn.scrollbars = function() {

		this.each(function(index, item) {

			// get references to actual jQuery objects:
			//  1] the $container, i.e. the element on which scrollbars() is called and that will scroll.
			//  2] the $scrollbar, i.e. the long line that will contain the scroller.
			//  3] the $scroller, i.e. that tiny button that the user will drag around to scroll the $container.
			var $container = $(item);

			// skip this item if scrolling is not necessary.
			// debug.log(item.scrollWidth, $container.width())
			if (item.scrollWidth <= $container.width())
				return true;

			// set the class-name of the scroller element.
			var scroller = 'scroller';
			// set the class-name of the scrollbar element.
			var scrollbar = 'scrollbar';

			$container.children('.' + scrollbar).remove();

			var $scrollbar = $('<div class="' + scrollbar + '"></div>').appendTo($container);
			var $scroller = $('<div class="' + scroller + '"></div>').appendTo($scrollbar);

			$container.addClass('scroll-container');
			$scrollbar.css('left', $container.scrollLeft());
			$scrollbar.css('width', $container.width());

			// remove the ugly scrollbars, unless we're on a touchy device to avoid the user loosing the possibility
			// to scroll with his fingers.
			if (Modernizr && false === Modernizr.touch)
				$container.css('overflow', 'hidden');

			// calculate the constraints for dragging the scroller around, to be passed to the jQuery UI draggable.
			var x1 = $container.offset().left;
			var y1 = $scroller.offset().top;
			var x2 = x1 + $container.width() - $scroller.width();
			var y2 = y1;
			var containment = [x1, y1, x2, y2];

			var scrollLeft = function(scrollerLeft, container, scroller) {

				// the maximum left coordinate of the scroller.
				var scrollerMaxLeft = container.width() - scroller.width();

				// the position of the scroller in a scale 0-1.
				var scrollerLeftRatio = (scrollerLeft / scrollerMaxLeft);

				// the contained width - or the container scrollwidth.
				// var containerScrollWidth =  container.get(0).scrollWidth;

				// the container width.
				// var containerWidth = container.width();

				// the maximum scrollLeft value.
				var containerMaxScrollLeft = container.maxScrollLeft();
				// containerScrollWidth - containerWidth;

				// the scrollleft.
				var scrollLeft = (scrollerLeftRatio * containerMaxScrollLeft);

				return scrollLeft;

			};

			var scrollerLeft = function(container, scroller) {

				// the current scroll-left.
				var scrollLeft = container.scrollLeft();

				// the maximum scroll-left.
				var scrollMaxLeft = container.maxScrollLeft();

				// the scroll-left to scroll-max-left ratio.
				var scrollLeftRatio = (scrollLeft / scrollMaxLeft);

				// the maximum left coordinate of the scroller.
				var scrollerMaxLeft = container.width() - scroller.width();

				var scrollerLeft = (scrollerMaxLeft * scrollLeftRatio);

				return scrollerLeft;
			};

			// set-up the draggable behaviour on the $scroller.
			$scroller.draggable({
				axis : 'x',
				containment : containment,
				// handle the start dragging event, by setting the user is dragging.
				start : function(event, ui) {
					var $target = $(event.target);
					$target.data('dragging', true);
				},
				// handle the stop dragging event, by setting the user is NOT dragging.
				stop : function(event, ui) {
					var $target = $(event.target);
					$target.data('dragging', false);
				},
				// the user is dragging, scroll the $container.
				drag : function(event, ui) {
					var $scroller = $(event.target);
					var $scrollbar = $scroller.parent();
					var $container = $scrollbar.parent();

					var scrollerLeft = (ui.offset.left - $container.offset().left);

					var left = scrollLeft(scrollerLeft, $container, $scroller);

					// realign the scrollbar to the visible left border.
					if ('hidden' === $container.css('overflow'))
						$scrollbar.css('left', left);

					// scroll the container.
					$container.scrollLeft(left);
				}
			});

			$container.mousewheel(function(event, delta, deltaX, deltaY) {

				var $target = $(event.target);
				var $container = ($target.hasClass('scroll-container') ? $target : $target.parents('.scroll-container') );
				var $scrollbar = $container.children('.' + scrollbar);
				var $scroller = $scrollbar.children('.' + scroller);

				var left = $container.scrollLeft() + (deltaX * 10);

				// check if out of boundaries.
				if (0 > left)
					left = 0;

				if ($container.maxScrollLeft() < left)
					left = $container.maxScrollLeft();

				// scroll the container.
				$container.scrollLeft(left);
				$scrollbar.css('left', left);

				// prevent default handling of this event especially to avoid Chrome shaking the page
				//  and move across history.
				event.preventDefault();
			});

			$container.scroll(function(event) {
				$container = $(event.target);
				$scrollbar = $container.children('.' + scrollbar);
				$scroller = $scrollbar.children('.' + scroller);

				// if the user is dragging, we don't move the $scroller.
				if (true === $scroller.data('dragging'))
					return;

				$scrollbar.css('left', $container.scrollLeft());
				$scroller.css('left', scrollerLeft($container, $scroller));

			});

		});

		return this;
	};
})(jQuery);