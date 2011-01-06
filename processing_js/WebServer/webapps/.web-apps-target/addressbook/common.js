// $Id: common.js,v 1.2 2006/08/30 03:05:09 rogatkin Exp $
// JavaScript toll and utilities
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
  if (document.all)
      return document.all(id);
  return document.getElementById(id);           
}