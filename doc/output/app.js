window.onload = function() {
  var canvas = Raphael("logo", 120, 90);
  var r = canvas.rect(60, 45, 0, 0);
  var c = canvas.circle(60, 45, 0);
  c.attr({fill: "black"});

  r.animate({x: 0.5, y: 0.5, width: 119, height: 89}, 750, "<",  function() {
    c.animate({r: 20}, 1000, "elastic", function() {
      document.getElementById('logo').onclick = function() {
        c.attr({r: 0});
        c.animate({r: 20}, 1500, "elastic");
      };
    });
  });
};
