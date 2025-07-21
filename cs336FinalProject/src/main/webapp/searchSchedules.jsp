<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Train Schedules</title>
<style>
    table { border-collapse: collapse; width: 100%; }
    th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
    th { background-color: #f2f2f2; }
</style>
</head>
<body>
<% 
bookingDB db = new bookingDB();
Connection conn = db.getConnection();

String origin = request.getParameter("origin");
String destination = request.getParameter("destination");
String date = request.getParameter("date");

String findTrains = "SELECT DISTINCT t.train_id, t.line_name, tl.fare, " +
                   "s1.departure_time as origin_departure, s2.arrival_time as dest_arrival, " +
                   "st1.station_name as origin_station, st2.station_name as dest_station " +
                   "FROM trains t " +
                   "JOIN transitlines tl ON t.line_name = tl.line_name " +
                   "JOIN TransitLines_Contains_Stops tcs1 ON t.line_name = tcs1.line_name " +
                   "JOIN TransitLines_Contains_Stops tcs2 ON t.line_name = tcs2.line_name " +
                   "JOIN stops s1 ON tcs1.stop_id = s1.stop_id " +
                   "JOIN stops s2 ON tcs2.stop_id = s2.stop_id " +
                   "JOIN stations st1 ON s1.station_id = st1.station_id " +
                   "JOIN stations st2 ON s2.station_id = st2.station_id " +
                   "WHERE st1.station_name = ? AND st2.station_name = ? " +
                   "AND s1.departure_time < s2.arrival_time " +
                   "ORDER BY s1.departure_time";

PreparedStatement psTrains = conn.prepareStatement(findTrains);
psTrains.setString(1, origin);
psTrains.setString(2, destination);
ResultSet trainResults = psTrains.executeQuery();
%>

<h2>Train Schedules for <%= date %></h2>
<h3>From <%= origin %> to <%= destination %></h3>

<table>
<tr>
<th>Train ID</th>
<th>Line Name</th>
<th>Departure Time</th>
<th>Arrival Time</th>
<th>Fare</th>
<th>Book</th>
</tr>

<%
boolean hasResults = false;
while(trainResults.next()){
    hasResults = true;
    int trainId = trainResults.getInt("train_id");
    String lineName = trainResults.getString("line_name");
    
    out.print("<tr>");
    out.print("<td>" + trainId + "</td>");
    out.print("<td>" + lineName + "</td>");
    out.print("<td>" + trainResults.getTime("origin_departure") + "</td>");
    out.print("<td>" + trainResults.getTime("dest_arrival") + "</td>");
    out.print("<td>$" + String.format("%.2f", trainResults.getDouble("fare")) + "</td>");
    out.print("<td><a href='bookReservation.jsp?train_id=" + trainId + "&origin=" + origin + "&destination=" + destination + "&date=" + date + "&line_name=" + lineName + "'>Book</a></td>");
    out.print("</tr>");
}

if (!hasResults) {
    out.print("<tr><td colspan='6'>No trains found for this route.</td></tr>");
}

conn.close();
%>
</table>

<br>
<a href="home.jsp">Back to Home</a>
</body>
</html>