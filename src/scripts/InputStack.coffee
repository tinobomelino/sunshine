
define ['scripts/keynames','scripts/extensions'], (keynames,extensions) ->
	class InputEvent
		" richtiges kopieren des InputStacks geht nicht, weil events nicht kopiert werden können ... bzw. ichs nicht hinkrieg"
		constructor: (stack) ->
			@stack = new Array()

			for slot in stack.stack
				a = new Array()
				@stack.push(a)
				for event in slot
					a.push(stack.get_keycode(event))

			if stack.last_up
				@last_up = stack.get_keycode(stack.last_up)
			else
				@last_up = null
		string: ()->
			s = ""
			for code in @stack
				s += "/" +code
			return s
		readable: () ->
			s = ""
			i = 0
			for slot in @stack
				j = 0
				s+="/"
				for code in slot
					if j > 0
						s += "+"
					if code.type() == "String"
						s+= code
					else
						s += keynames(code)
					j += 1
				
				
				i += 1
			if @last_up
				s += "\\"+ keynames(@last_up)
			return s
	class InputStack
		constructor: (chord_ms=50) ->
			@stack = new Array() # stack of slots of input events
			@stack.push(new Array()) # first slot
			@last_up = null	
			@last_event = new Date().getTime()	
			@chord_ms = chord_ms
			@current_slot = -1
		contains: (event) ->
			for tuple in @stack
				for e in tuple
					if @get_keycode(e) == @get_keycode(event)
						return true
			return false
		get_keycode: (event) ->
			if event.type == "mousedown" or event.type == "mouseup"
				return 300+event.button
			else
				return event.keyCode
		
		sort_keycodes: (a,b) ->
			return @get_keycode(a)-@get_keycode(b)
		cb_keydown: (event) ->
			@last_up = null			
			if (!(@contains(event)))
				t = new Date().getTime()
				if (t - @last_event) < @chord_ms
					# chord
					# insert into last slot
					# do not report other keys in current slot as part of event
					console.log "chord"
					ret = new InputEvent(this)
					@stack[@current_slot].push(event)
					@stack[@current_slot].sort( (a,b) => @sort_keycodes(a,b))
					ret.stack[@current_slot] = new Array()
					ret.stack[@current_slot].push(@get_keycode(event))
					return ret
				else
					# no chord
					console.log "no chord", (t-@last_event)
					@current_slot += 1
					@last_event = t
					if not @stack[@current_slot]
						@stack[@current_slot] = new Array()
					@stack[@current_slot].push(event)
					return new InputEvent(this)
	
		cb_keyup: (event) ->
			console.log "keyup", @get_keycode(event)
			@last_up = event
			ret = new InputEvent(this)
			s = 0			
			for slot in @stack
				e = 0
				for ev in slot
					console.log e,ev,event,slot.length
					if @get_keycode(ev) == @get_keycode(event)
						#remove ev
						@stack[s].splice(e,1)
						if @stack[s].length == 0
							@stack.splice(s,1)
							@current_slot -=1
						break
					e+=1
				s +=1							
			#todo return event
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
			for slot in @stack
				for event in slot
					s += "/" +keynames(@get_keycode(event))
			return s


	return InputStack
