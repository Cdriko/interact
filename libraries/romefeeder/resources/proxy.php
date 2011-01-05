<?
/*
 * Copyright 2008 Obx Labs / Bruno Nadeau / Jason E. Lewis
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

header ("content-type: text/xml");

//the url
$url = $_GET['url'] . "?";

//each variable that were originally passed to the url we want to get
//are passed as variable to the proxy.
//this works around the problem of having to encode ? and & characters
//(e.g. http://www.mydomain.com/index.htm?variable1=1&variable2=2 is passed as
//      proxy.php?url=http://www.mydomain.com/index.htm&variable1=1&variable2=2)
foreach ($_GET as $key => $value)
{
	if (is_array($value)) {
		foreach($value as $subvalue) {
			$url .= "&" . $key . "[]=" . htmlentities($subvalue);
		}
	}
	else {
		$url .= "&" . $key . "=" . htmlentities($value);
	}
}

echo (file_get_contents($url));
?>