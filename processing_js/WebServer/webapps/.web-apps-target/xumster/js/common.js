// $Id: common.js,v 1.6 2007/07/27 03:01:26 rogatkin Exp $
// JavaScript toll and utilities
// Copyright (c) 2005-2006 Dmitriy Rogatkin
// All rights reserved.

var base_url;

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
  if (document.all)
      return document.all(id);
  return document.getElementById(id);           
}

function render(url, area) {
  makeIFrameAjaxCall(base_url+url, 
      function(html) {
          getElement(area).innerHTML = html;
      });  
}

function doCommand(cmd) {
   // JSON ?
   makeIFrameAjaxCall(base_url+'Controll?submit.x=1&operation='+cmd,
     function(html) {
       // update areas
       top.frames["mainviewframe"].document.location.reload(true);
       top.frames["mainviewframe"].document.write(html);
     });
   
}

function max(a1,a2) {
  if (a1<a2)
    return a2;
  return a1;
}