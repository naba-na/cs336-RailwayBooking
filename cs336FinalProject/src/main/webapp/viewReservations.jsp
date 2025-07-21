<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*,java.time.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>My Reservations</title>
<style>
    table { border-collapse: collapse; width: 100%; margin: 20px 0; }
    th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
    th { background-color: #f2f2f2; }
    .active { background-color: #e8f5e8; }
    .cancelled { background-color: #ffe8e8; }
    .past { background-color: #f8f8f8; }
    .section { margin: 30px 0; }
    .cancel-btn { background: #f44336; color: white; padding: 5px 10px; text-decoration: none; border-radius: 3px; }
    .cancel-btn:hover { background: #d32f2f; }
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
    
    if (!userResult.next()) {
        out.println("<p>Error: User not found</p>");
        conn.close();
        return;
    }
    int user_id = userResult.getInt("user_id");
    
    java.sql.Date currentDate = new java.sql.Date(System.currentTimeMillis());
%>

<h1>My Reservations</h1>

<div class="section">
    <h2>Current Reservations (Future Travel)</h2>
    <%
    String currentReservations = "SELECT r.res_id, r.res_date, r.train_id, t.line_name, r.passenger_type, r.total_fare, r.status, " +
                               "st_origin.station_name as origin_station, st_dest.station_name as dest_station, " +
                               "s_origin.departure_time, s_dest.arrival_time " +
                               "FROM reservations r " +
                               "JOIN trains t ON r.train_id = t.train_id " +
                               "JOIN stops s_origin ON r.origin_stop_id = s_origin.stop_id " +
                               "JOIN stops s_dest ON r.dest_stop_id = s_dest.stop_id " +
                               "JOIN stations st_origin ON s_origin.station_id = st_origin.station_id " +
                               "JOIN stations st_dest ON s_dest.station_id = st_dest.station_id " +
                               "WHERE r.user_id = ? AND r.res_date >= ? AND r.status = 'active' " +
                               "ORDER BY r.res_date ASC, s_origin.departure_time ASC";
    
    PreparedStatement psCurrent = conn.prepareStatement(currentReservations);
    psCurrent.setInt(1, user_id);
    psCurrent.setDate(2, currentDate);
    ResultSet currentResults = psCurrent.executeQuery();
    %>
    
    <table>
    <tr>
        <th>Reservation ID</th>
        <th>Travel Date</th>
        <th>Train</th>
        <th>From</th>
        <th>To</th>
        <th>Departure</th>
        <th>Arrival</th>
        <th>Passenger Type</th>
        <th>Total Fare</th>
        <th>Action</th>
    </tr>
    
    <%
    boolean hasCurrentReservations = false;
    while(currentResults.next()){
        hasCurrentReservations = true;
        out.print("<tr class='active'>");
        out.print("<td>" + currentResults.getInt("res_id") + "</td>");
        out.print("<td>" + currentResults.getDate("res_date") + "</td>");
        out.print("<td>#" + currentResults.getInt("train_id") + " (" + currentResults.getString("line_name") + ")</td>");
        out.print("<td>" + currentResults.getString("origin_station") + "</td>");
        out.print("<td>" + currentResults.getString("dest_station") + "</td>");
        out.print("<td>" + currentResults.getTime("departure_time") + "</td>");
        out.print("<td>" + currentResults.getTime("arrival_time") + "</td>");
        out.print("<td>" + currentResults.getString("passenger_type").substring(0,1).toUpperCase() + currentResults.getString("passenger_type").substring(1) + "</td>");
        out.print("<td>$" + String.format("%.2f", currentResults.getDouble("total_fare")) + "</td>");
        out.print("<td><a href='cancelReservations.jsp?res_id=" + currentResults.getInt("res_id") + "' class='cancel-btn' onclick='return confirm(\"Are you sure you want to cancel this reservation?\")'>Cancel</a></td>");
        out.print("</tr>");
    }
    
    if (!hasCurrentReservations) {
        out.print("<tr><td colspan='10'>No current reservations found.</td></tr>");
    }
    %>
    </table>
</div>

<div class="section">
    <h2>Past Reservations</h2>
    <%
    String pastReservations = "SELECT r.res_id, r.res_date, r.train_id, t.line_name, r.passenger_type, r.total_fare, r.status, " +
                            "st_origin.station_name as origin_station, st_dest.station_name as dest_station, " +
                            "s_origin.departure_time, s_dest.arrival_time " +
                            "FROM reservations r " +
                            "JOIN trains t ON r.train_id = t.train_id " +
                            "JOIN stops s_origin ON r.origin_stop_id = s_origin.stop_id " +
                            "JOIN stops s_dest ON r.dest_stop_id = s_dest.stop_id " +
                            "JOIN stations st_origin ON s_origin.station_id = st_origin.station_id " +
                            "JOIN stations st_dest ON s_dest.station_id = st_dest.station_id " +
                            "WHERE r.user_id = ? AND (r.res_date < ? OR r.status = 'cancelled') " +
                            "ORDER BY r.res_date DESC, s_origin.departure_time DESC";
    
    PreparedStatement psPast = conn.prepareStatement(pastReservations);
    psPast.setInt(1, user_id);
    psPast.setDate(2, currentDate);
    ResultSet pastResults = psPast.executeQuery();
    %>
    
    <table>
    <tr>
        <th>Reservation ID</th>
        <th>Travel Date</th>
        <th>Train</th>
        <th>From</th>
        <th>To</th>
        <th>Departure</th>
        <th>Arrival</th>
        <th>Passenger Type</th>
        <th>Total Fare</th>
        <th>Status</th>
    </tr>
    
    <%
    boolean hasPastReservations = false;
    while(pastResults.next()){
        hasPastReservations = true;
        String status = pastResults.getString("status");
        String rowClass = status.equals("cancelled") ? "cancelled" : "past";
        
        out.print("<tr class='" + rowClass + "'>");
        out.print("<td>" + pastResults.getInt("res_id") + "</td>");
        out.print("<td>" + pastResults.getDate("res_date") + "</td>");
        out.print("<td>#" + pastResults.getInt("train_id") + " (" + pastResults.getString("line_name") + ")</td>");
        out.print("<td>" + pastResults.getString("origin_station") + "</td>");
        out.print("<td>" + pastResults.getString("dest_station") + "</td>");
        out.print("<td>" + pastResults.getTime("departure_time") + "</td>");
        out.print("<td>" + pastResults.getTime("arrival_time") + "</td>");
        out.print("<td>" + pastResults.getString("passenger_type").substring(0,1).toUpperCase() + pastResults.getString("passenger_type").substring(1) + "</td>");
        out.print("<td>$" + String.format("%.2f", pastResults.getDouble("total_fare")) + "</td>");
        out.print("<td>" + (status.equals("cancelled") ? "Cancelled" : "Completed") + "</td>");
        out.print("</tr>");
    }
    
    if (!hasPastReservations) {
        out.print("<tr><td colspan='10'>No past reservations found.</td></tr>");
    }
    
    conn.close();
    %>
    </table>
</div>

<div style="text-align: center; margin: 20px;">
    <a href="home.jsp">Return to Home</a>
</div>

</body>
</html>