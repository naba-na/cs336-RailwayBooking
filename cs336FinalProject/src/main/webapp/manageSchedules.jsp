<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<html>
<head>
<title>Manage Train Schedules</title>
</head>
<body>
<%
    String username = (String) session.getAttribute("username");
    String acc_type = (String) session.getAttribute("acc_type");
    
    if (username == null || !"rep".equals(acc_type)) {
        response.sendRedirect("home.jsp");
        return;
    }
    
    String deleteType = request.getParameter("deleteType");
    String deleteId = request.getParameter("deleteId");
    String message = "";
    
    if (deleteType != null && deleteId != null) {
        bookingDB db = new bookingDB();
        Connection conn = db.getConnection();
        
        try {
            if ("train".equals(deleteType)) {
                String deleteTrain = "DELETE FROM trains WHERE train_id = ?";
                PreparedStatement ps = conn.prepareStatement(deleteTrain);
                ps.setString(1, deleteId);
                int result = ps.executeUpdate();
                message = result > 0 ? "<p>Train deleted successfully!</p>" : "<p>Failed to delete train.</p>";
            } else if ("stop".equals(deleteType)) {
                String deleteStop = "DELETE FROM stops WHERE stop_id = ?";
                PreparedStatement ps = conn.prepareStatement(deleteStop);
                ps.setString(1, deleteId);
                int result = ps.executeUpdate();
                message = result > 0 ? "<p>Stop deleted successfully!</p>" : "<p>Failed to delete stop.</p>";
            }
        } catch (Exception e) {
            message = "<p>Error: " + e.getMessage() + "</p>";
        } finally {
            conn.close();
        }
    }
    
    bookingDB db = new bookingDB();
    Connection conn = db.getConnection();
%>

<h1>Manage Train Schedules</h1>
<p><a href="repPanel.jsp">Back to Rep Panel</a></p>

<%= message %>

<h2>Trains</h2>
<a href="addTrain.jsp">Add New Train</a>

<table border="1">
<tr>
    <th>Train ID</th>
    <th>Line Name</th>
    <th>Fare</th>
    <th>Child Fare</th>
    <th>Senior Fare</th>
    <th>Disabled Fare</th>
    <th>Actions</th>
</tr>

<%
String getTrains = "SELECT t.train_id, t.line_name, tl.fare, tl.fareChild, tl.fareSenior, tl.fareDisabled " +
                  "FROM trains t " +
                  "JOIN transitlines tl ON t.line_name = tl.line_name " +
                  "ORDER BY t.train_id";

PreparedStatement psTrains = conn.prepareStatement(getTrains);
ResultSet trainsResult = psTrains.executeQuery();

while(trainsResult.next()){
    int trainId = trainsResult.getInt("train_id");
    out.print("<tr>");
    out.print("<td>" + trainId + "</td>");
    out.print("<td>" + trainsResult.getString("line_name") + "</td>");
    out.print("<td>$" + String.format("%.2f", trainsResult.getDouble("fare")) + "</td>");
    out.print("<td>$" + String.format("%.2f", trainsResult.getDouble("fareChild")) + "</td>");
    out.print("<td>$" + String.format("%.2f", trainsResult.getDouble("fareSenior")) + "</td>");
    out.print("<td>$" + String.format("%.2f", trainsResult.getDouble("fareDisabled")) + "</td>");
    out.print("<td>");
    out.print("<a href='editTrain.jsp?id=" + trainId + "'>Edit</a> | ");
    out.print("<a href='manageSchedules.jsp?deleteType=train&deleteId=" + trainId + "' onclick='return confirm(\"Delete this train? This will also delete all reservations for this train.\")'>Delete</a>");
    out.print("</td>");
    out.print("</tr>");
}
%>
</table>

<h2>Transit Lines</h2>
<a href="addTransitLine.jsp">Add New Transit Line</a>

<table border="1">
<tr>
    <th>Line Name</th>
    <th>Fare</th>
    <th>Child Fare</th>
    <th>Senior Fare</th>
    <th>Disabled Fare</th>
    <th>Trains</th>
    <th>Actions</th>
</tr>

<%
String getLines = "SELECT tl.line_name, tl.fare, tl.fareChild, tl.fareSenior, tl.fareDisabled, " +
                 "COUNT(t.train_id) as train_count " +
                 "FROM transitlines tl " +
                 "LEFT JOIN trains t ON tl.line_name = t.line_name " +
                 "GROUP BY tl.line_name, tl.fare, tl.fareChild, tl.fareSenior, tl.fareDisabled " +
                 "ORDER BY tl.line_name";

PreparedStatement psLines = conn.prepareStatement(getLines);
ResultSet linesResult = psLines.executeQuery();

while(linesResult.next()){
    String lineName = linesResult.getString("line_name");
    out.print("<tr>");
    out.print("<td>" + lineName + "</td>");
    out.print("<td>$" + String.format("%.2f", linesResult.getDouble("fare")) + "</td>");
    out.print("<td>$" + String.format("%.2f", linesResult.getDouble("fareChild")) + "</td>");
    out.print("<td>$" + String.format("%.2f", linesResult.getDouble("fareSenior")) + "</td>");
    out.print("<td>$" + String.format("%.2f", linesResult.getDouble("fareDisabled")) + "</td>");
    out.print("<td>" + linesResult.getInt("train_count") + "</td>");
    out.print("<td>");
    out.print("<a href='editTransitLine.jsp?name=" + java.net.URLEncoder.encode(lineName, "UTF-8") + "'>Edit</a>");
    out.print("</td>");
    out.print("</tr>");
}
%>
</table>

<h2>Stations & Stops</h2>
<a href="addStation.jsp">Add New Station</a> | 
<a href="addStop.jsp">Add New Stop</a>

<table border="1">
<tr>
    <th>Stop ID</th>
    <th>Station Name</th>
    <th>City</th>
    <th>State</th>
    <th>Arrival Time</th>
    <th>Departure Time</th>
    <th>Transit Lines</th>
    <th>Actions</th>
</tr>

<%
String getStops = "SELECT s.stop_id, st.name, st.city, st.state, s.arrival_time, s.departure_time, " +
                 "GROUP_CONCAT(DISTINCT tcs.line_name SEPARATOR ', ') as 'lines' " +
                 "FROM stops s " +
                 "JOIN stations st ON s.station_id = st.station_id " +
                 "LEFT JOIN TransitLines_Contains_Stops tcs ON s.stop_id = tcs.stop_id " +
                 "GROUP BY s.stop_id, st.name, st.city, st.state, s.arrival_time, s.departure_time " +
                 "ORDER BY st.name, s.arrival_time";

PreparedStatement psStops = conn.prepareStatement(getStops);
ResultSet stopsResult = psStops.executeQuery();

while(stopsResult.next()){
    int stopId = stopsResult.getInt("stop_id");
    out.print("<tr>");
    out.print("<td>" + stopId + "</td>");
    out.print("<td>" + stopsResult.getString("name") + "</td>");
    out.print("<td>" + stopsResult.getString("city") + "</td>");
    out.print("<td>" + stopsResult.getString("state") + "</td>");
    out.print("<td>" + stopsResult.getTime("arrival_time") + "</td>");
    out.print("<td>" + stopsResult.getTime("departure_time") + "</td>");
    out.print("<td>" + (stopsResult.getString("lines") != null ? stopsResult.getString("lines") : "None") + "</td>");
    out.print("<td>");
    out.print("<a href='editStop.jsp?id=" + stopId + "'>Edit</a> | ");
    out.print("<a href='manageSchedules.jsp?deleteType=stop&deleteId=" + stopId + "' onclick='return confirm(\"Delete this stop?\")'>Delete</a>");
    out.print("</td>");
    out.print("</tr>");
}

conn.close();
%>
</table>

</body>
</html>