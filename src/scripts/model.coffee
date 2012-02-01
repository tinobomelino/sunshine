

define [], ->
	class Model
		constructor: ()->
			@_listeners = new Array()
			
		add_listener:( event, func) ->
			" add a listener function, that gets called every time event occurs
				event is a string
			"
			console.log @_listeners[event]
			if @_listeners[event] == undefined
				@_listeners[event] = new Array()
			@_listeners[event].push(func)
		remove_listener:( event, func ) ->
			
			@_listeners[event].remove(func)

		get: ()->
			" override this to get the javascript object behind the model (for example StringModel -> String"
		fire: (event, data...) ->
			console.log "fire",data...
			if @_listeners[event] != null
				for f in @_listeners[event]
					f(event,data...)

	class StringModel extends Model
		constructor: (string) ->
			@string = string
			super()

		get: () -> return @string
		set: (string, view = null) ->
			console.log "stringmodel set",view
			@string = string
			@fire("changed",string,view)

	return {Model : Model; String : StringModel}
