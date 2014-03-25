(function($, d3, window) {

  var TreeVis = function(id) {
    var rootRadius = 4,
        width = 960,
        height = 300, // TODO make these dynamic
        mainPadding = 50,
        smallCircle   = 4,
        mediumCircle  = 8,
        largeCircle   = 10,
        orgSizes = {'0-5': smallCircle,
                    '6-10': smallCircle,
                    '11-25': mediumCircle,
                    '26-50': mediumCircle,
                    '51-100': mediumCircle,
                    '101-500': largeCircle,
                    '501-1000': largeCircle,
                    'over-1000': largeCircle};

    var activityWidth = 32,
        activityHeight = 12;

    var mainElement = d3.select(id),
        that = this;

    var cluster = d3.layout.cluster().size([width, height - mainPadding]);

    var nodeWidth = function(node) {
      if(isOrganisation(node)) {
        return circleRadius(node) * 2;
      } else {
        return activityWidth;
      }
    };

    var isOrganisation = function(node) {
      return node.node_data.resource_type == 'organisation';
    };

    var isActivity = function(node) {
      return node.node_data.resource_type == 'project';
    };

    var circleRadius = function(node) {
      var key = node.node_data.more_details['No of Staff'];
      return orgSizes[key] || smallCircle;
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

    this.init = function() {
      console.log("Initialised Tree View");

      var klass = mainElement.attr('class'); //organisation or project
      var dataUrl = '/' + klass + '/tree_view/' + getResourceId() + '.json';

      d3.json(dataUrl, function(error, root) {
        setLoaded();
        console.log(root);

        var nodes = cluster.nodes(root),
            links = cluster.links(nodes);

        nodes.forEach(normaliseDepth);

        var topRow = nodes.filter(isAtDepth(2));
        topRow.sort(byOrganisationType);

        positionRow(topRow);
        positionRow(nodes.filter(isAtDepth(1)));
        positionBottomRow(nodes.filter(isAtDepth(0)));

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
              .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; });

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
