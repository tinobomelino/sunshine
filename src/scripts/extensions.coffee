define [], ->
	Array.prototype.remove_key = (from, to) ->
			rest = this.slice((to || from) + 1 || this.length)
			this.length = from < 0 ? this.length + from : from
			@push.apply(this, rest)

	Object.prototype.type = () ->
		obType = String(this.constructor).match(/function\s+(\w+)/)
		if (obType)
			return obType[1];
		return "undefined"

	deepCopy = (obj) ->
		if Object.prototype.toString.call(obj) == '[object Array]'
			out = []
			for value in obj
				out[_i] = arguments.callee(obj[_i])
			return out
		else
			out = {}
			console.log "copy object", obj
			for i in obj
				console.log _i,i
				out[_i] = arguments.callee(obj[_i])
			return out
  
   
	Array.prototype.contains = (obj) ->
		for key in this
			item = this[key]
			if (obj == item)
				return true
		return false

	return { deepCopy : deepCopy }
		

