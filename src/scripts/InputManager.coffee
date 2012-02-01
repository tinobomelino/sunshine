# block context menu: http://stackoverflow.com/questions/6789843/disable-right-click-menu-in-chrome

define ['scripts/view','scripts/InputStack'],(view,InputStack) ->
	class InputManager
		constructor: ->
			@selected = null # currently selected view (as in view.coffee, not as in dom)
			@grabbing = null
			@stack = new InputStack()
			console.log this
			@mouse_x = 0
			@mouse_y = 0
		blur: (event) ->
			@stack.cb_blur()
			console.log " BLUR"
		keyup: (event) ->
			ievent = @stack.cb_keyup(event)
			@input(ievent,event)
		keydown: (event) ->	
			ievent = @stack.cb_keydown(event)
			@input(ievent,event)
		mousedown: (event) ->	
			sel = $(event.target)
			console.log "mousedown",sel,event	
			ievent = @stack.cb_keydown(event)
			console.log "im:",ievent,ievent.readable()		
			if sel.hasClass("grab")
				v = view.View.get_view(sel)
				console.log "grabbing", v
				@grabbing = v	
				console.log "grab",v
				event.preventDefault()
				return false
			else	
				#@input(event)
			
		mousemove: (event) ->
			@mouse_x = event.clientX
			@mouse_y = event.clientY
			if @grabbing
				x = event.clientX
				y = event.clientY
				dom = @grabbing.get_grabdom()
				dom.css("left",x)
				dom.css("top",y)
				@grabbing.cb_moved()
				event.preventDefault()
			return false
			
		input: (stack,event) ->
			console.log "input", stack.readable()
			if stack and stack.readable() == "/E/N"
				# new note, /ctrl/N doesnt work in chrome
				console.log "new note"
				n = new view.NoteView()
				n.move(@mouse_x,@mouse_y)	
				console.log "new note"			
				event.preventDefault()
				return false
			else if stack and stack.readable() == "/ctrl/S"
				console.log "trying to send something"
				socket = io.connect('http://localhost:50008')
				socket.on 'connect', () ->
					console.log("socket connect")
					socket.emit('my other event', { my: 'data' })
				event.preventDefault()
				return false
			sel = $(event.target) # event is type object
			v = this.get_view(sel)
			if (v)
				if @selected
					@selected.selected(false)
				v.selected(true)
				@selected = v
				v.input(event)
			return true
		click: (event) ->
			" click wird nach mouseup gesendet "
			if @selected
				event.preventDefault()
				return false
			else
				#@input(event)
		mouseup: (event) ->
			if @grabbing != null
				@grabbing = null
				console.log "deselected",this,@grabbing
			event.preventDefault()
			sel = event.target;
			ievent = @stack.cb_keyup(event)
			console.log "im:",ievent,ievent.readable()	
			#@input(event)
		get_view: (dom)->
			id = Number(dom.attr("id"))	
			return view.View.views[id]

	return InputManager
