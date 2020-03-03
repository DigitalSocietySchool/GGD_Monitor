
root = exports ? this

# Years to show in bubble contour
getBorderColors = (year) ->
  arcFill = {}
  for x in [0..17] by 1
    arcFill[x] = "#FFFFFF"

  current_year = (new Date).getFullYear()
  for y in year.split(";")
    if y < current_year - 17
      y = current_year - 17
    index = current_year - parseInt(y)
    arcFill[index] = "#000000"
  return (val for key, val of arcFill)

getBorderOpacity = (year) ->
  arcOpacity = {}
  for x in [0..17] by 1
    arcOpacity[x] = 0

  current_year = (new Date).getFullYear()
  for y in year.split(";")
    if y < current_year - 17
      y = current_year - 17
    index = current_year - parseInt(y)
    arcOpacity[index] = 1
  return (val for key, val of arcOpacity)

root.Bubbles = () ->
  # standard variables accessible to
  # the rest of the functions inside Bubbles
  width = 1200
  height = 700
  data = []
  node = null
  label = null
  margin = {top: 0, right: 0, bottom: 0, left: 0}
  # largest size for our bubbles
  maxRadius = 45


  d3.select('#vis')
    .attr("width", width + margin.left + margin.right )
    .attr("height", height + margin.top + margin.bottom )

  # this scale will be used to size our bubbles
  root.rScale = d3.scale.sqrt().range([0,maxRadius])
  
  # I've abstracted the data value used to size each
  # into its own function. This should make it easy
  # to switch out the underlying dataset
  root.rValue = (d) -> Math.max( Math.min(parseInt(d.size), 2000), 20)

          
  # Extractig values for donut charts
  pie_bub = (d) -> d3.pie()(Array(18).fill(1))

  arc_bub = d3.svg.arc()
    .outerRadius( 100 )
    .innerRadius( 0 )

  # function to define the 'id' of a data element
  #  - used to bind the data uniquely to the force nodes
  #   and for url creation
  #  - should make it easier to switch out dataset
  #   for your own
  root.idValue = (d) -> d.ID

  # function to define what to display in each bubble
  #  again, abstracted to ease migration to 
  #  a different dataset if desired
  textValue = (d) -> d.name

  # function to retrieve the department
  geo = (d) -> d.geo
  population = (d) -> d.population
  # type
  level = (d) -> d.level
  size = (d) -> d.size
  department = (d) -> d.department
  time  = (d) -> d.time

  keywords = (d) -> d.keyword
  indicator = (d) -> d.indicator

  # Fill Colors by department
  colors =
    EGZ: "#BB9BD1"
    IZ: "#8FBCD8"
    JGZ: "#ADC499"
    VT: "#C69C6D"
    MGGZ: "#f384a3"
    FGMA: "#EA948B"
    GHOR: "#E3ACE5"
    LO: "#B3B3B3"
    AAGG: "#D9E021"
    unknown: "#dddddd"

  # constants to control how
  # collision look and act
  collisionPadding = 2
  minCollisionRadius = 12

  # variables that can be changed
  # to tweak how the force layout
  # acts
  # - jitter controls the 'jumpiness'
  #  of the collisions
  jitter = 0.2

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
    #filtered = node.attr('filtered')

    node
      .each(gravity(dampenedAlpha))
      .each(collide(jitter))
      .attr("transform", (d) -> "translate(#{d.x},#{d.y})"+ ",scale(#{d.ui_scale})") 
      
    #node.attr('transform', node.attr("transform") + ",scale(" + node.attr(filter_scale) + ")")
    # As the labels are created in raw html and not svg, we need
    # to ensure we specify the 'px' for moving based on pixels
    # - this.offsetWidth

    label
      .style("position", 'absolute')
      .style("left", (d) -> ((d.x)-25 + d.forceR) + "px")
      #.style("left", (d) -> ((d.x) - d.dx / 2) + "px")
      .style("top", (d) -> ((d.y) - d.dy / 2 ) + "px")
      .style("transform-origin","50% 50%")
      .style("font-size", (d) -> 8 + d.forceR/5 + "px")

  # The force variable is the force layout controlling the bubbles
  # here we disable gravity and charge as we implement custom versions
  # of gravity and collisions for this visualization
  force = d3.layout.force()
    .gravity(0)
    .charge(0)
    .size([width, height])
    .on("tick", tick) #, {passive: true}

  # ---
  # Creates new chart function. This is the 'constructor' of our
  #  visualization
  # Check out http://bost.ocks.org/mike/chart/ 
  #  for a explanation and rational behind this function design
  # ---
  chart = (selection) ->

    selection.each (rawData) ->
      
      #console.log(rawData)

      # first, get the data in the right format
      data = transformData(rawData)
      # data = rawData
      # setup the radius scale's domain now that
      # we have some data

      maxDomainValue = d3.max(data, (d) -> rValue(d))
      rScale.domain([0, maxDomainValue])

      # a fancy way to setup svg element
      svg = d3.select(this).selectAll("svg").data([data])
      svgEnter = svg.enter().append("svg")
      svg
        .attr("width", width)
        .attr("height", height )
        .attr("id","svg_main")
        .attr("transform", "translate(#{margin.left},#{margin.top})")
      
      # node will be used to group the bubbles
      node = svgEnter.append("g")
        .attr("id", "bubble-nodes")
        .attr("width", width )
        .attr("height", height )
        .attr("style",'border: 1px #f00 solid;')
        .attr("transform", "translate(-30,0)")

      # clickable background rect to clear the current selection
      node.append("rect")
        .attr("id", "bubble-background")
        .attr("width", width)
        .attr("height", height)
        .on("click", clear) #, {passive: true}

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
        .on("hashchange", hashchange, {passive: true})

      changeView('population');

    # search function callback
    $("#searchStart").on "click", ->
      # data = data.filter( (d) -> d.name == ("Dataset_3"||"Dataset_2"))
      # updateNodes(data)
      # updateLabels(data)
      
      input = $("#searchInput").val();
      d3.select("#status").html("Search results for <span class=\"active\"> " + String(input) + " </span>&nbsp;&nbsp;&nbsp;")

      theNode = d3.selectAll(".bubble-node")
                    .filter( (d,i) ->  
                      d.keyword.includes(input) |
                      d.time.includes(input) |
                      d.description.search(input) != -1 |
                      d.publication.search(input) != -1 |
                      d.contact.search(input) != -1  |
                      d.indicator.search(input) != -1 
                )
      theLabel = d3.selectAll(".bubble-label")
                    .filter( (d) ->
                      d.keyword.includes(input) |
                      d.time.includes(input) |
                      d.description.search(input) != -1 |
                      d.publication.search(input) != -1 |
                      d.contact.search(input) != -1  |
                      d.indicator.search(input) != -1 
                    )
      
      d3.selectAll(".bubble-node").transition().duration(150).style("opacity","0.2")
      theNode.transition().duration(150).style("opacity","1")

  $(".reset").on "click", ->
        d3.selectAll(".bubble-node").transition().duration(150).style("opacity","1")
        d3.selectAll(".bubble-label").transition().duration(150).style("opacity","1")
        d3.select("#status").html("")
        $("#searchInput").val('')
  

    
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
      d.ui_scale = 1

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
    #console.log("datas")
    #console.log(datas)

    node = node.selectAll(".bubble-node").data(datas, (d) -> idValue(d))

    # we don't actually remove any nodes from our data in this example 
    # but if we did, this line of code would remove them from the
    # visualization as well
    node.exit().remove()

    # nodes are just links with circles inside.
    # the styling comes from the css
    node.enter()
      .append("a")
        .attr("class", "bubble-node bubble-visible")
        .attr("xlink:href", (d) -> "##{encodeURIComponent(idValue(d))}")
        .attr("data-id", (d) -> d.ID)
        .attr("id", (d) -> "node_" + d.ID.toString())
        .style("fill", (d) -> colors[d.department.replace('-','unknown')])
        .attr("fill", (d) -> colors[d.department.replace('-','unknown')])
        .attr("contact", (d) -> d.contact)
        .attr("keywords", (d) -> d.keyword)
        .attr("indicators", (d) -> d.indicator)
        .attr("geo", (d) -> d.geo)
        .attr("pop", (d) -> d.population)
        .attr("type", (d) -> d.type)
        .attr("level", (d) -> d.level)
        .attr("size", (d) -> d.size)
        .attr("dep", (d) -> d.department)
        .attr("time", (d) -> d.time)
        .attr("filter_scale", (d) -> d.ui_scale)
        .call(force.drag)
        .call(connectEvents)

    # Adding time dimension
    node
      .append("g")
        .attr("class", "pie")
        .attr("id", (d) -> "g_" + d.ID.toString())
        .attr('data_col', (d) -> getBorderColors(d.time))
        .attr('data_opac', (d) -> getBorderOpacity(d.time))
        .attr("width",  (d) -> rScale(rValue(d)) * 2 )
        .attr("height", (d) -> rScale(rValue(d)) * 2 )
        .attr("transform", (d) -> "scale(" + rScale(rValue(d))/100 + "," + rScale(rValue(d))/100 + ")" )
      .selectAll(".arc")
        .data( (d) -> pie_bub(d) )
      .enter().append("path")
        .attr("class", "arc")
       .attr("d", (d) -> arc_bub(d) )
        .attr('stroke','#ffffff')

    # Fix color of pie chart    
    node.selectAll(".pie")
      .selectAll(".arc")
        .attr("fill", (d,i) -> d3.select(this.parentNode).attr("data_col").split(",")[i] )
        .attr("opacity", (d,i) -> d3.select(this.parentNode).attr("data_opac").split(",")[i] )



    # drawing the visible circle
    node
      .append("g")
      .append("circle")
        .attr('id', (d) -> 'svg_icon_dep_'+d.ID)
        .attr("r", (d) -> Math.max(12, rScale(rValue(d))-4 ) )


    # Adding type dimension
    type_g = node.append('g')

    type_g
      .append("image")
      .attr("xlink:href", "assets/img/glyphs/glyph-empty.png")
      .attr("class", "cat_type")
      .attr("width",  (d) -> rScale(rValue(d)) * 1.15 )
      .attr("height", (d) -> rScale(rValue(d)) * 1.15 )
      .style("transform", (d) -> "translate(-"+ rScale(rValue(d))*0.555 +'px,-'+ rScale(rValue(d))*0.6 +'px)') 
      .style("transform-origin","50% 50%")

    petals = 
      "socialmedia": "socialmedia"
      "promotion": "promotion"
      "registry": "registry"
      "monitor": "monitor"
      "questionnaire": "questionnaire"

    for p, dir of petals
      type_g
        .append("image")
        .attr("xlink:href", (d)-> if d.type.indexOf(p) != -1 then "assets/img/glyphs/glyph-" + dir + ".png")
        .attr("class", "cat_type " + dir)
        .attr("width",  (d) -> rScale(rValue(d)) * 1.15 )
        .attr("height", (d) -> rScale(rValue(d)) * 1.15 )
        .style("transform", (d) -> "translate(-"+ rScale(rValue(d))*0.555 +'px,-'+ rScale(rValue(d))*0.6 +'px)') 
        .style("transform-origin","50% 50%")


    # Adding population dimension
    pop_g = node.append('g')

    pop_g
      .append("image")
      .attr("xlink:href", "assets/img/icon/pop_empty.png")
      .attr("class", "cat_population")
      .attr("width",  (d) -> rScale(rValue(d)) * 1.15 )
      .attr("height", (d) -> rScale(rValue(d)) * 1.15 )
      .style("transform", (d) -> "translate(-"+ rScale(rValue(d))*0.555 +'px,-'+ rScale(rValue(d))*0.6 +'px)') 
      .style("transform-origin","50% 50%")

    population = 
      "youth" : "pop_1_youth.png"
      "young" : "pop_2_young_adult.png"
      "adult" : "pop_3_adult.png"
      "elderly" : "pop_4_elderly.png"

    for p, img of population
      pop_g
        .append("image")
        .attr("xlink:href", (d)-> if d.population.split(";").indexOf(p) != -1 then "assets/img/icon/" + img)
        .attr("class", "cat_population")
        .attr("width",  (d) -> rScale(rValue(d)) * 1.15 )
        .attr("height", (d) -> rScale(rValue(d)) * 1.15 )
        .style("transform", (d) -> "translate(-"+ rScale(rValue(d))*0.555 +'px,-'+ rScale(rValue(d))*0.6 +'px)') 
        .style("transform-origin","50% 50%")
    
    # Adding geo dimension
    geo_g = node.append('g')

    coverage = 
      "straat" : "icon/geo_1.png"
      "buurt" : "icon/geo_1.png"
      "wijk" : "icon/geo_1.png"
      "gebied" : "icon/geo_2.png"
      "stadsdeel" : "icon/geo_2.png"
      "stad" : "icon/geo_2.png"
      "amstelland" : "icon/geo_3.png"
      "adam" : "icon/geo_3.png"
      "g4" : "icon/geo_3.png"
      "national" : "icon/geo_3.png"

    for c, img of coverage
      geo_g
        .append("image")
        .attr('id', (d) -> 'svg_icon_geo_'+c+'_'+d.ID)
        .attr("xlink:href", (d) -> if d.geo.indexOf(c) != -1 then "assets/img/" + img)
        .attr("class", "cat_geo")
        .attr("width",  (d) -> rScale(rValue(d)) * 1.15 )
        .attr("height", (d) -> rScale(rValue(d)) * 1.15 )
        .style("transform-origin","50% 50%")
        .style("transform", (d) -> "translate(-"+ rScale(rValue(d))/1.8 +'px,-'+ rScale(rValue(d))/1.5 +'px)') 
        
    # Adding population dimension
    level_g = node.append('g').attr('id','svg_level')

    level =
      "individual" : "icon/level_1_individual.png"
      "family" : "icon/level_2_family.png"
      "group" : "icon/level_3_group.png"
      "orga" : "icon/level_4_orga.png"
      "geographic" : "icon/level_5_geographic.png"

    for l, img of level
      level_g
        .append("image")
        .attr('id', (d) -> 'svg_icon_level_'+l+'_'+d.ID)
        .attr("xlink:href", (d)-> if d.level.indexOf(l) != -1 then "assets/img/" + img)
        .attr("class", "cat_level")
        .attr("width",  (d) -> rScale(rValue(d))  )
        .attr("height", (d) -> rScale(rValue(d))  )
        .style("transform-origin","50% 50%")
        .style("transform", (d) -> "translate(-"+ rScale(rValue(d))/2.1 +'px,-'+ rScale(rValue(d))/1.9 +'px)') 

    node
      .append("circle")
      .attr('class','bubble-opac')
      .attr("r", (d) -> Math.max(12, rScale(rValue(d))-4 ) )
      .style('fill','#fff')
      .style('opacity',0)

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
      .attr("id", (d) -> "label_" + d.ID.toString())
      .style("text-align","left")
      .call(force.drag)
      .call(connectEvents)

    labelEnter.append("div")
      .attr("class", "bubble-label-name")
      .text((d) -> textValue(d))

    #labelEnter.append("div")
    #  .attr("class", "bubble-label-value")
    #  .text((d) -> rValue(d))

    # label font size is determined based on the size of the bubble
    # this sizing allows for a bit of overhang outside of the bubble
    # - remember to add the 'px' at the end as we are dealing with 
    #  styling divs
    label
      .style("font-size", (d) -> 8 + d.forceR/5 + "px")
      #.style("font-size", (d) -> "12px")
      .style("max-width", "250px")
      .style("min-width", "80px")
      #.style("width", (d) -> Math.max(150, 2.5 * rScale(rValue(d)) + "px"))

    # interesting hack to get the 'true' text width
    # - create a span inside the label
    # - add the text to this span
    # - use the span to compute the nodes 'dx' value
    #  which is how much to adjust the label by when
    #  positioning it
    # - remove the extra span
    label.append("span")
      .text((d) -> textValue(d))
      #.each((d) -> d.dx = Math.max(2.5 * rScale(rValue(d)), this.getBoundingClientRect().width))
      .remove()

    # reset the width of the label to the actual width
    label.style("width", (d) -> d.dx + "px")
  
    # compute and store each nodes 'dy' value - the 
    # amount to shift the label down
    # 'this' inside of D3's each refers to the actual DOM element
    # connected to the data node
    label.each((d) -> d.dy = this.getBoundingClientRect().height)
    label.each((d) -> d.dx = this.getBoundingClientRect().width)

    # Hide labels
    d3.selectAll('.bubble-label').style('display','none')


  # ---
  # custom gravity to skew the bubble placement
  # ---
  gravity = (alpha) ->
    # start with the center of the display
    cx = 250 + width / 2
    cy = height / 2
    # use alpha to affect how much to push
    # towards the horizontal or vertical
    ax = 0.7 * alpha # / 8
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
  # Animate bubbles after filtering
  # ---
  root.redraw = () ->
    force.nodes(data).start()


  # ---
  # Update data
  # ---
  root.changeLevel = (new_label) ->
    # Change data
    data_id = d3.select('#active_node_id').attr('active_node_id')
    node_data = d3.select('#node_'+data_id).data()[0]

    dim_label = ['individual', 'family', 'group', 'orga', 'geographic']
   
    # Remove bubble icons
    for l in dim_label
      d3.select('#svg_icon_level_'+l+'_'+data_id).attr('href','')
    
    if new_label == node_data.level
      node_data.level = ''

    else
      node_data.level = new_label
      index_img = dim_label.indexOf(new_label) + 1

      d3.select('#svg_icon_level_'+new_label+'_'+data_id).attr('href','assets/img/icon/level_'+index_img+'_'+new_label+'.png')
   
    hashchange()
    


  root.changeGeo = (new_label) ->
    # Change data
    data_id = d3.select('#active_node_id').attr('active_node_id')
    node_data = d3.select('#node_'+data_id).data()[0]

    dim_label = ['straat','buurt','wijk','gebied','stadsdeel','stad','amstelland','adam','g4','national']
    
    # Remove bubble icons
    for l in dim_label
      d3.select('#svg_icon_geo_'+l+'_'+data_id).attr('href','')
    
    if new_label == node_data.geo
      node_data.geo = ''

    else
      node_data.geo = new_label
      index_img = dim_label.indexOf(new_label) + 1
      
      if index_img < 4
        index_img = 1
      else if index_img < 7
        index_img = 2
      else 
        index_img = 3

      d3.select('#svg_icon_geo_'+new_label+'_'+data_id).attr('href','assets/img/icon/geo_'+index_img+'.png')

    hashchange()

  root.changeDep = (new_label) ->
    # Change data
    data_id = d3.select('#active_node_id').attr('active_node_id')
    node_data = d3.select('#node_'+data_id).data()[0]

    dim_label = ['EGZ', 'IZ', 'JGZ', 'VT', 'MGGZ', 'FGMA', 'GHOR', 'LO', 'AAGG']
   
    if new_label == node_data.department
      node_data.department = ''
      d3.select('#svg_icon_dep_'+data_id).attr('fill',colors['unknown'])

    else
      node_data.department = new_label
      d3.select('#svg_icon_dep_'+data_id).attr('fill',colors[new_label])
   
    hashchange()

    d3.select('#edit_department').attr('style', 'display:none;')
    d3.select('#department-input').attr('style', 'display:block;')


  root.changeTextFields = () ->
    # Change data
    data_id = d3.select('#active_node_id').attr('active_node_id')
    node_data = d3.select('#node_'+data_id).data()[0]
    
    d3.selectAll(".edit_field").attr('contentEditable', 'false')
    document.getElementById("edit-top-bar").style.display = "none"



    

  # ---
  # adds mouse events to element
  # ---
  connectEvents = (d) ->
    d.on("click", click) # , {passive: true}
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
  root.hashchange = () ->
    id = decodeURIComponent(location.hash.substring(1)).trim()
    updateActive(id)

  # ---
  # activates new node
  # ---
  root.updateActive = (id) ->
    node.classed("bubble-selected", (d) -> id == idValue(d))
    node.classed("bubble-tone-down", (d) -> id != idValue(d))
    keywords = ''
    contact = ''
    department = ''
    name = ''
    description = ''
    publication = ''
    indic = ''
    size = ''
    population = ''
    geo = ''
    type_value = ''
    level = ''
    time = ''
    ID = ''

    # #retrieve data elements from active node
    activeNode = d3.selectAll(".bubble-selected")
                    .filter( (d) -> 
                      description = d.description.replace(' - ',' ')
                      keywords = d.keyword 
                      contact = d.contact
                      department = d.department
                      name = d.name
                      publication = d.publication
                      indic = d.indicator
                      size = d.size
                      population = d.population
                      geo = d.geo
                      type_value = d.type
                      level = d.level
                      time = d.time
                      ID = d.ID
                    )
    if(department == '-')
      dep_value = 'unknown'
    else 
      dep_value = department

    time = time.replace(/;/g,', ')
    keywords = keywords.replace(/;/g,', ')
    indic = indic.replace(/;/g,', ')

    # Check if a node is selected
    if id.length > 0 & name != ''
      d3.select("#active_node_id").attr('active_node_id',"#{ID}")
      d3.select("#title-input").html("#{name}")
      d3.select("#description-input").html("#{description}")
      d3.select("#contact-input").html("#{contact}")
      d3.select("#department-input").html("<span class='dep_circle dep_#{dep_value}'></span>#{department}")
      d3.select("#keywords-input").html("#{keywords}")
      d3.select("#indic-input").html("#{indic}")
      d3.select("#publication-input").html("#{publication}")
      d3.select("#size-input").html("#{size}")
      d3.select("#time-input").html("#{time}")

      # Make unselected nodes transparent
      d3.selectAll(".bubble-selected").selectAll('.bubble-opac').transition().duration(150).style('opacity','0')
      d3.selectAll(".bubble-tone-down").selectAll('.bubble-opac').transition().duration(150).style('opacity','0.6')

      # Fix color of pie chart    
      d3.selectAll(".bubble-selected").selectAll(".pie").transition().duration(150).attr("opacity", '1' )
      d3.selectAll(".bubble-tone-down").selectAll(".pie").transition().duration(150).attr("opacity", '0.2' )


      # Highlight dataset's features
      pop_label = ['youth','young','adult','elderly']
      for i in [1..4]
        d3.select('#label_pop_'+i)
          .classed('input_item_checked', population.includes(pop_label[i-1]))

      geo_label = ['straat','buurt','wijk','gebied','stadsdeel','stad','amstelland','adam','g4','national']
      for i in [1..10]
        d3.select('#label_geo_'+i)
          .classed('input_item_checked', geo.split(';').indexOf(geo_label[i-1]) != -1)

      type_label =  ['questionnaire', 'socialmedia', 'promotion', 'registry', 'monitor']
      for i in [1..5]
        d3.select('#label_type_'+i)
          .classed('input_item_checked', type_value.includes(type_label[i-1]))
      
      level_label = ['individual', 'family', 'group', 'orga', 'geographic']
      for i in [1..5]
        d3.select('#label_level_'+i)
          .classed('input_item_checked', level.includes(level_label[i-1]))

      dep_label = ['EGZ', 'IZ', 'JGZ', 'VT', 'MGGZ', 'FGMA', 'GHOR', 'LO', 'AAGG']
      for i in [1..9]
        d3.select('#label_dep_'+i)
          .classed('input_item_checked', department == dep_label[i-1] )

    else
      d3.select("#title-input").html("No dataset is selected")
      d3.select("#description-input").html("-")
      d3.select("#contact-input").html("-")
      d3.select("#department-input").html("-")
      d3.select("#keywords-input").html("-")
      d3.select("#indic-input").html("-")
      d3.select("#publication-input").html("-")
      d3.select("#time-input").html("-")

      d3.selectAll(".bubble-tone-down").selectAll('.bubble-opac').transition().duration(150).style('opacity','0')

      # Fix color of pie chart    
      d3.selectAll(".bubble-tone-down").selectAll(".pie").transition().duration(150).attr("opacity", '1' )

      # Hide dataset's features
      for i in [1..4]
        d3.select('#label_pop_'+i)
          .classed('input_item_checked', false)

      for i in [1..10]
        d3.select('#label_geo_'+i)
          .classed('input_item_checked', false)

      for i in [1..5]
        d3.select('#label_type_'+i)
          .classed('input_item_checked', false)

      for i in [1..5]
        d3.select('#label_level_'+i)
          .classed('input_item_checked', false)

  # ---
  # hover event
  # ---
  mouseover = (d) ->
    node.classed("bubble-hover", (p) -> p == d)
    node.classed("bubble-tone-down", (p) -> p != d)

    keywords = ''
    contact = ''
    name = ''
    description = ''
    department = ''
    publication = ''
    ID = ''
    indic = ''
    size = ''
    population = ''
    geo = ''
    type_value = ''
    level = ''
    time = ''

    # retrieve data elements from rolled node
    rolledNode = d3.selectAll(".bubble-hover")
                    .filter( (d) -> 
                      description = d.description.replace(' - ',' ')
                      keywords = d.keyword 
                      contact = d.contact
                      department = d.department
                      name = d.name
                      publication = d.publication
                      indic = d.indicator
                      ID = d.ID
                      size = d.size
                      population = d.population
                      geo = d.geo
                      type_value = d.type
                      level = d.level
                      time = d.time
                    )
    if(department == '-')
      dep_value = 'unknown'
    else 
      dep_value = department

    time = time.replace(/;/g,', ')
    keywords = keywords.replace(/;/g,', ')
    indic = indic.replace(/;/g,', ')

    d3.select("#title-input").html("#{name}")
    d3.select("#description-input").html("#{description}")
    d3.select("#contact-input").html("#{contact}")
    d3.select("#keywords-input").html("#{keywords}")
    d3.select("#indic-input").html("#{indic}")
    d3.select("#department-input").html("<span class='dep_circle dep_#{dep_value}'></span>#{department}")
    d3.select("#publication-input").html("#{publication}")
    d3.select("#size-input").html("#{size}")
    d3.select("#time-input").html("#{time}")

    # Set transparency
    d3.selectAll(".bubble-hover").classed('bubble-tone-down', false)
    d3.selectAll(".bubble-hover").selectAll('.bubble-opac').transition().duration(150).style('opacity','0')
    d3.selectAll(".bubble-hover").selectAll(".pie").transition().duration(150).attr("opacity", '1' )

    # Make unselected nodes transparent...
    d3.selectAll('.bubble-tone-down').selectAll('.bubble-opac').transition().duration(150).style('opacity','0.6')
    d3.selectAll(".bubble-tone-down").selectAll(".pie").transition().duration(150).attr("opacity", '0.2' )
    # ...except the clicked bubble
    d3.selectAll(".bubble-selected").selectAll('.bubble-opac').transition().duration(150).style('opacity','0')
    d3.selectAll(".bubble-selected").selectAll(".pie").transition().duration(150).attr("opacity", '1' )

    # Hide labels
    d3.selectAll('.bubble-label').style('display','none')

    # Show selected label
    d3.selectAll('#label_'+ID).style('display','block')

    # Highlight dataset's features
    pop_label = ['youth','young','adult','elderly']
    for i in [1..4]
      d3.select('#label_pop_'+i)
        .classed('input_item_checked', population.includes(pop_label[i-1]))

    geo_label = ['straat','buurt','wijk','gebied','stadsdeel','stad','amstelland','adam','g4','national']
    for i in [1..10]
      d3.select('#label_geo_'+i)
        .classed('input_item_checked', geo.includes(geo_label[i-1]))

    type_label = ['questionnaire', 'socialmedia', 'promotion', 'registry', 'monitor']
    for i in [1..5]
      d3.select('#label_type_'+i)
        .classed('input_item_checked', type_value.includes(type_label[i-1]))

    level_label = ['individual', 'family', 'group', 'orga', 'geographic']
    for i in [1..5]
      d3.select('#label_level_'+i)
        .classed('input_item_checked', level.includes(level_label[i-1]))

  # ---
  # remove hover class
  # ---
  mouseout = (d) ->
    # Restore bubble transparency
    node
      .classed("bubble-hover", false)
      .classed('bubble-tone-down', true)

    # Hide labels
    d3.selectAll('.bubble-label').style('display','none')

    # Restore clicked bubble (if any)
    hashchange()

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
plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)

# ---
# jQuery document ready.
# ---
root.$ ->
  # create a new Bubbles chart
  root.plot = Bubbles()

  # ---
  # function that is called when
  # data is loaded
  # ---
  display = (data) ->
    document.getElementById('data_main').innerHTML = JSON.stringify(data)
    plotData("#vis", data, plot)

  # bind change in jitter range slider
  # to update the plot's jitter
  d3.select("#jitter")
    .on "input", () ->
      plot.jitter(parseFloat(this.output.value))


  # load our data
  d3.json("http://localhost:8888/GGD_20200203/ggd/data/db_v1.php", display)
  # d3.json("https://dev.ggd.dss.cloud/api/v1.php", display)
  # d3.json('http://localhost:8888/GGD_20200203/ggd/data/data_ggd.json', display)


