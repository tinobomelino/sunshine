" View "

define ['scripts/model'],(model) ->
	class View
		# klassenvariable soll id->view mapping speichern
		View.views = new Array()
		View.id = 0
		@get_id: ->
			View.id += 1
			return View.id
		@get_view: (dom) ->
			id = Number(dom.attr("id"))
			return View.views[id]
		constructor: (parent=null)->
			@parent = parent
			@children = new Array() # children of class View
			@id = View.get_id()
			@dom = $('<div id="'+@id+'" class="view"></div>')
			@_selected = false	
			#@dom.style.left = 0
			#@dom.style.top = 200
			View.views[@id] = this
			if (parent == null)
				$("body").append(@dom)
			#console.log sprintf.sprintf("my id%i",@id)
		input: (stack) ->
			" input event as keystack format"
			console.log("view input")
			console.log(stack)

			console.log @relative(stack)
		relative: (event) ->
			"relative coords of an event "
			offset = @dom.offset()
			x = event.clientX - offset.left
			y = event.clientY - offset.top
			return [x,y]
		add: (name, view) ->
			" add a view as child to this view "
			console.log "input"+view
			@children[name] = view
			@dom.append(view.dom)
			
		selected: (sel=null)->
			" inputmanager selects view "
			if sel == null
				return @_selected
			else
				@_selected = sel
				if @_selected
					console.log "selecting", this
					@dom.addClass("selected")
				else
					@dom.removeClass("selected")
		move: (x,y) ->
			@dom.css("top",y)
			@dom.css("left",x)
		get_grabdom: () ->
			" dom thats supposed to move when dragged"
			return @dom

	class Cursor extends View
		constructor: (parent=null) ->
			super(parent)
			@dom.addClass("cursor")
			
	class StringView extends View
		constructor: (parent=null, string = null) ->
			if string.type() == "String"
				@set_model( new model.String(string))
			else 
				@set_model( string or new model.String("stringmodel"))
			super(parent)
			@dom.empty().append(@model.get())
			@dom.attr("contentEditable",true)
			@dom.width(200)
			#@dom.bind 'textchange', (event,previous) -> @textchange(event,previous)
			#@dom.on 'blur', @textchange
			@dom.on 'DOMCharacterDataModified', (event) => @cb_textchange(event)
		set_model: (model) ->
			#todo deconnect old model		
			console.log "stringview set model",model
			@model = model
			@model.add_listener("changed", (event,string,view) => this.cb_model_changed(event,string,view)) # keep this-keyword
			
		cb_model_changed: (event, string, view)->
			if view == this
				console.log "string changed by myself"
			else
				@set(string)
					
		cb_textchange: (event) ->
			console.log "textchange",this			
			@model.set($(event.target).text(),this) # notifiy stringmodel
		set: (string) ->
			@dom.empty()
			@dom.append(string)		
		input: (stack) ->
			return true
		
	class NoteView extends View
		# view für eine Notiz
		constructor: (parent = null) ->
			super(parent)
			@add("grab",new Grab(this))
			@add("name",new StringView(this, "my string"))
			@add("content", new StringView(this,"mycontent"))
			@dom.addClass("absolute") # in order to move it around
			@dom.addClass("note")
			@dom.addClass("grab")
			# also posible:
			@dom.css("top",100)
			@dom.css("left",100)
			#@dom.offset({top: 100, left:100}) # gibt fehler b.replace is not a function ?
			@paths = new Array() # später eigene klasse
		connect: (v) ->
			" connect with another view"
			offset = @dom.offset()
			voffset = v.dom.offset()
			p = "M"+offset.left+" "+offset.top+"L"+voffset.left+" "+voffset.top
			path = window.paper.path(p)
			@paths.push([v,path])
			v.paths.push([this,path])
		cb_moved: () ->
			console.log "CB MOVED",this,@dom
			for elem in @paths
				v = elem[0]
				path = elem[1]
				console.log v,path
				offset = @dom.offset()
				voffset = v.dom.offset()
				p = "M"+offset.left+" "+offset.top+"L"+voffset.left+" "+voffset.top
				path.attr("path",p)

	class Grab extends View
		" grab something to move it "
		constructor: (parent, grab = undefined) ->
			if grab == undefined
				grab = parent
			
			super(parent)
			@grab = grab
			@dom.addClass("grab")
		get_grabdom: () -> @grab.dom
	return { View : View; NoteView : NoteView; StringView:StringView}
	
