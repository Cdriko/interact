var menuskin = "rightmenu_s2"; 
var display_url = 0; // Show URLs in status bar?

function showmenu(el) {
  var rightedge = document.body.clientWidth-event.clientX;
  var bottomedge = document.body.clientHeight-event.clientY;
  if (rightedge < el.offsetWidth)
    el.style.left = max(document.body.scrollLeft + event.clientX - el.offsetWidth,0);
  else
   el.style.left = document.body.scrollLeft + event.clientX;
  if (bottomedge < el.offsetHeight)
    el.style.top = document.body.scrollTop + event.clientY - el.offsetHeight;
  else
   el.style.top = document.body.scrollTop + event.clientY;
  el.style.visibility = "visible";
  return false;
}

function hidemenu(el) {
  el.style.visibility = "hidden";
}

function highlight() {
  if (event.srcElement.className == "rightmenuitems") {
    event.srcElement.style.backgroundColor = "highlight";
    event.srcElement.style.color = "white";
    if (display_url)
       window.status = event.srcElement.url;
   }
}
function lowlight() {
   if (event.srcElement.className == "rightmenuitems") {
     event.srcElement.style.backgroundColor = "";
     event.srcElement.style.color = "black";
     window.status = "";
   }
}
function jumpto() {
   if (event.srcElement.className == "rightmenuitems") {
     if (event.srcElement.getAttribute("target") != null)
        window.open(event.srcElement.url, event.srcElement.getAttribute("target"));
     else
        window.location = event.srcElement.url;
   }
}
