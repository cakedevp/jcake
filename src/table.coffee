jcakedev.plugins.table =
  pluginManager: null

  init: (pm) ->
    @pluginManager = pm
    me = @

    $.fn.cakeTable = (args...) ->
      if typeof args[0] is "string"
        action = args[0]

        switch action
          when "getSelected"
            console.log "Not implemented yet"
          when "setData"
            me.setData @, args[1]
          else
            console.log "'#{action}' is not a valid action for cakeTable"
      else
        me.create @, if typeof args[0] is "object" then args[0] else {}
      
      @

  create: ($elements, params) ->
    me = @

    fields = if params.fields? then params.fields else []
    fieldNames = if params.fieldNames? then params.fieldNames else {}
    data = if params.data? then params.data else []
    maxRecords = if params.maxRecords? then params.maxRecords else 20
    formats = if params.formats? then params.formats else {}
    selectable = if params.selectable? then params.selectable else no
    editable = if params.editable? then params.editable else no
    erasable = if params.erasable? then params.erasable else no
    emptyMessage = if params.emptyMessage? then params.emptyMessage else "..."

    $elements.each ->
      table = new Table $(@), fields, fieldNames, data, maxRecords, formats, selectable, editable, erasable, emptyMessage
      me.pluginManager.addComponent table

  setData: ($obj, data) ->
    if data instanceof Array
      for i in [0...$obj.length]
        table = @pluginManager.getComponent $obj.eq(i)
        table.setData(data) if table?

class Table
  constructor: (@el, @fields, @fieldNames, @data, @maxRecords, @formats, @selectable, @editable, @erasable, @emptyMessage) ->
    @currentPage = 0
    @el.addClass "-cakedev-table"

    $wrapper = $ "<div class='-cakedev-table-wrapper' />"
    $records = $ "<table class='-cakedev-table-records' />"
    $pages = $ "<div class='-cakedev-table-pages' />"

    $wrapper.append $records
    $wrapper.append "<div class='-cakedev-table-loading' />"
    $wrapper.append "<div class='-cakedev-table-message'>#{@emptyMessage}</div>"
    @el.append $wrapper
    @el.append $pages

    @setRecords()

  setData: (data) ->
    @data = data
    @setRecords()

  clear: ->
    setData []

  

  getValueWithFormat: (field, value) ->
    if typeof @formats[field] is "function"
      valueWithFormat = @formats[field].call value, value
      value = valueWithFormat if valueWithFormat?
    
    if value? then value else ""

  setRecords: ->
    $records = @el.find ".-cakedev-table-records"
    $records.empty()

    @setHeaders()

    if @data.length
      start = @currentPage * @maxRecords
      end = start + @maxRecords

      for i in [start...end]
        if i >= @data.length
          break

        $record = $ "<tr />";
        $record.append "<td class='-cakedev-table-recordActions' />"

        for field in @fields
          value = @getValueWithFormat field, @data[i][field]

          $record.append "<td>#{value}</td>"

        $records.append $record

      $records.find("tr:last td").css "border", "none"
    else
      @el.children "-cakedev-table-wrapper"

    @setPages()

    if @data.length
      @setSelectable() if @selectable
      @setEditable() if @editable
      @setErasable() if @erasable

  setHeaders: ->
    $headers = $ "<tr />"
    $headers.append "<th />"

    for field in @fields
      fieldName = if @fieldNames[field]? then @fieldNames[field] else field
      $headers.append "<th>#{fieldName}</th>"

    @el.find(".-cakedev-table-records").append $headers

  setPages: ->
    me = @
    $pages = @el.children ".-cakedev-table-pages"
    $pages.empty()

    pagesCount = Math.ceil(@data.length / @maxRecords)

    for i in [0...pagesCount]
      $page = $ "<a class='-cakedev-table-page' href='#'>#{i + 1}</a>"
      $page.data "pageIndex", i

      $page.on "click", ->
        index = $(@).data "pageIndex"
        if index isnt me.currentPage
          me.setPage index
        no
      
      $pages.append $page

    $pages.children(".-cakedev-table-page").eq(@currentPage).addClass "-cakedev-table-currentPage"

    if @data.length
      @setNavigationControls()
      @setInfo()

  setNavigationControls: ->
    me = @
    $pages = @el.children ".-cakedev-table-pages"

    $previous = $ "<a href='#'>&laquo; Anterior</a>"
    $next = $ "<a href='#'>Siguiente &raquo;</a>"
    $beginning = $ "<a href='#'>Ir al inicio</a>"
    $end = $ "<a href='#'>Ir al final</a>"

    lastPage = Math.ceil(@data.length / @maxRecords) - 1
    lastPage = 0 if lastPage < 0

    $previous.on "click", ->
      me.setPage(me.currentPage - 1) if me.currentPage > 0
      no
    $beginning.on "click", ->
      me.setPage 0
      no
    $next.on "click", ->
      me.setPage(me.currentPage + 1) if me.currentPage < lastPage
      no
    $end.on "click", ->
      me.setPage lastPage
      no

    $pages
      .prepend($end)
      .prepend($next)
      .prepend($previous)
      .prepend($beginning)

  setInfo: ->
    beginning = @currentPage * @maxRecords
    end = beginning + @maxRecords
    end = @data.length if end > @data.length

    @el.children(".-cakedev-table-pages").append "<span class='-cakedev-table-info'>Mostrando #{beginning + 1} a #{end} de #{@data.length}</span>"

  setPage: (index) ->
    @currentPage = index
    @setRecords()

  setSelectable: ->
    no

  setEditable: ->
    $actions = @el.find(".-cakedev-table-records").find ".-cakedev-table-recordActions"
    
    for i in [0...$actions.length]
      $actions.eq(i).append "<span class='-cakedev-table-action -cakedev-edit-icon' />"

  setErasable: ->
    $actions = @el.find(".-cakedev-table-records").find ".-cakedev-table-recordActions"
    
    for i in [0...$actions.length]
      $actions.eq(i).append "<span class='-cakedev-table-action -cakedev-trash-icon' />"

  setLoading: ->


  removeLoading: ->

