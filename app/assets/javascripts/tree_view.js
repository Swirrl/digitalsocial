(function($, d3, window) {

  var TreeVis = function(id) {

    ////////////////////////////////////////////////////////////////////////////
    // PRIVATE HELPERS
    ////////////////////////////////////////////////////////////////////////////

    var getWidth = function() {
      return mainElement.node().offsetWidth - mainPadding;
    };

    var calcSize = function() {
      var totalWidth = mainElement.node().offsetWidth;
      return "rotate(180 " + (totalWidth / 2) + " " + (height / 2) + ") translate(" + (mainPadding / 2) + "," + (mainPadding / 2) + ")";
    };

    var createSvg = function() {
      var svg = mainElement.append("svg");

      var g = svg.attr("height", height)
            .append("g")
            .attr("transform", calcSize);

      return svg;
    };

    var windowResized = function() {
      currentSize = mainElement.node().offsetWidth;
      if(lastSize != currentSize) { // if the size of our box has changed then render/rescale
        lastSize = currentSize;
        clearPopup();
        svg.remove();
        svg = createSvg();
        render();
      }
    };

    // Deduplicate by key
    var uniqueBy = function(findKey, ary) {
      var seen = {};
      return ary.filter(function(elem) {
        var k = findKey(elem);
        return (seen[k] === 1) ? 0 : seen[k] = 1;
      });
    };

    var uniqueById = function(ary) {
      return uniqueBy(function(node) {
        return node.node_data.uri_slug;
      }, ary);
    };

    var isOrganisation = function(node) {
      return node.node_data.resource_type == 'organisation';
    };

    var circleRadius = function(node) {
      var num = node.node_data.more_details['No of Activities'];

      if(num <= 2) {
        return smallCircle;
      } else if(num <= 7) {
        return mediumCircle;
      } // else

      return largeCircle;
    };

    var nodeWidth = function(node) {
      if(isOrganisation(node)) {
        return circleRadius(node) * 2;
      } else {
        return activityWidth;
      }
    };

    var scaledNodeWidth = function(node) {
      return (node.scaleFactor || 1.0) * nodeWidth(node);
    };

    // calculate a row width at a given scale factor
    var totalRowWidth = function(row) {
      var sum = 0;
      for(var i=0; i < row.length; i++) {
        sum += nodeWidth(row[i]);
      }
      return sum;
    };

    var calcScaleForRow = function(row, scale) {
      var rowWidth = totalRowWidth(row, scale);

      var space = 2,
          spaceBetweenSize = ((row.length - 1) * space);

      while(rowWidth >= (getWidth() - spaceBetweenSize)) {
        scale -= scale * 0.25;
        rowWidth = totalRowWidth(row) * scale;
      }

      return scale;
    };

    var nodeHeight = function(node) {
      if(isOrganisation(node)) {
        return (circleRadius(node) * 2);
      } else {
        return activityHeight;
      }
    };

    var isActivity = function(node) {
      return node.node_data.resource_type == 'project';
    };

    var colourCircles = function(node) {
      var d = node.node_data;
      if(isOrganisation(node)) {
        return colourOrg(d.organisation_type);
      }
      return null;
    };

    var colourLines = function(line) {
      var node = line.source.node_data.resource_type == 'project' ? line.source.node_data : line.target.node_data;
      return colourActivity(node.activity_type.uri);
    };

    var byOrganisationType = function(a, b) {
      var aType = a.node_data.organisation_type_label || 'Other',
          bType = b.node_data.organisation_type_label || 'Other';

      return d3.ascending(aType, bType);
    };

    var isAtDepth = function(n) { return function(node) { return node.depth == n; }; };

    var dataLoaded = function(data) {
      $('#tree-vis').addClass('loaded');
    };

    var getResourceId = function() {
      return $(document.URL.split('/')).last()[0];
    };

    var setLoaded = function() {
      mainElement.classed('loaded', true);
    };

    /* The d3 default is to render uneven trees with leaves at the
     * greatest depth.  i.e. a depth 1 node will render at depth 2 if
     * it has no children.  Here we override this default to render
     * nodes at their true depth.
     */
    var normaliseDepth = function(n) {
      n.y = n.depth * ((height - 50) / 2);
    };

    var positionRow = function(row) {
      if(row.length == 1) {
        var node = row[0];
        node.x = (getWidth() / 2) ;
        return;
      }

      var scaler = d3.scale.linear()
            .rangeRound([0, getWidth()])
            .domain([0, row.length - 1]);


      row.forEach(function(node, i) {
        node.x = scaler(i);
        node.scaleFactor = calcScaleForRow(row, 1.0);
      });
    };

    var positionBottomRow = function(bottomRow) {
        var rootNode = bottomRow[0];
        rootNode.x = (getWidth() / 2) ;
    };

    var findOrCreatePopup = function() {
      var popup = mainElement.select('.popup');
      if(popup.empty()) {
        popup = mainElement
          .append('div')
          .classed('popup', true);

        var innerPopup = popup.append('div').classed('inner-popup', true);
        innerPopup.append('h3').classed({'type': true});
        innerPopup.append('h1').append('a').classed('name', true);
      }
      return popup;
    };

    var clearPopup = function(ev) {
      if(popup) {
        popup.remove();
      }
    };

    var toTitleCase = function(inputStr) {
      var i, str, lowers, uppers;
      str = inputStr.replace(/([^\W_]+[^\s-]*) */g, function(txt) {
        return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
      });

      // Certain minor words should be left lowercase unless
      // they are the first or last words in the string
      lowers = ['A', 'An', 'The', 'And', 'But', 'Or', 'For', 'Nor', 'As', 'At',
                'By', 'For', 'From', 'In', 'Into', 'Near', 'Of', 'On', 'Onto', 'To', 'With'];
      for (i = 0; i < lowers.length; i++)
        str = str.replace(new RegExp('\\s' + lowers[i] + '\\s', 'g'),
                          function(txt) {
                            return txt.toLowerCase();
                          });

      return str;
    };

    var displayPopup = function(node) {
      d3.event.stopPropagation();
      var svgEl = svg.node();

      var x = d3.mouse(svgEl)[0],
          y = d3.mouse(svgEl)[1];

      var arrowHeight = 10;

      clearPopup();
      popup = findOrCreatePopup();

      if(x <= (mainElement.node().offsetWidth / 2)) {
        popup.classed({'left': true, 'right' :false});
        var arrowOffset = 21; // an eyeballed value I'm afraid
        x = x - arrowOffset;
      } else {
        popup.classed({'right': true, 'left' :false});
        var arrowOffset = 181; // an eyeballed value I'm afraid
        x = x - arrowOffset;
      }
      y = y + arrowHeight;

      var xpx = String(x) + 'px',
          ypx = String(y) + 'px';


      popup.style({'top': ypx, 'left': xpx });
      popup.select('h3.type').text(function(n) { return isActivity(node) ? 'Activity' : node.node_data.resource_type; });
      popup.select('a.name').text(node.node_data.name).attr('href', node.node_data.uri_slug);

      var more_details = node.node_data.more_details;
      var keys = d3.keys(more_details).sort();

      var innerPopup = popup.select('.inner-popup');
      keys.forEach(function(category) {
        innerPopup.append('h3').classed('category', true).text(category);
        var ul = innerPopup.append('ul');
        var val = more_details[category];
        if(isActivity(node)) {
          val.forEach(function(value) {
            ul.append('li').classed('item', true).text(toTitleCase(value));
          });
        } else {
          ul.append('li').classed('item', true).text(val);
        }
      });
    };

    var reparentLinks = function(links, nodes) {
      var lookupNode = buildLookup(nodes);

      links.forEach(function(link) {
        link.source = lookupNode[link.source.node_data.uri_slug];
        link.target = lookupNode[link.target.node_data.uri_slug];
      });

      return links;
    };

    // maps node_uri => node_obj
    var buildLookup = function(nodes) {
      var lookupNode = {};
      nodes.forEach(function(node) {
        lookupNode[node.node_data.uri_slug] = node;
      });

      return lookupNode;
    };

    /* d3's dendrograms don't by default support multiple parents, if
     * a node is shared by multiple parents d3 duplicates it.
     *
     * This function implements the following hack/algorithm:
     *
     * 1) Call d3 and get it to generate a set of nodes.
     * 2) Remove all the duplicate nodes d3 creates (there are no duplicates in
     * the source data).
     * 3) Get d3 to generate links (these will associate source/target)
     * 4) Reparent the links to the shared nodes, rather than the duplicate
     *    nodes assumed by d3's algorithm.
     * 5) reposition all the rows.
     * 6) Normalise the depths to ensure that nodes with no children on the
     *    middle row are not rendered at the top.
     *
     * As we're entirely hacking around d3 here, we might be better
     * just implementing this bit ourselves.  All d3 is really doing
     * here is flattening the tree for us.
     */
    var makeMultiParentTree = function(root) {
      var nodes = cluster.nodes(root);
      nodes = uniqueById(nodes);

      var links = cluster.links(nodes);
      links = reparentLinks(links, nodes);

      var topRow = nodes.filter(isAtDepth(2));
      topRow.sort(byOrganisationType);
      positionRow(topRow);
      positionRow(nodes.filter(isAtDepth(1)));
      positionBottomRow(nodes.filter(isAtDepth(0)));
      nodes.forEach(normaliseDepth);

      return {nodes: nodes, links: links};
    };

    var render = function() {
      var tree = makeMultiParentTree(loadedData);

      cluster.size([getWidth(), height - mainPadding]);
      var nodes = tree.nodes,
          links = tree.links;

      var g = svg.select('g');

      var link = g.selectAll(".link")
            .data(links);

      link.enter().append("path")
        .attr("class", "link")
        .attr("d", diagonal)
        .style('stroke', colourLines);

      var node = g.selectAll(".node")
            .data(nodes);

      node.enter().append("g")
        .classed('node', true)
        .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; })
        .on("click", function(n) {
          displayPopup(n, d3.event);
          //window.open(n.node_data.uri_slug, '_self');
        });

      // temporary tooltips
      node.append('title').text(function(d) { return d.node_data.name; });

      node.append(function(nodeDatum) {
        var el;
        if(isOrganisation(nodeDatum)) {
          el = document.createElementNS(d3.ns.prefix.svg, 'circle');
          d3.select(el)
            .attr('r', scaledNodeWidth(nodeDatum) / 2);
        } else {
          el = document.createElementNS(d3.ns.prefix.svg, 'rect');
          var halfWidth = -(scaledNodeWidth(nodeDatum) / 2),
              halfHeight = -(activityHeight / 2);

          d3.select(el)
            .attr('width', scaledNodeWidth(nodeDatum))
            .attr('height', activityHeight)
            .attr('transform', 'translate(' + halfWidth + ', ' + halfHeight + ')');
        }
        return el;
      });

      // node.selectAll('circle')
      //   .style('fill', colourCircles)
      //   .style('stroke', colourCircles);

    };

    ////////////////////////////////////////////////////////////////////////////
    // PUBLIC METHODS
    ////////////////////////////////////////////////////////////////////////////

    this.init = function() {
      console.log("Initialised Tree View");

      var klass = mainElement.attr('class'); //organisation or project
      var dataUrl = '/' + klass + '/tree_view/' + getResourceId() + '.json';

      d3.json(dataUrl, function(error, root) {
        setLoaded();
        loadedData = root;
        render();
      });

      d3.select(document).on('click', clearPopup);
    };

    this.hasOrganisationAtRoot = function() {
      return mainElement.select('.organisation').length == 1;
    };

    this.hasActivityAtRoot = function() {
      return !this.hasOrganisationAtRoot();
    };

    ////////////////////////////////////////////////////////////////////////////
    // OBJECT STATE
    ////////////////////////////////////////////////////////////////////////////

    var rootRadius = 4,
        height = 300, // TODO make these dynamic
        mainPadding = 60,
        smallCircle   = 4,
        mediumCircle  = 8,
        largeCircle   = 10;

        // // Commented out incase NESTA decide to use this as a sizing metric.
        // orgSizes = {'0-5': smallCircle,
        //             '6-10': smallCircle,
        //             '11-25': mediumCircle,
        //             '26-50': mediumCircle,
        //             '51-100': mediumCircle,
        //             '101-500': largeCircle,
        //             '501-1000': largeCircle,
        //             'over-1000': largeCircle}

    var activityWidth = 32, // TODO make dynamic based on number of activities to render & available width.
        activityHeight = 12;

    var colourOrg = d3.scale.ordinal()
          .domain([
            undefined,
            'http://data.digitalsocial.eu/def/concept/organization-type/academia-and-research',
            'http://data.digitalsocial.eu/def/concept/organization-type/business',
            'http://data.digitalsocial.eu/def/concept/organization-type/government-and-public-sector',
            'http://data.digitalsocial.eu/def/concept/organization-type/grass-roots-organization-or-community-network',
            'http://data.digitalsocial.eu/def/concept/organization-type/social-enterprise-charity-or-foundation'])
          .range(['#AAAAAA',
                  '#165698',
                  '#CC5593',
                  '#B41A2E',
                  '#38994F',
                  '#F9912D']);

    var colourActivity = d3.scale.ordinal()
          .domain([
            'http://data.digitalsocial.eu/def/concept/activity-type/research-project',
            'http://data.digitalsocial.eu/def/concept/activity-type/event',
            'http://data.digitalsocial.eu/def/concept/activity-type/network',
            'http://data.digitalsocial.eu/def/concept/activity-type/incubators-and-accelerators',
            'http://data.digitalsocial.eu/def/concept/activity-type/maker-and-hacker-spaces',
            'http://data.digitalsocial.eu/def/concept/activity-type/education-and-training',
            'http://data.digitalsocial.eu/def/concept/activity-type/delivering-a-web-service',
            'http://data.digitalsocial.eu/def/concept/activity-type/investment-and-funding',
            'http://data.digitalsocial.eu/def/concept/activity-type/advocating-and-campaigning',
            'http://data.digitalsocial.eu/def/concept/activity-type/advisory-or-expert-body',
            'http://data.digitalsocial.eu/def/concept/activity-type/other'
          ])
          .range(["#a6cee3","#1f78b4","#b2df8a","#33a02c","#fb9a99","#e31a1c","#fdbf6f","#ff7f00","#cab2d6","#6a3d9a","#b15928"]);
    //.range(colorbrewer.Paired[11]);
    //.range(colorbrewer.Set3[11]);
    //.range(colorbrewer.PuOr[11]);


    var mainElement = d3.select(id),
        that = this,
        popup;

    var loadedData = null; // The main state / tree data to be loaded.

    var cluster = d3.layout.cluster();

    cluster.separation(function(a, b) {
      return a.parent == b.parent ? 1 : 1;
    });

    cluster.sort(byOrganisationType);

    var diagonal = d3.svg.diagonal()
          .projection(function(d) { return [d.x, d.y]; });

    var svg = createSvg();

    var currentSize = getWidth(),
        lastSize = null;

    window.onresize = windowResized;
  };

  var treeVis = new TreeVis("#tree-vis");
  treeVis.init();

})($,d3, window);
