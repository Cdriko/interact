//  This file provided usefult function for making Ajax calls
// $Id: ajaxhelper.js,v 1.2 2009/09/23 07:02:36 dmitriy Exp $

var some_URI = "http://itrevw.com/soap/";
var ajaxFrameCnt = 11;
// this call consider that parameters contains an array
// of parameters with predefined names as param1, param2, paramn
// a parameter can be array, all parameters considered string
// if payload specified then it considered in soap body as parameters part
function makeSoapAjaxCall(ws_url, method, parameters, payload, callback) {
   var envelope = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
   +"<SOAP-ENV:Envelope"+
   +"  xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\"\n"
  +"SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"\n"
  +  ' xmlns:xsi="http://www.w3.org/1999/XMLSchema-instance" \n'+
      ' xmlns:xsd="http://www.w3.org/1999/XMLSchema">\n'
  +"<SOAP-ENV:Header>\n"
  +"     <t:Transaction\n"
  +"       xmlns:t=\"some-URI\"\n"
  +"       xsi:type=\"xsd:int\" mustUnderstand=\"1\">\n"
  +"         5\n"
  +"     </t:Transaction>\n"
  +"</SOAP-ENV:Header>\n"
  +"<SOAP-ENV:Body>\n<n:"
  +method+"\n xmlns:n=\"urn:"+method+"\">\n";
  // pack parameters
  if (payload)
      envelope+=payload;
  else {
     if (parameters.length) {
        // can be recursive call like packParams(parameters, 0)
        // todo: use more robust way to figure out vector or scalar
        for (var i=0; i<parameters.length; i++) {
            if (parameters[i].length) {
               for(var k=0; k<parameters[i].length;k++)
                  envelope+='<param'+(i+1)+' xsi:type="xsd:string">'+parameters[i][k]+
                    '</param'+(i+1)+'>\n';
            } else {
               envelope+='<param'+(i+1)+' xsi:type="xsd:string">'+parameters[i]+
                    '</param'+(i+1)+'>\n';
            }
        }
     } else { 
        envelope+='<param1 xsi:type="xsd:string">'+parameters+'</param1>\n';
     }
  }
  envelope += "</n:"+method+
  '></SOAP-ENV:Body></SOAP-ENV:Envelope>';
  // todo: figure out if xmlhttp can be created just once
  var xmlhttp=false;
  /*@cc_on @*/
  /*@if (@_jscript_version >= 5)
  // JScript gives us Conditional compilation, we can cope with old IE versions.
  // and security blocked creation of the objects.
   try {
    xmlhttp = new ActiveXObject("Msxml2.XMLHTTP");
   } catch (e) {
    try {
     xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
    } catch (E) {
      xmlhttp = false;
    }
   }
  @end @*/
  if (!xmlhttp && typeof XMLHttpRequest!='undefined') {
    xmlhttp = new XMLHttpRequest();
  }
  // todo: verify that xmlhttp valid
  xmlhttp.open("POST", ws_url, true);
  xmlhttp.onreadystatechange=function() {
     if (xmlhttp.readyState==4) {
        if(callback)
          callback(xmlhttp.responseText)
     }
  }
  xmlhttp.setRequestHeader("SOAPAction", "n"+method)
  xmlhttp.setRequestHeader("MessageType", "CALL")
  xmlhttp.setRequestHeader("Content-Type", "text/xml")
  xmlhttp.send(envelope);
}

function makeGenericAjaxCall(ws_url, parameters, async, callback, errcallback) {
 try {
   var xmlhttp = getXmlHttp();
   if (parameters) {
      xmlhttp.open("POST",ws_url,async); // (method,url,async,usr,pswd)
      xmlhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
   } else
      xmlhttp.open("GET",ws_url,async);
   xmlhttp.onreadystatechange=function() {
     if (xmlhttp.readyState==4) {
       if (xmlhttp.status==200) {
          callback(xmlhttp.responseText);
       } else {
         if (errcallback)
            errcallback(xmlhttp.status, null);
         else
           alert("URL:"+ws_url+" = "+xmlhttp.status);
       }
     }
   }
   xmlhttp.send(parameters);
 } catch(e) {
     if (errcallback)
       errcallback(x-1, e);
     else
       alert("URL:"+ws_url+" = "+e);
 }
}

// [{id:"LHR",country:"GB",lat:"51.466666666667",lon:"-0.45",tz:"Europe/London",name:"London, England",shortname:"Heathrow"}]
// see details http://www.crockford.com/JSON/index.html, orr http://www.json.org
// ws_url - url to call with parameters for get
// parameters - in form name=value&name=value, name/value url encoded for post
// async - boolean type of call
// callback - a function which take a result of call as JS var evaluated from result
// errcallback - an optional function to handle errors, takes 2 parameters http response code and exception if happened
function makeJSONAjaxCall(ws_url, parameters, async, callback, errcallback) {
 try {
   var xmlhttp = getXmlHttp();
   if (parameters) {
      xmlhttp.open("POST",ws_url,async); // (method,url,async,usr,pswd)
      xmlhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
   } else
      xmlhttp.open("GET",ws_url,async);
   xmlhttp.onreadystatechange=function() {
     if (xmlhttp.readyState==4) {
       if (xmlhttp.status==200) {
          var local=new Function("return "+xmlhttp.responseText)();
          callback(local);
       } else {
         if (errcallback)
            errcallback(xmlhttp.status, null);
         else
           alert("URL:"+ws_url+" = "+xmlhttp.status);
       }
     }
   }
   xmlhttp.send(parameters);
 } catch(e) {
     if (errcallback)
       errcallback(x-1, e);
     else
       alert("URL:"+ws_url+" = "+e);
 }
}

function nextUniqueId() {
   return "dr_ajax"+ajaxFrameCnt++;
}

function makeIFrameAjaxCall(ws_url, callback, errorCalBack) {
    var targetFrame = document.createElement("IFRAME");
    var IE = (navigator.appName.indexOf("Microsoft") >= 0);
    targetFrame.id = nextUniqueId();
    targetFrame.style.display = "none";  
    if(IE){
	document.appendChild(targetFrame);
    } else {
	document.body.appendChild(targetFrame);
    }//end if
		
    targetFrame.src = ws_url;
    try {
      if(IE){
  	targetFrame.onreadystatechange = function(){
  	    if(this.readyState == "complete"){
  		callback(document.frames[targetFrame.id].document.body.innerHTML);
		document.removeChild(targetFrame);
	     }//end if
	};
      } else {
 	targetFrame.addEventListener("load", function(){
		callback(document.getElementById(targetFrame.id).contentDocument.body.innerHTML);
			document.body.removeChild(document.getElementById(targetFrame.id));
		}, false);
      }//end if
    }catch(e) {
      if (errorCallbakc)
         errorCallbakc(e);
    }
}

// note method has to be set by a caller
function makeIFrameAjaxSubmit(ws_url, form, type, callback, errorcallback, iframename) {
    var IE = (navigator.appName.indexOf("Microsoft") >= 0);
    var origTar = form.target;
    var origAction = form.action;
    var targetFrame;
    if (iframename == "" && IE == false) {
      targetFrame = document.createElement("IFRAME");
      targetFrame.name = nextUniqueId();
      targetFrame.id = targetFrame.name;
      //targetFrame.setAttribute('name', nextUniqueId());
      //targetFrame.style.display = "none"; 
      targetFrame.style.width ="0px";  
      targetFrame.style.height = "0px";
      targetFrame.style.border = "0px"
      if(IE){ // never called
  	        document.appendChild(targetFrame);
      } else {
 	         document.body.appendChild(targetFrame);
      }//end if
      form.target = targetFrame.id;
    } else {
      targetFrame = document.getElementById(iframename);
      form.target = iframename;
    }
    form.action = ws_url;
    
    if ("p" == type)
        form.encoding = "text/plain";
    else if("m" == type)
        form.encoding = "multipart/form-data";
    form.submit();

    try {
	    if(IE){
		targetFrame.onreadystatechange = function(){
		    if(this.readyState == "complete"){
        	        form.target = origTar;
	                form.action = origAction;
        	       	callback(document.frames[targetFrame.id].document.body.innerHTML);
	                if (iframename == "")
   			   document.removeChild(targetFrame);
		     }//end if
		};
	    } else {
		targetFrame.addEventListener("load", function(){
        	        form.target = origTar;
	                form.action = origAction;
			callback(document.getElementById(targetFrame.id).contentDocument.body.innerHTML);
	                if (iframename == "") // TODO use delayed remove
				document.body.removeChild(document.getElementById(targetFrame.id));
 			}, false);
	    }//end if
   }catch(e) {
     if (errorcallback)
       errorcallback(e);
      else
        alert("An exception in iframe ("+ws_url+") submit: "+e);
   }
}

function getXmlHttp() {
  var xmlhttp=false;
  /*@cc_on @*/
  /*@if (@_jscript_version >= 5)
  // JScript gives us Conditional compilation, we can cope with old IE versions.
  // and security blocked creation of the objects.
   try {
    xmlhttp = new ActiveXObject("Msxml2.XMLHTTP");
   } catch (e) {
    try {
     xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
    } catch (E) {
      xmlhttp = false;
    }
   }
  @end @*/
  if (!xmlhttp && typeof XMLHttpRequest!='undefined') {
    xmlhttp = new XMLHttpRequest();
  }
  return xmlhttp;
}

function formValues2String(form) {	
	var res = "";
	for ( var i=0; i<form.elements.length; i++) {
		var el = form.elements[i];
		if (el.type) {
			var value = null;

			if (el.type == 'text' || el.type == 'textarea'
					|| el.type == 'password' || el.type == 'file'
					|| el.type == 'button' || el.type == 'reset'
					|| el.type == 'submit') {
				if (el.disabled == false)
					value = el.value;
			} else if (el.type == 'hidden') {
				value = el.value;
			} else if (el.type == 'radio' || el.type == 'checkbox') {
				if (el.disabled && el.defaultChecked || el.disabled == false
						&& el.checked)
					value = el.value;
			} else if (el.type == 'select-one') {
				if (el.disabled == false)
					if (el.selectedIndex >= 0)
						value = el.options[el.selectedIndex].value;
			} else if (el.type == 'select-multiple') {
				if (el.disabled == false)
					for ( var o in el.options)
						if (o.disabled == false && o.selected) {
							res += el.name + '=' + encodeURIComponent(o.value)
									+ '&';
						}
			}
			if (value) {
				res += el.name + '=' + encodeURIComponent(value) + '&';
			}
		}
	}
	return res;
}
