


require ['scripts/InputManager','scripts/view',	'scripts/extensions'], (im,view)->
	$(document).ready -> 
		# anonyme funktion, die bei document.ready aufgerufen wird
		c = new im()
		console.log $(document), $
		$(document).keydown( (event) -> c.keydown(event))
		$(document).keyup( (event) -> c.keyup(event))
		$(document).mousedown( (event)=> c.mousedown(event))
		$(document).mouseup((event) => c.mouseup(event))
		$(document).click( (event) => c.click(event))
		$(document).mousemove( (event) => c.mousemove(event))
		$(document).blur( (event) -> c.blur(event))
		window.paper = Raphael(document.getElementById("svg"),1000,1000)

		v = new view.NoteView()		
		v2 = new view.StringView(undefined,v.children["name"].model)
		v3 = new view.NoteView()
		v3.move(200,200)
		v3.connect(v)
		
		# pfad ändern
		# path.attr("path","M100 10L90 900")

