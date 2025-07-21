<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*,java.time.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Train Stops</title>
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
String trainid = request.getParameter("trainid");
String sortValue = request.getParameter("sortValue");
String sortDirect = request.getParameter("sortDirect");

String findLine = "SELECT line_name FROM trains WHERE train_id = ?";
PreparedStatement psLine = conn.prepareStatement(findLine);
psLine.setString(1, trainid);
ResultSet resultLine = psLine.executeQuery();

String line_name = "";
if (resultLine.next()) {
    line_name = resultLine.getString("line_name");
} else {
    out.println("<p>Error: Train not found</p>");
    conn.close();
    return;
}

String stops_in_transitline = "SELECT t.line_name, t.fare, t.fareChild, t.fareSenior, t.fareDisabled, s.stop_id, st.name, s.arrival_time, s.departure_time " +
                             "FROM transitlines t " +
                             "JOIN TransitLines_Contains_Stops ts ON t.line_name = ts.line_name " +
                             "JOIN stops s ON ts.stop_id = s.stop_id " +
                             "JOIN stations st ON s.station_id = st.station_id " +
                             "WHERE t.line_name = ?";

if (sortValue != null && sortDirect != null) {
    stops_in_transitline += " ORDER BY " + sortValue + " " + sortDirect;
}

PreparedStatement psStops = conn.prepareStatement(stops_in_transitline);
psStops.setString(1, line_name);
ResultSet results = psStops.executeQuery();
%>

<h1>Stops for train #<%=trainid%> (<%=line_name%>)</h1>

<br><br>

<table>
<tr>
<th>Line Name</th>
<th>Fare</th>
<th>Fare (Children)</th>
<th>Fare (Senior)</th>
<th>Fare (Disabled)</th>
<th>Stop ID</th>
<th>Station Name</th>
<th>Stop Arrival</th>
<th>Stop Departure</th>
</tr>

<%
boolean hasResults = false;
while(results.next()){
    hasResults = true;
    out.print("<tr>");
    out.print("<td>" + results.getString("line_name") + "</td>");
    out.print("<td>$" + String.format("%.2f", results.getDouble("fare")) + "</td>");
    out.print("<td>$" + String.format("%.2f", results.getDouble("fareChild")) + "</td>");
    out.print("<td>$" + String.format("%.2f", results.getDouble("fareSenior")) + "</td>");
    out.print("<td>$" + String.format("%.2f", results.getDouble("fareDisabled")) + "</td>");
    out.print("<td>" + results.getInt("stop_id") + "</td>");
    out.print("<td>" + results.getString("name") + "</td>");
    out.print("<td>" + results.getTime("arrival_time") + "</td>");
    out.print("<td>" + results.getTime("departure_time") + "</td>");
    out.print("</tr>");
}

if (!hasResults) {
    out.print("<tr><td colspan='9'>No stops found for this train.</td></tr>");
}

conn.close();
%>
</table>
<br>
<a href="home.jsp">Click here to proceed to homepage</a>
</body>
</html>