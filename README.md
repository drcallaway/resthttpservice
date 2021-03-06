# REST Client for Flex

The current Flex HTTPService component is severely lacking when it comes to making REST calls. This component can only send GET and POST requests (no PUT, DELETE, HEAD, or OPTIONS without using a proxy) and does not make available the HTTP status code returned in the response. Rather, it fires a fault event for any HTTP response that does not have a status code of 200 (even a 201 "created" status is considered a fault condition).

The aim of this project is to create a fully REST-aware component called RestHttpService that can serve as a replacement to the existing HTTPService.

Keep in mind that the RestHttpService component is restricted by the same cross-domain security rules as HTTPService. That is, a Flex application that uses the RestHttpService component can only make calls back to the server from which it was downloaded (unless deployed as an AIR application). If you can't serve the REST client from the same server that hosts the REST service, the simplest way around this Flash security restriction is to add the client's domain to a crossdomain.xml file that is placed in the root of the REST service server. This file notifies the Flash runtime on the client machine that the REST service will accept requests from the client's domain.

The original code archive is available [here](https://code.google.com/archive/p/resthttpservice/).
