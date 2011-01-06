var handlerUrl;
function updateUI() {
	if (!handlerUrl || handlerUrl == '')
		handlerUrl = './ajax/Asyncupdate';
	var request = new XMLHttpRequest();
	request.open("GET", handlerUrl, true);
	request.setRequestHeader("Content-Type", "application/x-javascript;");
	request.onreadystatechange = function() {
		if (request.readyState == 4) {
			if (request.status == 200) {
				if (request.responseText) {
					//alert(request.responseText);
					// try
					var uievents = new Function("return "
							+ request.responseText)();
					for ( var i in uievents) {
						var uie = uievents[i];
						//alert(typeof uie.eventHandler + uie.eventHandler);
						//if (typeof uie.eventHandler == 'function')
						if (window[uie.eventHandler])
							try {
								window[uie.eventHandler].apply(this, uie.parameters || []);
							} catch (e) {
								alert(e);
							}
					}
				}
			} else if (request.status == 403) 
				return;
			updateUI();
		}
		
	};
	request.send(null);
}
