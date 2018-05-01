var Bar = React.createClass({
  displayName: "Bar",

  render: function () {
    var style = { "whiteSpace": "nowrap", "height": this.props.height + "px", "backgroundColor": this.props.color };
    if (this.props.category == this.props.selectedCategory) {
      // style['border'] = "2px solid white";
      style['width'] = "125px";
    } else {
      style['width'] = "100px";
    }
    return React.createElement(
      "div",
      { className: "Bar", style: style },
      this.props.category
    );
  }
});

var BarChart = React.createClass({
  displayName: "BarChart",

  render: function () {
    var bars = this.props.data.map(function (key, i) {
      var height = key.value * 0.08;

      return React.createElement(Bar, { key: i, height: height, category: key.label, color: key.color, selectedCategory: this.props.category });
    }.bind(this));

    return React.createElement(
      "div",
      null,
      bars
    );
  }
});

var Timeline = React.createClass({
  displayName: "Timeline",

  render: function () {
    var line = this.props.quarters.map(function (key, i) {
      var style = key == this.props.quarter ? { "color": "red", "fontWeight": "600" } : {};
      return React.createElement(
        "span",
        { key: i, onClick: this.props.onClickHandler, title: key, style: style },
        "|"
      );
    }.bind(this));
    return React.createElement(
      "div",
      null,
      line
    );
  }
});
var Detail = React.createClass({
  displayName: "Detail",

  getInitialState: function () {
    return { data: [] };
  },

  get: function (props) {
    $.ajax({
      url: "get.php",
      data: { 'proc': "get_detail", category: props.category, quarter: props.quarter },
      dataType: 'text',
      cache: false,
      success: function (dataStr) {
        var data = JSON.parse(dataStr);
        this.setState({ data: data });
        initGrid(data);
      }.bind(this),
      error: function (xhr, status, err) {
        console.error(status, err.toString());
      }
    });
  },

  componentWillReceiveProps: function (props) {
    this.get(props);
  },

  render: function () {
    var lines = this.state.data.map(function (key, i) {
      return React.createElement(
        "div",
        { key: i },
        key.Date,
        " ",
        key.Amount,
        " ",
        key.Description,
        " ",
        key['Original Description']
      );
    });
    return React.createElement(
      "div",
      null,
      React.createElement(
        "div",
        null,
        "Discretionary spending by category over time"
      ),
      React.createElement(
        "div",
        { id: "titleDiv" },
        this.props.quarter,
        " -- ",
        this.props.category
      ),
      React.createElement("div", { id: "jsGrid" })
    );
  }
});

var App = React.createClass({
  displayName: "App",


  getInitialState: function () {
    return {
      chartData: [],
      quarters: [],
      idxQuarter: 0,
      category: 'Shopping',
      quarter: '2018-02' };
  },

  getQuarters: function () {
    $.ajax({
      url: "get.php",
      data: { 'proc': "get_quarters" },
      dataType: 'text',
      cache: false,
      success: function (dataStr) {
        var mint_quarter = JSON.parse(dataStr);

        var quarters = [];
        for (var i = 0; i < mint_quarter.length; i++) {
          var q = mint_quarter[i].quarter;
          quarters.push(q);
        }

        var idxQuarter = quarters.length - 1;
        var quarter = quarters[idxQuarter];
        this.setState({ quarters: quarters, idxQuarter: idxQuarter, quarter: quarter });

        // Get some data for the first time.
        this.getData(quarter);
      }.bind(this),
      error: function (xhr, status, err) {
        console.error(status, err.toString());
      }
    });
  },

  getData: function (quarter) {

    $.ajax({
      url: "get.php",
      data: { 'proc': "get_agg", quarter: quarter },
      dataType: 'text',
      cache: false,
      success: function (dataStr) {
        var mint_quarter = JSON.parse(dataStr);
        var chartData = [];

        for (var i = 0; i < mint_quarter.length; i++) {
          var quarter = mint_quarter[i].quarter;
          var type = mint_quarter[i].type;
          if (type == 'debit') chartData.push({
            label: mint_quarter[i].category,
            value: parseInt(mint_quarter[i].sumAmount),
            color: mint_quarter[i].color
          });
        }
        this.setState({ chartData: chartData });

        if (this.pie == null)
          // Create pie chart the first time we have data to show.
          this.renderPie();else
          // Update existing pie chart.
          this.update();

        setTimeout(this.openPieSlice, 100);
      }.bind(this),
      error: function (xhr, status, err) {
        console.error(status, err.toString());
      }
    });
  },

  openPieSlice: function () {
    var selectedSliceIdx = -1;
    for (var i = 0; i < this.state.chartData.length; i++) {
      if (this.state.chartData[i].label == this.state.category) {
        selectedSliceIdx = i;
        break;
      }
    }

    if (selectedSliceIdx != -1 && this.pie != null) {
      this.pie.closeSegment();
      this.pie.openSegment(selectedSliceIdx);
    }
  },

  //
  // Keyboard input
  //
  onKeyDown: function (event) {
    this.pie.closeSegment();
    event.preventDefault();
  },

  onKeyUp: function (event) {
    switch (event.keyCode) {
      case 37:
        // left
        this.onClickPrev();
        break;
      case 38:
        // up
        this.upCategory(-1);
        break;
      case 39:
        // right
        this.onClickNext();
        break;
      case 40:
        // down
        this.upCategory(1);
        break;
    }
    event.preventDefault();
  },

  componentDidMount: function () {
    this.getQuarters();
    document.body.onkeydown = function (e) {
      this.onKeyDown(e);
    }.bind(this);
    document.body.onkeyup = function (e) {
      this.onKeyUp(e);
    }.bind(this);
  },

  update: function () {
    this.pie.updateProp("data.content", this.state.chartData);
    //  this.pie.updateProp("header.title.text", this.state.quarter);
    //  setTimeout(this.openPieSlice, 0);
  },

  upCategory: function (direction) {
    var catIdx = -1;
    for (var i = 0; i < this.state.chartData.length; i++) {
      if (this.state.chartData[i].label == this.state.category) {
        catIdx = i;
        break;
      }
    }

    if (catIdx != -1) {
      var i = (catIdx + direction) % this.state.chartData.length;
      if (i < 0) {
        i = this.state.chartData.length + i;
      }
      // var i = Math.min(this.state.chartData.length - 1, Math.max(0, catIdx + direction));

      var newCat = this.state.chartData[i].label;
      this.setState({ category: newCat });
    }

    this.openPieSlice();
  },

  onClickPrev: function () {
    var idxQuarter = Math.max(0, this.state.idxQuarter - 1);
    var quarter = this.state.quarters[idxQuarter];
    this.setState({ idxQuarter: idxQuarter, quarter: quarter });
    this.getData(quarter);
  },

  onClickNext: function () {
    var idxQuarter = Math.min(this.state.quarters.length - 1, this.state.idxQuarter + 1);
    var quarter = this.state.quarters[idxQuarter];
    this.setState({ idxQuarter: idxQuarter, quarter: quarter });
    this.getData(quarter);
  },

  jump: function (e) {
    this.setState({ quarter: e.target.title, idxQuarter: this.state.quarters.indexOf(e.target.title) });
    this.getData(e.target.title);
  },

  renderPie: function () {
    this.pie = new d3pie("pieChart", {
      size: {
        canvasHeight: 400,
        canvasWidth: 550,
        pieInnerRadius: "60%"
      },
      effects: {
        load: {
          effect: "none"
        }
      },
      data: { content: this.state.chartData },
      callbacks: {
        onClickSegment: function (a) {
          this.setState({ category: a.data.label });
        }.bind(this)
      }
    });

    // Global var needed by d3pie to open and close a segment.
    pie = this.pie;
  },

  render: function () {
    return React.createElement(
      "div",
      null,
      React.createElement(
        "div",
        { id: "chartDiv" },
        React.createElement("div", { id: "pieChart" }),
        React.createElement(Timeline, { quarters: this.state.quarters, onClickHandler: this.jump, quarter: this.state.quarter }),
        React.createElement(
          "button",
          { onClick: this.onClickPrev },
          "previous"
        ),
        React.createElement(
          "span",
          null,
          this.state.quarter
        ),
        React.createElement(
          "button",
          { onClick: this.onClickNext },
          "next"
        )
      ),
      React.createElement(
        "div",
        { id: "barchartDiv" },
        React.createElement(BarChart, { data: this.state.chartData, category: this.state.category })
      ),
      React.createElement(
        "div",
        { id: "detailDiv" },
        React.createElement(Detail, { quarter: this.state.quarter, category: this.state.category })
      )
    );
  }
});

function renderRoot(dish, business_id) {
  var domContainerNode = window.document.getElementById('content');
  ReactDOM.unmountComponentAtNode(domContainerNode);
  ReactDOM.render(React.createElement(App, null), domContainerNode);
}

function initApp() {
  renderRoot();
}