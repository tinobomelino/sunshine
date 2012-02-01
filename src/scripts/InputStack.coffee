
define ['scripts/keynames','scripts/extensions'], (keynames,extensions) ->
	class InputEvent
		" richtiges kopieren des InputStacks geht nicht, weil events nicht kopiert werden können ... bzw. ichs nicht hinkrieg"
		constructor: (stack) ->
			@stack = new Array()
			for event in stack.stack
				if event.type == "mousedown"
					@stack.push("button"+event.button)
				else
					@stack.push(event.keyCode)
			if stack.last_up
				@last_up = stack.last_up.keyCode
			else
				@last_up = null
		string: ()->
			s = ""
			for code in @stack
				s += "/" +code
			return s
		readable: () ->
			s = ""
			for code in @stack
				if code.type() == "String"
					s+= "/"+code
				else
					s += "/" +keynames(code)
			if @last_up
				s += "\\"+ keynames(@last_up)
			return s
	class InputStack
		constructor: () ->
			@stack = new Array() # stack of input events
			@last_up = null			
		contains: (event) ->
			for e in @stack
				if @get_keycode(e) == @get_keycode(event)
					return true
			return false
		get_keycode: (event) ->
			if event.type == "mousedown" or event.type == "mouseup"
				return "button"+event.button
			else
				return event.keyCode
		index: (keycode) ->
			i = 0
			for event in @stack			
				if @get_keycode(event) == @get_keycode(keycode)
					return i
				i+=1
			return -1		
		cb_keydown: (event) ->
			@last_up = null
			if (!(@contains(event)))
				@stack.push(event)
			return new InputEvent(this)
	
		cb_keyup: (event) ->
			console.log "keyup", @get_keycode(event)
			@last_up = event
			ret = new InputEvent(this)
			
			if @contains(event)
				i = @index(event)
				@stack.splice(i,1)
			return ret

		cb_blur: (event) ->
			" window gets out of focus, if this happens via alt+tab (or another way where keys remain pressed), these keys will be stuck"
			@stack = new Array()
			

		string: ()->
			s = ""
			for event in @stack
				s += "/" +event.keyCode
			return s
		readable: () ->
			s = ""
			for event in @stack
				console.log "readable",event.type
				if event.type == "mousedown"
					s+= "/button"+event.button
				else
					s += "/" +keynames(event.keyCode)
			return s


	return InputStack
