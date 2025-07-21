<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>My Reservations</title>
<style>
    table { border-collapse: collapse; width: 100%; margin: 20px 0; }
    th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
    th { background-color: #f2f2f2; }
    .cancelled { background-color: #ffe8e8; }
</style>
</head>
<body>
<%
String username = (String) session.getAttribute("username");
if (username == null) {
    response.sendRedirect("login.jsp");
    return;
}

bookingDB db = new bookingDB();
Connection conn = db.getConnection();

String getUserId = "SELECT user_id FROM users WHERE username = ?";
PreparedStatement psUser = conn.prepareStatement(getUserId);
psUser.setString(1, username);
ResultSet userResult = psUser.executeQuery();
userResult.next();
int userId = userResult.getInt("user_id");

String getReservations = "SELECT r.*, t.line_name, " +
                        "st_origin.station_name as origin_station, st_dest.station_name as dest_station " +
                        "FROM reservations r " +
                        "JOIN trains t ON r.train_id = t.train_id " +
                        "JOIN stops s_origin ON r.origin_stop_id = s_origin.stop_id " +
                        "JOIN stops s_dest ON r.dest_stop_id = s_dest.stop_id " +
                        "JOIN stations st_origin ON s_origin.station_id = st_origin.station_id " +
                        "JOIN stations st_dest ON s_dest.station_id = st_dest.station_id " +
                        "WHERE r.user_id = ? " +
                        "ORDER BY r.res_date DESC";

PreparedStatement psReservations = conn.prepareStatement(getReservations);
psReservations.setInt(1, userId);
ResultSet reservations = psReservations.executeQuery();
%>

<h2>My Reservations</h2>

<h3>All Reservations</h3>
<table>
<tr>
    <th>Reservation ID</th>
    <th>Train</th>
    <th>Route</th>
    <th>Travel Date</th>
    <th>Passenger Type</th>
    <th>Fare</th>
    <th>Status</th>
    <th>Actions</th>
</tr>

<%
boolean hasReservations = false;
while(reservations.next()) {
    hasReservations = true;
    String status = reservations.getString("status");
    String rowClass = "cancelled".equals(status) ? "class='cancelled'" : "";
    String route = reservations.getString("origin_station") + " → " + reservations.getString("dest_station");
    
    out.print("<tr " + rowClass + ">");
    out.print("<td>" + reservations.getInt("res_id") + "</td>");
    out.print("<td>#" + reservations.getInt("train_id") + " (" + reservations.getString("line_name") + ")</td>");
    out.print("<td>" + route + "</td>");
    out.print("<td>" + reservations.getDate("res_date") + "</td>");
    out.print("<td>" + reservations.getString("passenger_type") + "</td>");
    out.print("<td>$" + String.format("%.2f", reservations.getDouble("total_fare")) + "</td>");
    out.print("<td>" + status + "</td>");
    out.print("<td>");
    if ("active".equals(status)) {
        out.print("<a href='cancelReservations.jsp?res_id=" + reservations.getInt("res_id") + "' onclick='return confirm(\"Cancel this reservation?\")'>Cancel</a>");
    }
    out.print("</td>");
    out.print("</tr>");
}

if (!hasReservations) {
    out.print("<tr><td colspan='8'>No reservations found.</td></tr>");
}

conn.close();
%>
</table>

<a href="home.jsp">Back to Home</a>
</body>
</html>