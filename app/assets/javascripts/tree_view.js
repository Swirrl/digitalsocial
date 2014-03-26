(function($, d3, window) {

  var TreeVis = function(id) {
    var rootRadius = 4,
        width = 960,
        height = 300, // TODO make these dynamic
        mainPadding = 50,
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

    var activityWidth = 32,
        activityHeight = 12;

    var mainElement = d3.select(id),
        that = this;

    var cluster = d3.layout.cluster().size([width, height - mainPadding]);

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

    var nodeWidth = function(node) {
      if(isOrganisation(node)) {
        return circleRadius(node) * 2;
      } else {
        return activityWidth;
      }
    };

    var isActivity = function(node) {
      return node.node_data.resource_type == 'project';
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

    cluster.separation(function(a, b) {
      return a.parent == b.parent ? 1 : 1;
    });

    var byOrganisationType = function(a, b) {
      var aType = a.node_data.organisation_type_label || 'Other',
          bType = b.node_data.organisation_type_label || 'Other';

      return d3.ascending(aType, bType);
    };

    cluster.sort(byOrganisationType);

    var diagonal = d3.svg.diagonal()
          .projection(function(d) { return [d.x, d.y]; });

    var rowScale = d3.scale.linear()
          .rangeRound([0, width - mainPadding]);

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
        node.x = (width / 2);
        return;
      }

      var scaler = rowScale.domain([0, row.length - 1]);

      row.forEach(function(node, i) {
        node.x = scaler(i);
      });
    };

    var positionBottomRow = function(bottomRow) {
        var rootNode = bottomRow[0];
        rootNode.x = (width / 2); // + (nodeWidth(rootNode) / 2);
    };

    var displayTooltip = function(node) {
      alert(node.node_data.name);
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

    this.init = function() {
      console.log("Initialised Tree View");

      var klass = mainElement.attr('class'); //organisation or project
      var dataUrl = '/' + klass + '/tree_view/' + getResourceId() + '.json';

      d3.json(dataUrl, function(error, root) {
        setLoaded();
        console.log(root);

        var _tree = makeMultiParentTree(root),
            nodes = _tree.nodes,
            links = _tree.links;

        var svg = mainElement.append("svg")
              .attr("width", width)
              .attr("height", height)
              .append("g")
              .attr("transform", "rotate(180 480 150) translate(" + (mainPadding / 2) + "," + (mainPadding / 2) + ")");

        var link = svg.selectAll(".link")
              .data(links)
              .enter().append("path")
              .attr("class", "link")
              .attr("d", diagonal);

        var node = svg.selectAll(".node")
              .data(nodes)
              .enter().append("g")
              .classed('node', true)
              .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; })
              .on("click", function(node) {
                displayTooltip(node);
              });

        // temporary tooltips
        node.append('title').text(function(d) { return d.node_data.name; });

        node.append(function(nodeDatum) {
          var el;
          if(isOrganisation(nodeDatum)) {
            el = document.createElementNS(d3.ns.prefix.svg, 'circle');
            d3.select(el)
              .attr('r', circleRadius(nodeDatum));
          } else {
            el = document.createElementNS(d3.ns.prefix.svg, 'rect');
            var halfWidth = -(nodeWidth(nodeDatum) / 2),
                halfHeight = -(activityHeight / 2);

            d3.select(el)
              .attr('width', nodeWidth(nodeDatum))
              .attr('height', activityHeight)
              .attr('transform', 'translate(' + halfWidth + ', ' + halfHeight + ')');
          }
          return el;
        });

        var colourCircles = function(node) {
            var d = node.node_data;
            if(isOrganisation(node)) {
              return colourOrg(d.organisation_type);
            }
          return null;
        };

        node.selectAll('circle')
          .style('fill', colourCircles)
          .style('stroke', colourCircles);

      });
    };

    this.hasOrganisationAtRoot = function() {
      return mainElement.select('.organisation').length == 1;
    };

    this.hasActivityAtRoot = function() {
      return !this.hasOrganisationAtRoot();
    };

  };


  var treeVis = new TreeVis("#tree-vis");
  treeVis.init();

  treeVis.hasOrganisationAtRoot();

  window.treeVis = treeVis;
})($,d3, window);
