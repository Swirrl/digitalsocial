(function($, window) {

  var TreeVis = {};

  TreeVis.dataLoaded = function(data) {
    $('#tree-vis').addClass('loaded');
  };

  TreeVis.init = function() {
    console.log("Initialised Tree View");
  };

  TreeVis.init();
})($, window);
