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



//todo - print multiple times for different arrival/departure times to the same stops
String findStops = "SELECT o.departure_time, d.arrival_time FROM stops o, stops d WHERE o.station_id = ? AND d.station_id = ?";
PreparedStatement psStops = conn.prepareStatement(findStops);
psStops.setInt(1, o_station_id);
psStops.setInt(2,d_station_id);
ResultSet foundStops = psStops.executeQuery();
foundStops.next();
String o_time = foundStops.getString(1);
String d_time = foundStops.getString(2);
%>

<h1>Schedule on <%= date %></h1>

<br><br>

<table>
<tr>
<th>Origin Station Number</th>
<th>Name</th>
<th>Destination Station Number</th>
<th>Name</th>
<th>Origin Departure Time</th>
<th>Destination Arrival Time</th>
</tr>

<tr>
<td><%=o_station_id %> </td>
<td><%=origin %> </td>
<td><%=d_station_id %> </td>
<td><%=destination %> </td>
<td><%=o_time %> </td>
<td><%=d_time %> </td>
</tr>
</table>

<% conn.close(); %>
<br>
<a href="home.jsp">back to home</a>
</body>
</html>