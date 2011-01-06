<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Comet Weather</title>
        <SCRIPT TYPE="text/javascript">
            function go(){
                var url = "/weatherserver/Weather?random="+Math.random();
                var request =  new XMLHttpRequest();
                request.open("GET", url, true);
                request.setRequestHeader("Content-Type","application/x-javascript;");
                request.onreadystatechange = function() {
                    if (request.readyState == 4) {
                        if (request.status == 200){
                            if (request.responseText) {
                                document.getElementById("forecasts").innerHTML = request.responseText;
                            }
                        }
                        go();
                    }
                };
                request.send(null);
            }
        </SCRIPT>
    </head>
    <body>
        <h1>Rapid Fire Weather</h1>
        <input type="button" onclick="go()" value="Go!"></input>
        <div id="forecasts"></div>
    </body>
</html>
