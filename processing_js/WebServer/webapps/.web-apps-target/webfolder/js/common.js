// $Id: common.js,v 1.6 2010/07/12 22:40:09 dmitriy Exp $
// JavaScript tool and utilities
// Copyright (c) 2005-2006 Dmitriy Rogatkin
// All rights reserved.


function submitFormOnEnter (field, evt) {
   var keyCode = evt.which ? evt.which : evt.keyCode;
   if (keyCode == 13) {
      field.form.submit();
      return false;
   } else 
      return true;
}

function getOffsetLeft (el) {
  var ol = el.offsetLeft;
  while ((el = el.offsetParent) != null)
    ol += el.offsetLeft;
  return ol;
}

function getOffsetTop (el) {
  var ot = el.offsetTop;
  while((el = el.offsetParent) != null)
   ot += el.offsetTop;
  return ot;
}

function getElement(id) {
	// TODO cache in hash
  if (document.all)
      return document.all(id);
  return document.getElementById(id);           
}

function makeArrText(up) {
  return up?'&#9660':'&#9650;';
}

function getFormField(el_name, form_name) {
	if (form_name) 
		return document.forms[form_name].elements[el_name];
	else {
		if (formName) 
			return document.forms[formName].elements[el_name];
		return document.forms[0].elements[el_name];
	}
}
function centerElement(el)  {
    var lessIE7 = window.XMLHttpRequest == null;
	  var left =  lessIE7? document.documentElement.scrollLeft : 0;
	  var top = lessIE7 ? document.documentElement.scrollTop : 0;
	  var modal_box = getElement('popup');
	  el.style.left = Math.max((left + (getWindowWidth() - el.offsetWidth) / 2), 0) + 'px';
	  el.style.top = Math.max((top + (getWindowHeight() - el.offsetHeight) / 2), 0) + 'px';
 }

function getWindowWidth() {
	var width =
		document.documentElement && document.documentElement.clientWidth ||
		document.body && document.body.clientWidth ||
		document.body && document.body.parentNode && document.body.parentNode.clientWidth ||
		0;

	return width;
}
 
function getWindowHeight() {
    var height =
		document.documentElement && document.documentElement.clientHeight ||
		document.body && document.body.clientHeight ||
  		document.body && document.body.parentNode && document.body.parentNode.clientHeight ||
  		0;
  		
  	return height;
}

function message(key) {
	// TODO use key in lookup localized message association
	if (localized_messages) {
		var mess = localized_messages[key];
		if (mess) {
			getElement('status').innerHTML = mess;
			return;
		}			
	}
	getElement('status').innerHTML = key;
}