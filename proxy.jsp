<%@page session="false"%>
<%@page import="java.net.*,java.io.*" %>
<%@page trimDirectiveWhitespaces="true"%> 
<%

/**
 * This is a white list proxy that could be used the prevent an error due to 
 * JavaScript Same Origin Policy.
 * 
 * CAUTION: It might break some sites and it's a security risk because
 * people can use this proxy to browse the web and possibly do bad and/or illegal stuff
 * with it. 
 * It can load any content type.
 * This proxy implementation was inspired by the proxy.cgi script of OpenLayers
 * {@link http://openlayers.org}
 * To use this in OpenLayers you have to set OpenLayers.ProxyHost = "Url/To/This/Proxyfile/proxy.jsp?";
 * within your JavaScript code <br>
 * The base code of the proxy has been provided by SNIPPLR
 * {@link http://snipplr.com/view/17987/jsp-proxy-for-javascript-applications/}
 * 
 * @author terrestris GmbH & Co. KG
 * @author Christian Mayer
 * @author Marc Jansen
 * 
 * @license BSD see license.txt
 * 
 */
String[] allowedHosts = {
    "www.openlayers.org", "openlayers.org", 
    "labs.metacarta.com", "world.freemap.in", 
    "prototype.openmnnd.org", "geo.openplans.org",
    "sigma.openplans.org", "demo.opengeo.org",
    "www.openstreetmap.org", "sample.azavea.com",
    "v-swe.uni-muenster.de:8080", 
    "vmap0.tiles.osgeo.org"
};
HttpURLConnection con = null;
try {
	String reqUrl = request.getQueryString();
	String decodedUrl = "";
	if (reqUrl != null) {
		reqUrl = URLDecoder.decode(reqUrl, "UTF-8");
	}
	else {
		response.setStatus(400);
		out.println("ERROR 400: No target specified for proxy.");
	}

	// extract the host
	String host = "";
	host = reqUrl.split("\\/")[2];
	boolean allowed = false;
	
	// check if host (with port) is in white list
	for (String surl : allowedHosts) {
		if (host.equalsIgnoreCase(surl)) {
			allowed = true;
			break;
		}
	}
	
	// do the proxy action (load requested ressource and transport it to client)
	// if host is in white list
	if(allowed) {
		// replace the white spaces with plus in URL
		reqUrl = reqUrl.replaceAll(" ", "+"); 
		
		// call the requested ressource		
		URL url = new URL(reqUrl);
		con = (HttpURLConnection)url.openConnection();
		con.setDoOutput(true);
		con.setRequestMethod(request.getMethod());
		String reqContenType = request.getContentType();
		if(reqContenType != null) {
			con.setRequestProperty("Content-Type", reqContenType);
		}
		else {
			con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
		}

		int clength = request.getContentLength();
		if(clength > 0) {
			con.setDoInput(true);
			byte[] idata = new byte[clength];
			request.getInputStream().read(idata, 0, clength);
			con.getOutputStream().write(idata, 0, clength);	
		}
		
		// respond to client
		response.setContentType(con.getContentType());

		BufferedReader rd = new BufferedReader(new InputStreamReader(con.getInputStream()));
		String line;
		int i = 0;
		while ((line = rd.readLine()) != null) {
			out.println(line);	
		}
		rd.close();
	}
	else {
		// deny access via HTTP status code 502
		response.setStatus(502);
		out.println("ERROR 502: This proxy does not allow you to access that location.");
	}

} catch(Exception e) {
	
	// resond an internal server error with the stacktrace
	// on exception
	response.setStatus(500);
	byte[] idata = new byte[5000];

	if(con.getErrorStream() != null) {
		con.getErrorStream().read(idata, 0, 5000);
	}
	
	out.println("ERROR 500: An internal server error occured. " + e.getMessage() + " " + new String(idata));	
}
%>