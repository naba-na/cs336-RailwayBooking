<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<html>
<head>
<title>Station Schedules</title>
</head>
<body>
<%
    String username = (String) session.getAttribute("username");
    String acc_type = (String) session.getAttribute("acc_type");
    
    if (username == null || !"rep".equals(acc_type)) {
        response.sendRedirect("home.jsp");
        return;
    }
    
    String selectedStation = request.getParameter("station");
    String scheduleType = request.getParameter("scheduleType");
    
    bookingDB db = new bookingDB();
    Connection conn = db.getConnection();
%>

<h1>Station Schedules</h1>
<p><a href="repPanel.jsp">Back to Rep Panel</a></p>

<h3>Select Station</h3>
<form method="get">
    <select name="station" required>
        <option value="">Choose a station...</option>
        <%
        String getStations = "SELECT DISTINCT name FROM stations ORDER BY name";
        PreparedStatement psStations = conn.prepareStatement(getStations);
        ResultSet stationsResult = psStations.executeQuery();
        
        while(stationsResult.next()) {
            String stationName = stationsResult.getString("name");
            String selected = stationName.equals(selectedStation) ? "selected" : "";
            out.println("<option value='" + stationName + "' " + selected + ">" + stationName + "</option>");
        }
        %>
    </select>
    
    <select name="scheduleType">
        <option value="both" <%= "both".equals(scheduleType) ? "selected" : "" %>>Arrivals & Departures</option>
        <option value="arrivals" <%= "arrivals".equals(scheduleType) ? "selected" : "" %>>Arrivals Only</option>
        <option value="departures" <%= "departures".equals(scheduleType) ? "selected" : "" %>>Departures Only</option>
    </select>
    
    <input type="submit" value="Get Schedule">
</form>

<% if (selectedStation != null && !selectedStation.trim().isEmpty()) { %>

<%
String getStationInfo = "SELECT st.name, st.city, st.state, COUNT(DISTINCT s.stop_id) as total_stops, " +
                       "COUNT(DISTINCT tcs.line_name) as total_lines " +
                       "FROM stations st " +
                       "LEFT JOIN stops s ON st.station_id = s.station_id " +
                       "LEFT JOIN TransitLines_Contains_Stops tcs ON s.stop_id = tcs.stop_id " +
                       "WHERE st.name = ? " +
                       "GROUP BY st.name, st.city, st.state";

PreparedStatement psInfo = conn.prepareStatement(getStationInfo);
psInfo.setString(1, selectedStation);
ResultSet infoResult = psInfo.executeQuery();

if (infoResult.next()) {
    out.println("<h3>" + infoResult.getString("name") + "</h3>");
    out.println("<p><strong>Location:</strong> " + infoResult.getString("city") + ", " + infoResult.getString("state") + "</p>");
    out.println("<p><strong>Total Stops:</strong> " + infoResult.getInt("total_stops") + " | <strong>Transit Lines:</strong> " + infoResult.getInt("total_lines") + "</p>");
}
%>

<h3>Train Schedule</h3>
<table border="1">
<tr>
    <th>Train ID</th>
    <th>Transit Line</th>
    <% if (!"departures".equals(scheduleType)) { %>
        <th>Arrival Time</th>
    <% } %>
    <% if (!"arrivals".equals(scheduleType)) { %>
        <th>Departure Time</th>
    <% } %>
    <th>Fare</th>
    <th>Status</th>
</tr>

<%
String getSchedule = "SELECT t.train_id, t.line_name, s.arrival_time, s.departure_time, tl.fare " +
                    "FROM trains t " +
                    "JOIN stops s ON t.line_name IN ( " +
                    "    SELECT tcs.line_name FROM TransitLines_Contains_Stops tcs WHERE tcs.stop_id = s.stop_id " +
                    ") " +
                    "JOIN stations st ON s.station_id = st.station_id " +
                    "JOIN transitlines tl ON t.line_name = tl.line_name " +
                    "WHERE st.name = ? " +
                    "ORDER BY s.departure_time, s.arrival_time";

PreparedStatement psSchedule = conn.prepareStatement(getSchedule);
psSchedule.setString(1, selectedStation);
ResultSet scheduleResult = psSchedule.executeQuery();

boolean hasSchedule = false;
while(scheduleResult.next()) {
    hasSchedule = true;
    out.print("<tr>");
    out.print("<td>" + scheduleResult.getInt("train_id") + "</td>");
    out.print("<td>" + scheduleResult.getString("line_name") + "</td>");
    
    if (!"departures".equals(scheduleType)) {
        out.print("<td>" + scheduleResult.getTime("arrival_time") + "</td>");
    }
    if (!"arrivals".equals(scheduleType)) {
        out.print("<td>" + scheduleResult.getTime("departure_time") + "</td>");
    }
    
    out.print("<td>$" + String.format("%.2f", scheduleResult.getDouble("fare")) + "</td>");
    out.print("<td>Active</td>");
    out.print("</tr>");
}

if (!hasSchedule) {
    int colspan = 5;
    if ("arrivals".equals(scheduleType) || "departures".equals(scheduleType)) {
        colspan = 4;
    }
    out.print("<tr><td colspan='" + colspan + "'>No trains scheduled for this station.</td></tr>");
}
%>
</table>

<h3>Transit Lines Serving This Station</h3>
<table border="1">
<tr>
    <th>Line Name</th>
    <th>Trains</th>
    <th>Adult Fare</th>
    <th>Child Fare</th>
    <th>Senior Fare</th>
    <th>Disabled Fare</th>
</tr>

<%
String getLines = "SELECT DISTINCT tl.line_name, tl.fare, tl.fareChild, tl.fareSenior, tl.fareDisabled, " +
                 "COUNT(DISTINCT t.train_id) as train_count " +
                 "FROM transitlines tl " +
                 "JOIN TransitLines_Contains_Stops tcs ON tl.line_name = tcs.line_name " +
                 "JOIN stops s ON tcs.stop_id = s.stop_id " +
                 "JOIN stations st ON s.station_id = st.station_id " +
                 "LEFT JOIN trains t ON tl.line_name = t.line_name " +
                 "WHERE st.name = ? " +
                 "GROUP BY tl.line_name, tl.fare, tl.fareChild, tl.fareSenior, tl.fareDisabled";

PreparedStatement psLines = conn.prepareStatement(getLines);
psLines.setString(1, selectedStation);
ResultSet linesResult = psLines.executeQuery();

while(linesResult.next()) {
    out.print("<tr>");
    out.print("<td>" + linesResult.getString("line_name") + "</td>");
    out.print("<td>" + linesResult.getInt("train_count") + "</td>");
    out.print("<td>$" + String.format("%.2f", linesResult.getDouble("fare")) + "</td>");
    out.print("<td>$" + String.format("%.2f", linesResult.getDouble("fareChild")) + "</td>");
    out.print("<td>$" + String.format("%.2f", linesResult.getDouble("fareSenior")) + "</td>");
    out.print("<td>$" + String.format("%.2f", linesResult.getDouble("fareDisabled")) + "</td>");
    out.print("</tr>");
}
%>
</table>

<% } %>

<%
conn.close();
%>

</body>
</html>