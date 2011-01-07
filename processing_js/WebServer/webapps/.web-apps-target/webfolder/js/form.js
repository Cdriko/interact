/**
 * 
 * Copyright 2009 Dmitriy Rogatkin
 */
var formName;
var baseServURI;
var activeAutosuggestSelect;
var frameLoaded = 0;
var sequence_holder =1 ;
function addCascadeHandler(attachto, attachfor) {
	if (!document.forms[formName])
		return;
	var field = document.forms[formName][attachto];
	// alert("Attaching to :"+field);
	if (field) {
		var oldChange = field.onchange;
		field.onchange = function() {
			// alert(attachfor);
			makeGenericAjaxCall(baseServURI + "/ajax/Cascading?cascaded="
					+ attachfor, grabvalues(collecMap[attachfor]), true,
					function(resp) {
						var data = new Function("return " + resp)();
						var af = document.forms[formName][attachfor];
						if (af.type == 'select-one') {
							af.options.length = 0;
							for ( var i = 0; i < data.length; i++)
								try {
									af.options[i] = new Option(data[i].label,
											data[i].value);
								} catch (e) {
								}
						}
					});
			// prototype.onchange.call()
		};
		field.onchange.prototype.updated = attachfor;
		field.onchange.prototype.onchange = oldChange;
	}
}
function getOffsetLeft1 (el,type) {
	  var ol = el.offsetLeft;
	  while ((el = el.offsetParent) != null) {
		  if (el.nodeName != type)
			  ol += el.offsetLeft;
	    //alert('no:'+ol+', add:'+el.offsetLeft+',el:'+el.nodeName);
	  }
	  return ol;
	}

function addAutosuggestHandler(attachto) {
	if (!document.forms[formName])
		return;
	var field = document.forms[formName][attachto];
	// alert("Attaching to :"+field);
	if (field && field.type == 'text') {
		field.onkeyup = function(e) {
			makeJSONAjaxCall(baseServURI + '/ajax/Autosuggest?autosuggest='
					+ attachto, grabvalues(collecMap[attachto], attachto),
					true, function(data) {
						var af = document.forms[formName][attachto];
						if (af.type == 'text') { // do auto-suggest for text
						// only
					var x = getOffsetLeft1(af,'LABEL');
					var y = getOffsetTop(af) + af.offsetHeight;
					if (typeof (activeAutosuggestSelect) == 'undefined') {
						activeAutosuggestSelect = document
								.createElement("select");
						activeAutosuggestSelect.style.position = 'absolute';
						activeAutosuggestSelect.style.zIndex =99;
						document.body.appendChild(activeAutosuggestSelect);
						//af.parentNode.insertBefore(activeAutosuggestSelect, af);
					} else
						activeAutosuggestSelect.style.visibility = '';
					activeAutosuggestSelect.options.length = 0;
					activeAutosuggestSelect.style.left = x + 'px';
					activeAutosuggestSelect.style.top = y + 'px';
					activeAutosuggestSelect.style.width = af.offsetWidth + 'px';					
					if (data.length > 0) {
						activeAutosuggestSelect.size = Math
								.min(10, data.length);
						for ( var o in data) {
							activeAutosuggestSelect.options[o] = new Option(
									data[o].label, data[o].value);
						}
						activeAutosuggestSelect.onkeyup = function(e) {
							var keyCode = event.keyCode;

							switch (keyCode) {
							case 13:
								if (activeAutosuggestSelect
										&& activeAutosuggestSelect.selectedIndex >= 0) {
									af.value = activeAutosuggestSelect.options[activeAutosuggestSelect.selectedIndex].value;
									activeAutosuggestSelect.style.visibility = 'hidden';
									af.focus();
								}
								event.returnValue = false;
								event.cancelBubble = true;
								break;
							case 27: // escape
								// if (activeAutosuggestSelect)
								activeAutosuggestSelect.style.visibility = 'hidden';
								af.focus();
							}
						};
						activeAutosuggestSelect.onclick = function(e) {
							if (activeAutosuggestSelect
									&& activeAutosuggestSelect.selectedIndex >= 0) {
								af.value = activeAutosuggestSelect.options[activeAutosuggestSelect.selectedIndex].value;
								activeAutosuggestSelect.style.visibility = 'hidden';
								af.focus();
							}
						};
					} else
						activeAutosuggestSelect.size = 2;
				}
			});
		};

		field.onkeydown = function(e) {
			var keyCode = event.keyCode;

			switch (keyCode) {
			// Return/Enter
			case 13:
				if (typeof (activeAutosuggestSelect) != 'undefined')
					activeAutosuggestSelect.style.visibility = 'hidden';
				event.returnValue = false;
				event.cancelBubble = true;
				break;

			// Escape
			case 27:
				if (typeof (activeAutosuggestSelect) != 'undefined')
					activeAutosuggestSelect.style.visibility = 'hidden';
				event.returnValue = false;
				event.cancelBubble = true;
				break;
			// Down arrow
			case 40:
				if (activeAutosuggestSelect) {
					//if (activeAutosuggestSelect.style.visibility == 'hidden')
						//activeAutosuggestSelect.style.visibility = '';
					if (activeAutosuggestSelect.style.visibility != 'hidden') {
					activeAutosuggestSelect.focus();
					activeAutosuggestSelect.selectedIndex = 0;
					}
				}
				return false;
				break;
			}
		};
	}
}

function initCommonAutosuggestHandlers() {
	var hideDropdown = function() {
		if (activeAutosuggestSelect != undefined)
			activeAutosuggestSelect.style.visibility = 'hidden';
	};
	if (document.addEventListener) {
		document.addEventListener('click', hideDropdown, false);
	} else if (document.attachEvent) {
		document.attachEvent('onclick', hideDropdown, false);
	}
}

function grabvalues(fields, extra) {
	// alert(fields);
	var parameters = 'undefined';
	for ( var i in fields) {
		var fn = fields[i];
		parameters = addParam(parameters, fn);
	}
	if (extra != null)
		parameters = addParam(parameters, extra);
	return parameters;
}

function addParam(currentParams, fn) {
	var f1 = document.forms[formName][fn];
	var v;
	if (f1.type == 'select-one') {
		if (f1.selectedIndex >= 0)
			v = f1.options[f1.selectedIndex].value;
		else
			v = '';
	} else if (f1.type == 'select-multiple') {

	} else if (f1.type == 'password') {
		v = f1.value;
	} else if (f1.type == 'text') {
		v = f1.value;
	} else if (f1.type == 'radio') {
	} else if (f1.type == 'checkbox') {
	} else if (f1.type == 'file') {
	} else if (f1.type == 'hidden') {
		v = f1.value;
	}
	if (currentParams == 'undefined')
		currentParams = fn + '=' + encodeURIComponent(v);
	else
		currentParams += '&' + fn + '=' + encodeURIComponent(v);
	return currentParams;
}

function addAttchHandler(fn, serv) {
	var attach = getElement('$$' + fn);
	if (attach)
		attach.onclick = function() {
			uploadFile(fn, serv);
		}
}

function uploadFile(fn, serv) {
	var target = 'N' + (sequence_holder++);
	var divid = '---' + target;
	var fdiv = getElement(divid);
	if (fdiv == null) {
		if (!serv)
			serv = 'Attach';
		fdiv = document.createElement("div");
		fdiv.innerHTML = '<iframe src="'+serv+'?divid=' + divid + '&name='
				+ encodeURIComponent(fn) + '&target=' + encodeURIComponent(target) + '" name="'
				+ target + '" id="' + target + '"></iframe>';
		fdiv.id = divid;
		fdiv.style.display = 'none'
		document.body.appendChild(fdiv);
	}
	// alert("upload?");
	// attachAndUpload(target, fn);
	setInterval('checkLoaded(\'' + target + '\',\'' + fn + '\')', 500);
}

function updateUploadStatus(target, fn, mess) {
	frameLoaded = 1;
}

function attachAndUpload(target, fn) {
	// TODO forms[0] -> name of form
	frames[target].document.forms[0].browsefile.click();
	if (frames[target].document.forms[0].browsefile.value == '')
		return; // canceled
	var path = frames[target].document.forms[0].browsefile.value;
	var parts = path.split(/(\\|\/)/g);
	path = parts[parts.length-1];
	getElement('!!' + fn).innerHTML = 'Uploading /fakepath/' + path + '...';
	frames[target].document.forms[0].submit();
}

function uploadDone(fn, file, id, divid, serv) {
	document.forms[formName][fn].value = id;
	if (!serv)
		serv = 'Attach';
	getElement('!!' + fn).innerHTML = '<a href="'+serv+'?id=' + id + '">' + file
			+ '</a>';
	document.body.removeChild(getElement(divid));
	postUploadProcess(fn, file, id);
}

function checkLoaded(target, fn) {
	if (frameLoaded == 1) {
		clearInterval();
		frameLoaded = 0;
		attachAndUpload(target, fn);
	}
}

function postUploadProcess(fn, file, id) {
	
}