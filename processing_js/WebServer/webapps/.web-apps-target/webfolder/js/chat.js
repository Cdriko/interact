// TODO convert in chat support object
// maintain internal members with chat box element ids
var chatBox;

var participant;
var originator = 'me'; // TODO localize
// / call back methods
function initiateChat(p, id, o) {
	participant = p;
	if (o)
		originator = o;
	var chat = getElement('chat_frame');
	chat.style.display = '';
	// alert("chat with "+p);
	getElement('chat_mes').focus();
}

function chatMessage(p, id, msg) {
	var chat = getElement('chat_area');
	var newMes = document.createElement('DIV');
	// newMes.id = ..
	newMes.style.width = '100%';
	newMes.innerHTML = '<div style="display:inline;color:#227734;font-weight:900">'
			+ p
			+ '</div>'
			+ '<div style="display:inline;text-indent:1em">&nbsp;'
			+ msg
			+ '</div>';
	chat.appendChild(newMes);
	newMes.scrollIntoView();
}

// / chat methods
function closeChat(p, id) {
	var chat = getElement('chat_frame');
	chat.style.display = 'none';

}

function processMesKey(mesarea) {
	if (event.keyCode == 13) {
		sendMessage(mesarea.value);
		mesarea.value = '';
	}
}

function openChat(o, p) {
	makeGenericAjaxCall(
			'Chat/ajax/initiate?participant=' + encodeURIComponent(p), null,
			true, function(resp) {
				if (resp == 'ok')
					initiateChat(p, null, o);
			});
}

function sendMessage(mes, id) {
	makeGenericAjaxCall('Chat/ajax/message?participant='
			+ encodeURIComponent(participant) + '&message='
			+ encodeURIComponent(mes), null, true, function(resp) {
		if (resp == 'ok')
			chatMessage(originator, id, mes);
	});
}

function addAvailable() {
	makeGenericAjaxCall('Chat/ajax/available', null, true, function(resp) {
		if (resp == 'ok')
			;
	});
}

function removeAvailable() {
	makeGenericAjaxCall('Chat/ajax/unavailable', null, true, function(resp) {
		if (resp == 'ok')
			;
	});
}