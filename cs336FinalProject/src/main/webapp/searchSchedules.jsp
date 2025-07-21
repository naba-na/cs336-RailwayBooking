<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page language="java" %>
<%@ page import="java.io.*,java.util.*,java.sql.*,java.time.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
<% 
bookingDB db = new bookingDB();
Connection conn = db.getConnection();

String origin = request.getParameter("origin");
String destination = request.getParameter("destination");
String date = request.getParameter("date");



String findStations = "SELECT o.station_id, d.station_id FROM stations o, stations d WHERE o.name = ? AND d.name = ?";
PreparedStatement psStations = conn.prepareStatement(findStations);
psStations.setString(1, origin);
psStations.setString(2, destination);
ResultSet foundStations = psStations.executeQuery();
foundStations.next();
int o_station_id = foundStations.getInt(1);
int d_station_id = foundStations.getInt(2);



String findStops = "SELECT o.departure_time, d.arrival_time FROM stops o, stops d WHERE o.station_id = ? AND d.station_id = ? AND o.departure_time < d.arrival_time ORDER BY o.departure_time ASC, o.arrival_time ASC";
PreparedStatement psStops = conn.prepareStatement(findStops);
psStops.setInt(1, o_station_id);
psStops.setInt(2,d_station_id);
ResultSet foundStops = psStops.executeQuery();
%>

<h1>Schedule on <%= date %></h1>
<h1>From <%=origin %> (<%=o_station_id %>) to <%=destination %> (<%=d_station_id %>)</h1>
<br><br>

<table>
<tr>
<th>Origin Departure Time</th>
<th>Destination Arrival Time</th>
</tr>

<%
while(foundStops.next()){
	out.print("<tr>");
	out.print("<td>");
	out.print(foundStops.getString(1));
	out.print("<td>");
	out.print(foundStops.getString(2));
	out.print("</tr>");
} %>

</table>

 <% conn.close(); %>
 
<br>
<a href="home.jsp">back to home</a>
</body>
</html>