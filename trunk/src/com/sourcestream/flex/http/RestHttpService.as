/*
 * The MIT License
 *
 * Copyright (c) 2008
 * Dustin R. Callaway
 * http://www.sourcestream.com/
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package com.sourcestream.flex.http
{
    import mx.utils.StringUtil;
    import flash.events.EventDispatcher;
    import flash.events.ProgressEvent;
    import flash.events.Event;
    import flash.net.Socket;

    // result event is fired when the web service's response is received
    [Event(name="result", type="com.sourcestream.flex.http.HttpEvent")]

    /**
     * Similar to Flex's HTTP service component but adds support for all HTTP methods.
     */
    public class RestHttpService extends EventDispatcher
    {
        public static const EVENT_DATA_RECEIVED:String = "result";

        public static const METHOD_GET:String = "GET";
        public static const METHOD_POST:String = "POST";
        public static const METHOD_PUT:String = "PUT";
        public static const METHOD_DELETE:String = "DELETE";
        public static const METHOD_HEAD:String = "HEAD";
        public static const METHOD_OPTIONS:String = "OPTIONS";

        private static const DAYS:Array = new Array("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat");
        private static const MONTHS:Array = new Array("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep",
                "Oct", "Nov", "Dec");

        private var socket:Socket;
        private var _host:String;
        private var _port:String;
        private var _method:String;
        private var _path:String;
        private var _body:String;
        private var _contentType:String;

        /**
         * Constructs a new REST HTTP service object.
         *
         * @param host Web service provider to which this class should connect
         * @param port Port on which to connect to the host
         */
        public function RestHttpService(host:String=null, port:String=null)
        {
            createSocket();
            _host = host;
            _port = port;
        }

        /**
         * Gets the address of the web service provider.
         *
         * @return Web service provider
         */
        public function get host():String
        {
            return _host;
        }

        /**
         * Sets the address of the web service provider.
         *
         * @param host Web service provider
         */
        public function set host(host:String):void
        {
            _host = host;
        }

        /**
         * Gets the port on which the web service provider is listening.
         *
         * @return Port on web service provider
         */
        public function get port():String
        {
            return _port;
        }

        /**
         * Sets the port on which the web service provider is listening.
         *
         * @param port Port on web service provider
         */
        public function set port(port:String):void
        {
            _port = port;
        }

        /**
         * Gets the HTTP method to be used by this service (GET, POST, PUT, DELETE, HEAD, OPTIONS).
         *
         * @return HTTP method
         */
        [Inspectable(defaultValue="GET", enumeration="GET,POST,PUT,DELETE,HEAD,OPTIONS")]
        public function get method():String
        {
            return _method;
        }

        /**
         * Sets the HTTP method to be used by this service (GET, POST, PUT, DELETE, HEAD, OPTIONS).
         *
         * @param method HTTP method
         */
        public function set method(method:String):void
        {
            _method = method;
        }

        /**
         * Gets the path to the resource (minus the host and port information).
         *
         * @return Path to resource
         */
        public function get path():String
        {
            return _path;
        }

        /**
         * Sets the path to the resource (minus the host and port information).
         *
         * @param path Path to resource
         */
        public function set path(path:String):void
        {
            _path = path;
        }

        /**
         * Gets the content type of the request body.
         *
         * @return Content type of the request
         */
        public function get contentType():String
        {
            return _contentType;
        }

        /**
         * Sets the content type of the request body.
         *
         * @param contentType Content type of the request
         */
        public function set contentType(contentType:String):void
        {
            _contentType = contentType;
        }

        /**
         * Creates a socket and adds CONNECT and SOCKET_DATA event listeners.
         */
        private function createSocket():void
        {
            if (socket == null && _host != null && _port != null)
            {
                socket = new Socket();
                socket.addEventListener(Event.CONNECT, connectHandler);
                socket.addEventListener(ProgressEvent.SOCKET_DATA, dataHandler);
            }
        }

        /**
         * Performs a GET operation.
         *
         * @param path Path to resource on which to perform the GET
         */
        public function doGet(path:String):void
        {
            sendRequest(METHOD_GET, path);
        }

        /**
         * Performs a POST operation.
         *
         * @param path Path to resource on which to perform the POST
         */
        public function doPost(path:String, body:String):void
        {
            sendRequest(METHOD_POST, path, body);
        }

        /**
         * Performs a PUT operation.
         *
         * @param path Path to resource on which to perform the PUT
         */
        public function doPut(path:String, body:String):void
        {
            sendRequest(METHOD_PUT, path, body);
        }

        /**
         * Performs a DELETE operation.
         *
         * @param path Path to resource on which to perform the DELETE
         */
        public function doDelete(path:String):void
        {
            sendRequest(METHOD_DELETE, path);
        }

        /**
         * Performs a HEAD operation.
         *
         * @param path Path to resource on which to perform the HEAD
         */
        public function doHead(path:String):void
        {
            sendRequest(METHOD_HEAD, path, _body);
        }

        /**
         * Performs a OPTIONS operation.
         *
         * @param path Path to resource on which to perform the OPTIONS
         */
        public function doOptions(path:String, body:String=""):void
        {
            sendRequest(METHOD_OPTIONS, path, body);
        }

        /**
         * Called by the client to initiate sending a request.
         *
         * @param body Body of request
         */
        public function send(body:String=null):void
        {
            _body = body;
            createSocket();
            socket.connect(_host, parseInt(_port));
        }

        /**
         * Called internally to initiate sending a request.
         *
         * @param method HTTP method
         * @param path Path to resource
         * @param body Request body
         */
        private function sendRequest(method:String, path:String, body:String=""):void
        {
            createSocket();
            socket.connect(_host, parseInt(_port));

            _method = method;
            _path = path;
            _body = body;
        }

        /**
         * Handler for the socket's CONNECT event.
         *
         * @param event CONNECT event
         */
        private function connectHandler(event:Event):void
        {
            var requestLine:String = _method + " " + _path + " HTTP/1.0\n";

            var now:Date = new Date();
            var headers:String = "Date: " + DAYS[now.day] + ", " + now.date + " " + MONTHS[now.month] + " " +
                now.fullYear + " " + now.hours + ":" + now.minutes + ":" + now.seconds + "\n";

            if (_contentType != null)
            {
                headers += "Content-Type: " + _contentType + "\n";
            }

            if (_body != null)
            {
                headers += "Content-Length: " + _body.length + "\n";
            }

            socket.writeUTFBytes(requestLine + headers + "\n" + _body);
            socket.flush();
        }

        /**
         * Handler for the socket's SOCKET_DATA event.
         *
         * @param event SOCKET_DATA event
         */
        private function dataHandler(event:ProgressEvent):void
        {
            var rawResponse:String = socket.readUTFBytes(event.bytesLoaded);
            var lines:Array = rawResponse.split("\n");

            var isFirstLine:Boolean = true;
            var isBody:Boolean = false;
            var statusCode:int;
            var statusMessage:String;
            var headers:Object = new Object();
            var body:String;

            for each (var line:String in lines)
            {
                if (isFirstLine)
                {
                    var startStatusCode:int = line.indexOf(" ");
                    var endStatusCode:int = line.indexOf(" ", startStatusCode+1);
                    statusCode = parseInt(line.substr(startStatusCode, endStatusCode));
                    statusMessage = StringUtil.trim(line.substr(endStatusCode+1));
                    isFirstLine = false;
                }
                else if (StringUtil.trim(line) == "")
                {
                    isBody = true; // blank line separates headers from body
                }
                else if (isBody)
                {
                    body += line;
                }
                else // headers
                {
                    var colonIndex:int = line.indexOf(":");
                    var headerName:String = line.substr(0, colonIndex);
                    var headerValue:String = line.substr(colonIndex+1);
                    headers[headerName] = StringUtil.trim(headerValue);
                }
            }

            var httpEvent:HttpEvent = new HttpEvent(EVENT_DATA_RECEIVED);
            httpEvent.data = rawResponse;
            httpEvent.response = new HttpResponse(statusCode, statusMessage, headers, body);
            dispatchEvent(httpEvent);
        }
    }
}