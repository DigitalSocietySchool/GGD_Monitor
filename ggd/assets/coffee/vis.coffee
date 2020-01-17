
root = exports ? this

#Years for outline
years = {}
for x in [1970..2020] by 10
    years[x] = "#FFFFFF"
console.log years

getBorderColors = (year) ->
  arcFill = years
  for y in year.split(";")
    arcFill[Math.trunc(y/10)*10] = "#000000"
  console.log arcFill
  return (val for key, val of arcFill)

Bubbles = () ->
  # standard variables accessible to
  # the rest of the functions inside Bubbles
  width = 980
  height = 510
  data = []
  node = null
  label = null
  margin = {top: 5, right: 0, bottom: 0, left: 0}
  # largest size for our bubbles
  maxRadius = 65

  # this scale will be used to size our bubbles
  rScale = d3.scale.sqrt().range([0,maxRadius])
  
  # I've abstracted the data value used to size each
  # into its own function. This should make it easy
  # to switch out the underlying dataset
  rValue = (d) -> parseInt(d.size)
          
  # EMMA
  # Extractig values for donut charts
  pie_bub = (d) -> d3.pie()([1,1,1,1,1,1])

  arc_bub = d3.svg.arc()
    .outerRadius( 100 )
    .innerRadius( 0 )

  # function to define the 'id' of a data element
  #  - used to bind the data uniquely to the force nodes
  #   and for url creation
  #  - should make it easier to switch out dataset
  #   for your own
  idValue = (d) -> d.name

  # function to define what to display in each bubble
  #  again, abstracted to ease migration to 
  #  a different dataset if desired
  textValue = (d) -> d.name

  # function to retrieve the department
  department = (d) -> d.department


  policy = (d) -> d.policy


  keywords = (d) -> d.keywords

  # Fill Colors by department
  colors =
    EGZ: "#BB9BD1"
    IZ: "#8FBCD8"
    JGZ: "#ADC499"
    VT: "#C69C6D"
    MGGZ: "#C69C6D"
    FGMA: "#EA948B"
    GHOR: "#E3ACE5"
    LO: "#B3B3B3"
    AAGG: "#D9E021"

  # constants to control how
  # collision look and act
  collisionPadding = 4
  minCollisionRadius = 12

  # variables that can be changed
  # to tweak how the force layout
  # acts
  # - jitter controls the 'jumpiness'
  #  of the collisions
  jitter = 0.5

  # ---
  # tweaks our dataset to get it into the
  # format we want
  # - for this dataset, we just need to
  #  ensure the count is a number
  # - for your own dataset, you might want
  #  to tweak a bit more
  # ---
  transformData = (rawData) ->
    rawData.forEach (d) ->
      d.size = parseInt(d.size)
      rawData.sort(() -> 0.5 - Math.random())
    rawData

  # ---
  # tick callback function will be executed for every
  # iteration of the force simulation
  # - moves force nodes towards their destinations
  # - deals with collisions of force nodes
  # - updates visual bubbles to reflect new force node locations
  # ---
  tick = (e) ->
    dampenedAlpha = e.alpha * 0.1
    
    # Most of the work is done by the gravity and collide
    # functions.
    node
      .each(gravity(dampenedAlpha))
      .each(collide(jitter))
      .attr("transform", (d) -> "translate(#{d.x},#{d.y})")

    # As the labels are created in raw html and not svg, we need
    # to ensure we specify the 'px' for moving based on pixels
    label
      .style("left", (d) -> ((margin.left + d.x) - d.dx / 2) + "px")
      .style("top", (d) -> ((margin.top + d.y) - d.dy / 2) + "px")

  # The force variable is the force layout controlling the bubbles
  # here we disable gravity and charge as we implement custom versions
  # of gravity and collisions for this visualization
  force = d3.layout.force()
    .gravity(0)
    .charge(0)
    .size([width, height])
    .on("tick", tick)

  # ---
  # Creates new chart function. This is the 'constructor' of our
  #  visualization
  # Check out http://bost.ocks.org/mike/chart/ 
  #  for a explanation and rational behind this function design
  # ---
  chart = (selection) ->

    selection.each (rawData) ->
      
      console.log(rawData)

      # first, get the data in the right format
      data = transformData(rawData)
      # setup the radius scale's domain now that
      # we have some data

      maxDomainValue = d3.max(data, (d) -> rValue(d))
      rScale.domain([0, maxDomainValue])

      # a fancy way to setup svg element
      svg = d3.select(this).selectAll("svg").data([data])
      svgEnter = svg.enter().append("svg")
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )
      
      # node will be used to group the bubbles
      node = svgEnter.append("g").attr("id", "bubble-nodes")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      # clickable background rect to clear the current selection
      node.append("rect")
        .attr("id", "bubble-background")
        .attr("width", width)
        .attr("height", height)
        .on("click", clear)

      # label is the container div for all the labels that sit on top of 
      # the bubbles
      # - remember that we are keeping the labels in plain html and 
      #  the bubbles in svg
      label = d3.select(this).selectAll("#bubble-labels").data([data])
        .enter()
        .append("div")
        .attr("id", "bubble-labels")

        

      update()

      # see if url includes an id already 
      hashchange()

      # automatically call hashchange when the url has changed
      d3.select(window)
        .on("hashchange", hashchange)


    # search function callback
    $(".button").on "click", ->
      # data = data.filter( (d) -> d.name == ("Dataset_3"||"Dataset_2"))
      # updateNodes(data)
      # updateLabels(data)
      
      input = $(".searchInput").val();
      d3.select("#status").html("<h3>search results for <span class=\"active\"> " + String(input) + " </span> </h3>")

      theNode = d3.selectAll(".bubble-node")
                    .filter( (d,i) ->                                   
                                      d.keywords.includes(input));
      theLabel = d3.selectAll(".bubble-label")
                    .filter( (d) -> d.keywords.includes(input))
      console.log("theNode")
      console.log(theNode)
      d3.selectAll(".bubble-node").style("opacity","0");
      theNode.style("opacity","1")
      d3.selectAll(".bubble-label").style("opacity","0");
      theLabel.style("opacity","1")

  $(".reset").on "click", ->
        d3.selectAll(".bubble-node").style("opacity","1");
        d3.selectAll(".bubble-label").style("opacity","1");
        d3.select("#status").html("<h3>No dataset is selected</h3>")

  
  # ---
  # update starts up the force directed layout and then
  # updates the nodes and labels
  # ---
  update = () ->
    # add a radius to our data nodes that will serve to determine
    # when a collision has occurred. This uses the same scale as
    # the one used to size our bubbles, but it kicks up the minimum
    # size to make it so smaller bubbles have a slightly larger 
    # collision 'sphere'
    
    data.forEach (d,i) ->
      d.forceR = Math.max(minCollisionRadius, rScale(rValue(d)))

    # start up the force layout
    force.nodes(data).start()

    # call our update methods to do the creation and layout work
    updateNodes(data)
    updateLabels(data)

  # ---
  # updateNodes creates a new bubble for each node in our dataset
  # ---
  updateNodes = (datas) ->
    # here we are using the idValue function to uniquely bind our
    # data to the (currently) empty 'bubble-node selection'.
    # if you want to use your own data, you just need to modify what
    # idValue returns
    console.log("datas")
    console.log(datas)

    node = node.selectAll(".bubble-node").data(datas, (d) -> idValue(d))
    console.log(node)  
    # we don't actually remove any nodes from our data in this example 
    # but if we did, this line of code would remove them from the
    # visualization as well
    node.exit().remove()
    console.log(node)  

    # nodes are just links with circles inside.
    # the styling comes from the css
    node.enter()
      .append("a")
      .attr("class", "bubble-node")
      .attr("xlink:href", (d) -> "##{encodeURIComponent(idValue(d))}")
      .style("fill", (d) -> colors[d.department])
      .call(force.drag)
      .call(connectEvents)
      .append("circle")
      .attr("r", (d) -> rScale(rValue(d)))

    # drawing the Pie chart ( timeline)

    node.append("g")
        .attr("class", "pie")
        .attr('data_col', (d) -> getBorderColors(d.years))
        .attr("width",  (d) -> rScale(rValue(d)) * 2 )
        .attr("height", (d) -> rScale(rValue(d)) * 2 )
        .attr("transform", (d) -> "scale(" + rScale(rValue(d))/100 + "," + rScale(rValue(d))/100 + ")" )
      .selectAll(".arc")
        .data( (d) -> pie_bub(d) )
      .enter().append("path")
        .attr("class", "arc")
       .attr("d", (d) -> arc_bub(d) )
        .attr('stroke','#ffffff')

    # drawing the visible circle
    node.append("circle")
      .attr("r", (d) -> rScale(rValue(d)-20))

    #adding svgs to the circle
    node.append("image")
    .attr("xlink:href", "assets/img/glyphs/glyph-empty.png")
    .attr("class", "catDataset")
        .attr("width",  (d) -> rScale(rValue(d)) / 2 )
        .attr("height", (d) -> rScale(rValue(d)) / 2 )
        .style("transform", "translate(-1%, -3%)")
        .style("transform-origin","6px 56px;")
    
    petals = 
      "Social Media": "right"
      "Health Promotion": "diagonal-right"
      "Registry": "diagonal-left"
      "Monitor": "left"
      "Questionaire": "top"

    for p, dir of petals
      node.append("image")
        .attr("xlink:href", (d)-> if d.type.indexOf(p) != -1 then "assets/img/glyphs/glyph-" + dir + ".png")
        .attr("class", "catDataset")
        .attr("width",  (d) -> rScale(rValue(d)) / 2 )
        .attr("height", (d) -> rScale(rValue(d)) / 2 )
        .style("transform", "translate(-1%, -3%)")
        .style("transform-origin","6px 56px;")

    node.selectAll(".pie")
      .selectAll(".arc")
        .attr("fill", (d,i) -> d3.select(this.parentNode).attr("data_col").split(",")[i] )




  # ---
  # updateLabels is more involved as we need to deal with getting the sizing
  # to work well with the font size
  # ---
  updateLabels = (datas) ->
    # as in updateNodes, we use idValue to define what the unique id for each data 
    # point is
    label = label.selectAll(".bubble-label").data(datas, (d) -> idValue(d))

    label.exit().remove()

    # labels are anchors with div's inside them
    # labelEnter holds our enter selection so it 
    # is easier to append multiple elements to this selection
    labelEnter = label.enter().append("a")
      .attr("class", "bubble-label")
      .attr("href", (d) -> "##{encodeURIComponent(idValue(d))}")
      .call(force.drag)
      .call(connectEvents)

    labelEnter.append("div")
      .attr("class", "bubble-label-name")
      .text((d) -> textValue(d))

    labelEnter.append("div")
      .attr("class", "bubble-label-value")
      .text((d) -> rValue(d))

    # label font size is determined based on the size of the bubble
    # this sizing allows for a bit of overhang outside of the bubble
    # - remember to add the 'px' at the end as we are dealing with 
    #  styling divs
    label
      .style("font-size", (d) -> Math.max(4, rScale(rValue(d) / 12)) + "px")
      .style("width", (d) -> 2.5 * rScale(rValue(d)) + "px")

    # interesting hack to get the 'true' text width
    # - create a span inside the label
    # - add the text to this span
    # - use the span to compute the nodes 'dx' value
    #  which is how much to adjust the label by when
    #  positioning it
    # - remove the extra span
    label.append("span")
      .text((d) -> textValue(d))
      .each((d) -> d.dx = Math.max(2.5 * rScale(rValue(d)), this.getBoundingClientRect().width))
      .remove()

    # reset the width of the label to the actual width
    label
      .style("width", (d) -> d.dx + "px")
  
    # compute and store each nodes 'dy' value - the 
    # amount to shift the label down
    # 'this' inside of D3's each refers to the actual DOM element
    # connected to the data node
    label.each((d) -> d.dy = this.getBoundingClientRect().height)

  # ---
  # custom gravity to skew the bubble placement
  # ---
  gravity = (alpha) ->
    # start with the center of the display
    cx = width / 2
    cy = height / 2
    # use alpha to affect how much to push
    # towards the horizontal or vertical
    ax = alpha / 8
    ay = alpha

    # return a function that will modify the
    # node's x and y values
    (d) ->
      d.x += (cx - d.x) * ax
      d.y += (cy - d.y) * ay

  # ---
  # custom collision function to prevent
  # nodes from touching
  # This version is brute force
  # we could use quadtree to speed up implementation
  # (which is what Mike's original version does)
  # ---
  collide = (jitter) ->
    # return a function that modifies
    # the x and y of a node
    (d) ->
      data.forEach (d2) ->
        # check that we aren't comparing a node
        # with itself
        if d != d2
          # use distance formula to find distance
          # between two nodes
          x = d.x - d2.x
          y = d.y - d2.y
          distance = Math.sqrt(x * x + y * y)
          # find current minimum space between two nodes
          # using the forceR that was set to match the 
          # visible radius of the nodes
          minDistance = d.forceR + d2.forceR + collisionPadding

          # if the current distance is less then the minimum
          # allowed then we need to push both nodes away from one another
          if distance < minDistance
            # scale the distance based on the jitter variable
            distance = (distance - minDistance) / distance * jitter
            # move our two nodes
            moveX = x * distance
            moveY = y * distance
            d.x -= moveX
            d.y -= moveY
            d2.x += moveX
            d2.y += moveY

  # ---
  # adds mouse events to element
  # ---
  connectEvents = (d) ->
    d.on("click", click)
    d.on("mouseover", mouseover)
    d.on("mouseout", mouseout)

  # ---
  # clears currently selected bubble
  # ---
  clear = () ->
    location.replace("#")

  # ---
  # changes clicked bubble by modifying url
  # ---
  click = (d) ->
    location.replace("#" + encodeURIComponent(idValue(d)))
    d3.event.preventDefault()

  # ---
  # called when url after the # changes
  # ---
  hashchange = () ->
    id = decodeURIComponent(location.hash.substring(1)).trim()
    updateActive(id)

  # ---
  # activates new node
  # ---
  updateActive = (id) ->
    node.classed("bubble-selected", (d) -> id == idValue(d))
    # if no node is selected, id will be empty
    if id.length > 0
      d3.select("#status").html("<h3>The <span class=\"active\">#{id}</span> is now selected</h3>")
    else
      d3.select("#status").html("<h3>No dataset is selected</h3>")

  # ---
  # hover event
  # ---
  mouseover = (d) ->
    node.classed("bubble-hover", (p) -> p == d)

  # ---
  # remove hover class
  # ---
  mouseout = (d) ->
    node.classed("bubble-hover", false)

  # ---
  # public getter/setter for jitter variable
  # ---
  chart.jitter = (_) ->
    if !arguments.length
      return jitter
    jitter = _
    force.start()
    chart

  # ---
  # public getter/setter for height variable
  # ---
  chart.height = (_) ->
    if !arguments.length
      return height
    height = _
    chart

  # ---
  # public getter/setter for width variable
  # ---
  chart.width = (_) ->
    if !arguments.length
      return width
    width = _
    chart

  # ---
  # public getter/setter for radius function
  # ---
  chart.r = (_) ->
    if !arguments.length
      return rValue
    rValue = _
    chart
  
  # final act of our main function is to
  # return the chart function we have created
  return chart

# ---
# Helper function that simplifies the calling
# of our chart with it's data and div selector
# specified
# ---
root.plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)

texts = [
  {key:"sherlock",file:"dummy.csv",name:"GGD Monitor Test File"}
]

# ---
# jQuery document ready.
# ---
$ ->
  # create a new Bubbles chart
  plot = Bubbles()

  # ---
  # function that is called when
  # data is loaded
  # ---
  display = (data) ->
    data.time = [data.Y1970,
          data.Y1980,
          data.Y1990,
          data.Y2000,
          data.Y2010,
          data.Y2020]
    plotData("#vis", data, plot)

  # we are storing the current text in the search component
  # just to make things easy
  key = decodeURIComponent(location.search).replace("?","")
  text = texts.filter((t) -> t.key == key)[0]

  # default to the first text if something gets messed up
  if !text
    text = texts[0]

  # select the current text in the drop-down
  $("#text-select").val(key)

  # bind change in jitter range slider
  # to update the plot's jitter
  d3.select("#jitter")
    .on "input", () ->
      plot.jitter(parseFloat(this.output.value))

  # bind change in drop down to change the
  # search url and reset the hash url
  d3.select("#text-select")
    .on "change", (e) ->
      key = $(this).val()
      location.replace("#")
      location.search = encodeURIComponent(key)

  # set the book title from the text name
  d3.select("#book-title").html(text.name)

  # load our data
  d3.csv("data/ggd.csv", display)

