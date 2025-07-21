<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<html>
<head>
<title>Reservation Reports</title>
</head>
<body>
<%
    String username = (String) session.getAttribute("username");
    String acc_type = (String) session.getAttribute("acc_type");
    
    if (username == null || !"admin".equals(acc_type)) {
        response.sendRedirect("home.jsp");
        return;
    }
    
    bookingDB db = new bookingDB();
    Connection conn = db.getConnection();
%>

<h1>Reservation Reports</h1>
<p><a href="adminPanel.jsp">Back to Admin Panel</a></p>

<h2>Reservations by Transit Line</h2>
<form method="get">
    <input type="hidden" name="reportType" value="transitLine">
    <select name="transitLine">
        <option value="">All Transit Lines</option>
        <%
        String getLines = "SELECT DISTINCT line_name FROM transitlines ORDER BY line_name";
        PreparedStatement psLines = conn.prepareStatement(getLines);
        ResultSet linesResult = psLines.executeQuery();
        
        while(linesResult.next()) {
            String lineName = linesResult.getString("line_name");
            String selected = lineName.equals(request.getParameter("transitLine")) ? "selected" : "";
            out.println("<option value='" + lineName + "' " + selected + ">" + lineName + "</option>");
        }
        %>
    </select>
    <input type="submit" value="Generate Report">
</form>

<%
String selectedTransitLine = request.getParameter("transitLine");
if ("transitLine".equals(request.getParameter("reportType")) || selectedTransitLine != null) {
    String transitLineQuery = "SELECT r.res_id, r.res_date, r.creationDate, r.isActive, tl.fare, r.total_fare, " +
                             "u.firstname, u.lastname, u.username, t.train_id, t.line_name, " +
                             "st_origin.name as origin_station, st_dest.name as dest_station " +
                             "FROM reservations r " +
                             "JOIN users u ON r.user_id = u.user_id " +
                             "JOIN trains t ON r.line_name = t.line_name " +
                             "JOIN transitlines tl on r.line_name = tl.line_name " +
                             "JOIN stops s_origin ON r.origin_stop_id = s_origin.stop_id " +
                             "JOIN stops s_dest ON r.dest_stop_id = s_dest.stop_id " +
                             "JOIN stations st_origin ON s_origin.station_id = st_origin.station_id " +
                             "JOIN stations st_dest ON s_dest.station_id = st_dest.station_id";
    
    if (selectedTransitLine != null && !selectedTransitLine.trim().isEmpty()) {
        transitLineQuery += " WHERE t.line_name = ?";
    }
    
    transitLineQuery += " ORDER BY r.creationDate DESC, t.line_name, r.res_id";
    
    PreparedStatement psTransitLine = conn.prepareStatement(transitLineQuery);
    if (selectedTransitLine != null && !selectedTransitLine.trim().isEmpty()) {
        psTransitLine.setString(1, selectedTransitLine);
    }
    ResultSet transitLineResult = psTransitLine.executeQuery();
%>

<h4>Results</h4>
<table border="1">
<tr>
    <th>Reservation ID</th>
    <th>Customer</th>
    <th>Transit Line</th>
    <th>Train ID</th>
    <th>Route</th>
    <th>Travel Date</th>
    <th>Booking Date</th>
    <th>Line's Fare</th>
    <th>Customer's Fare</th>
    <th>Status</th>
</tr>

<%
boolean hasTransitResults = false;
while(transitLineResult.next()) {
    hasTransitResults = true;
    String fullName = transitLineResult.getString("firstname") + " " + transitLineResult.getString("lastname");
    String route = transitLineResult.getString("origin_station") + " → " + transitLineResult.getString("dest_station");
    String status = transitLineResult.getString("isActive");
    
    out.print("<tr>");
    out.print("<td>" + transitLineResult.getInt("res_id") + "</td>");
    out.print("<td>" + fullName + " (" + transitLineResult.getString("username") + ")</td>");
    out.print("<td>" + transitLineResult.getString("line_name") + "</td>");
    out.print("<td>" + transitLineResult.getInt("train_id") + "</td>");
    out.print("<td>" + route + "</td>");
    out.print("<td>" + transitLineResult.getDate("res_date") + "</td>");
    out.print("<td>" + transitLineResult.getTimestamp("creationDate") + "</td>");
    out.print("<td>$" + String.format("%.2f", transitLineResult.getDouble("total_fare")) + "</td>");
    out.print("<td>$" + String.format("%.2f", transitLineResult.getDouble("fare")) + "</td>");
    out.print("<td>" + status.substring(0,1).toUpperCase() + status.substring(1) + "</td>");
    out.print("</tr>");
}

if (!hasTransitResults) {
    out.print("<tr><td colspan='10'>No reservations found for the selected criteria.</td></tr>");
}
%>
</table>
<% } %>

<h2>Reservations by Customer Name</h2>
<form method="get">
    <input type="hidden" name="reportType" value="customer">
    <input type="text" name="customerName" placeholder="Enter customer name (first or last)" value="<%= request.getParameter("customerName") != null ? request.getParameter("customerName") : "" %>">
    <input type="submit" value="Search">
</form>

<%
String selectedCustomer = request.getParameter("customerName");
if ("customer".equals(request.getParameter("reportType")) || selectedCustomer != null) {
    String customerQuery = "SELECT r.res_id, r.res_date, r.booking_date, r.status, r.passenger_type, r.total_fare, " +
                          "u.firstname, u.lastname, u.username, u.email, t.train_id, t.line_name, " +
                          "st_origin.station_name as origin_station, st_dest.station_name as dest_station " +
                          "FROM reservations r " +
                          "JOIN users u ON r.user_id = u.user_id " +
                          "JOIN trains t ON r.train_id = t.train_id " +
                          "JOIN stops s_origin ON r.origin_stop_id = s_origin.stop_id " +
                          "JOIN stops s_dest ON r.dest_stop_id = s_dest.stop_id " +
                          "JOIN stations st_origin ON s_origin.station_id = st_origin.station_id " +
                          "JOIN stations st_dest ON s_dest.station_id = st_dest.station_id";
    
    if (selectedCustomer != null && !selectedCustomer.trim().isEmpty()) {
        customerQuery += " WHERE (u.firstname LIKE ? OR u.lastname LIKE ? OR CONCAT(u.firstname, ' ', u.lastname) LIKE ?)";
    }
    
    customerQuery += " ORDER BY u.lastname, u.firstname, r.booking_date DESC";
    
    PreparedStatement psCustomer = conn.prepareStatement(customerQuery);
    if (selectedCustomer != null && !selectedCustomer.trim().isEmpty()) {
        String searchPattern = "%" + selectedCustomer + "%";
        psCustomer.setString(1, searchPattern);
        psCustomer.setString(2, searchPattern);
        psCustomer.setString(3, searchPattern);
    }
    ResultSet customerResult = psCustomer.executeQuery();
%>

<h4>Results</h4>
<table border="1">
<tr>
    <th>Reservation ID</th>
    <th>Customer</th>
    <th>Email</th>
    <th>Transit Line</th>
    <th>Train ID</th>
    <th>Route</th>
    <th>Travel Date</th>
    <th>Booking Date</th>
    <th>Passenger Type</th>
    <th>Fare</th>
    <th>Status</th>
</tr>

<%
boolean hasCustomerResults = false;
while(customerResult.next()) {
    hasCustomerResults = true;
    String fullName = customerResult.getString("firstname") + " " + customerResult.getString("lastname");
    String route = customerResult.getString("origin_station") + " → " + customerResult.getString("dest_station");
    String status = customerResult.getString("status");
    
    out.print("<tr>");
    out.print("<td>" + customerResult.getInt("res_id") + "</td>");
    out.print("<td>" + fullName + " (" + customerResult.getString("username") + ")</td>");
    out.print("<td>" + customerResult.getString("email") + "</td>");
    out.print("<td>" + customerResult.getString("line_name") + "</td>");
    out.print("<td>" + customerResult.getInt("train_id") + "</td>");
    out.print("<td>" + route + "</td>");
    out.print("<td>" + customerResult.getDate("res_date") + "</td>");
    out.print("<td>" + customerResult.getTimestamp("booking_date") + "</td>");
    out.print("<td>" + customerResult.getString("passenger_type").substring(0,1).toUpperCase() + customerResult.getString("passenger_type").substring(1) + "</td>");
    out.print("<td>$" + String.format("%.2f", customerResult.getDouble("total_fare")) + "</td>");
    out.print("<td>" + status.substring(0,1).toUpperCase() + status.substring(1) + "</td>");
    out.print("</tr>");
}

if (!hasCustomerResults) {
    out.print("<tr><td colspan='11'>No reservations found for the selected customer.</td></tr>");
}
%>
</table>
<% } %>

<%
conn.close();
%>

</body>
</html>