.pragma library

/**
 * From processing.js: https://raw.githubusercontent.com/processing-js/processing-js/v1.4.8/processing.js
 *
 * Re-map a number from one range to another. In the example above, the number
 * '25' is converted from a value in the range 0..100 into a value that
 * ranges from the left edge (0) to the right edge (width) of the screen.
 * Numbers outside the range are not clamped to 0 and 1, because out-of-range
 * values are often intentional and useful.
 *
 * @param {Number} value        The incoming value to be converted
 * @param {Number} istart       Lower bound of the value's current range
 * @param {Number} istop        Upper bound of the value's current range
 * @param {Number} ostart       Lower bound of the value's target range
 * @param {Number} ostop        Upper bound of the value's target range
 *
 * @returns {Number}
 */
function map(value, istart, istop, ostart, ostop) {
  return ostart + (ostop - ostart) * ((value - istart) / (istop - istart))
}

/**
 * Return a value which is always between `min` and `max`
 *
 * @param {Number} value     The current value
 * @param {Number} min       The minimum value
 * @param {Number} max       The maximum value
 *
 * @returns {Number}
 */
function clamp(value, min, max) {
  if (value < min) return min
  if (value > max) return max
  return value
}

// calculates the distance from the middle of one rect to middle of other rect
function rectDistance(rect1, rect2) {
    return pointDistance(Qt.point(rect1.x + rect1.width / 2, rect1.y + rect1.height / 2),
                         Qt.point(rect2.x + rect2.width / 2, rect2.y + rect2.height / 2))
}

// calculates the distance between two points
function pointDistance(point1, point2) {
    return Math.sqrt(Math.pow(point1.x - point2.x, 2) +
                     Math.pow(point1.y - point2.y, 2)
                    )
}

// from http://stackoverflow.com/questions/14616829/java-method-to-find-the-rectangle-that-is-the-intersection-of-two-rectangles-usi
function intersectionRect(r1, r2) {
    var xmin = Math.max(r1.x, r2.x);
    var xmax1 = r1.x + r1.width;
    var xmax2 = r2.x + r2.width;
    var xmax = Math.min(xmax1, xmax2);
    var out = {x:0, y:0, width:0, height:0}
    if (xmax > xmin) {
        var ymin = Math.max(r1.y, r2.y);
        var ymax1 = r1.y + r1.height;
        var ymax2 = r2.y + r2.height;
        var ymax = Math.min(ymax1, ymax2);
        if (ymax > ymin) {
            out.x = xmin;
            out.y = ymin;
            out.width = xmax - xmin;
            out.height = ymax - ymin;
        }
    }
    return out;
}

function easeOutCubic(t) { return (--t)*t*t+1 }

function linearAnimation(startProgress, endProgress, startValue, endValue, progress) {
    // progress : progressDiff = value : valueDiff => value = progress * valueDiff / progressDiff
    return (progress - startProgress) * (endValue - startValue) / (endProgress - startProgress) + startValue;
}
