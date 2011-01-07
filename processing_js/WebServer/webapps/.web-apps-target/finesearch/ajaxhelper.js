//  This file provided usefult function for making Ajax calls
// $Id: ajaxhelper.js,v 1.4 2007/02/26 05:22:01 rogatkin Exp $

var some_URI = "http://searchdir.sf.net/soap/";
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
// see details http://www.crockford.com/JSON/index.html
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
                setTimeout( function() {
			document.body.removeChild(document.getElementById(targetFrame.id));
                  }, 900);
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
      if(IE){
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
                           setTimeout( function() {
				document.body.removeChild(document.getElementById(targetFrame.id));
                            }, 900);
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
   var l = form.length;
   var res = "";
   for(var i=0; i<l; i++) 
      res+=form.elements(i).name+'='+escape(form.elements(i).value)+'&';
   return res;
}