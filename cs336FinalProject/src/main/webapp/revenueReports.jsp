<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<html>
<head>
<title>Revenue Reports</title>
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

<h1>Revenue Analysis</h1>
<p><a href="adminPanel.jsp">Back to Admin Panel</a></p>

<%
String overallQuery = "SELECT " +
                     "SUM(CASE WHEN isActive = true THEN total_fare ELSE 0 END) as total_active_revenue, " +
                     "SUM(CASE WHEN isActive = false THEN total_fare ELSE 0 END) as total_cancelled_revenue, " +
                     "COUNT(CASE WHEN isActive = true THEN 1 END) as active_bookings, " +
                     "COUNT(CASE WHEN isActive = false THEN 1 END) as cancelled_bookings, " +
                     "AVG(CASE WHEN isActive = true THEN total_fare END) as avg_fare " +
                     "FROM reservations";

PreparedStatement psOverall = conn.prepareStatement(overallQuery);
ResultSet overallResult = psOverall.executeQuery();
overallResult.next();

double totalActiveRevenue = overallResult.getDouble("total_active_revenue");
double totalCancelledRevenue = overallResult.getDouble("total_cancelled_revenue");
int activeBookings = overallResult.getInt("active_bookings");
int cancelledBookings = overallResult.getInt("cancelled_bookings");
double avgFare = overallResult.getDouble("avg_fare");
%>

<h2>Total Revenue</h2>
<p><strong>Total Revenue:</strong> $<%= String.format("%.2f", totalActiveRevenue) %></p>
<p>From <%= activeBookings %> active reservations</p>

<h2>Revenue Metrics</h2>
<p><strong>Average Fare:</strong> $<%= String.format("%.2f", avgFare) %></p>
<p><strong>Cancelled Revenue:</strong> $<%= String.format("%.2f", totalCancelledRevenue) %></p>
<p><strong>Total Bookings:</strong> <%= activeBookings + cancelledBookings %></p>

<h2>Revenue by Transit Line</h2>
<table border="1">
<tr>
    <th>Transit Line</th>
    <th>Active Reservations</th>
    <th>Total Revenue</th>
    <th>Average Fare</th>
    <th>Cancelled Reservations</th>
    <th>Lost Revenue</th>
    <th>Revenue Share</th>
</tr>

<%
String lineRevenueQuery = "SELECT t.line_name, " +
                         "COUNT(CASE WHEN r.isActive = true THEN 1 END) as active_count, " +
                         "SUM(CASE WHEN r.isActive = true THEN r.total_fare ELSE 0 END) as line_revenue, " +
                         "AVG(CASE WHEN r.isActive = true THEN r.total_fare END) as avg_fare, " +
                         "COUNT(CASE WHEN r.isActive = false THEN 1 END) as cancelled_count, " +
                         "SUM(CASE WHEN r.isActive = false THEN r.total_fare ELSE 0 END) as lost_revenue " +
                         "FROM trains t " +
                         "LEFT JOIN reservations r ON t.line_name = r.line_name " +
                         "GROUP BY t.line_name " +
                         "ORDER BY line_revenue DESC";

PreparedStatement psLineRevenue = conn.prepareStatement(lineRevenueQuery);
ResultSet lineRevenueResult = psLineRevenue.executeQuery();

while(lineRevenueResult.next()) {
    double lineRevenue = lineRevenueResult.getDouble("line_revenue");
    double lineAvgFare = lineRevenueResult.getDouble("avg_fare");
    double lostRevenue = lineRevenueResult.getDouble("lost_revenue");
    double revenueShare = totalActiveRevenue > 0 ? (lineRevenue / totalActiveRevenue) * 100 : 0;
    
    out.print("<tr>");
    out.print("<td>" + lineRevenueResult.getString("line_name") + "</td>");
    out.print("<td>" + lineRevenueResult.getInt("active_count") + "</td>");
    out.print("<td><strong>$" + String.format("%.2f", lineRevenue) + "</strong></td>");
    out.print("<td>$" + String.format("%.2f", lineAvgFare) + "</td>");
    out.print("<td>" + lineRevenueResult.getInt("cancelled_count") + "</td>");
    out.print("<td>$" + String.format("%.2f", lostRevenue) + "</td>");
    out.print("<td>" + String.format("%.1f%%", revenueShare) + "</td>");
    out.print("</tr>");
}
%>
</table>

<h2>Top 20 Customers by Revenue</h2>
<table border="1">
<tr>
    <th>Rank</th>
    <th>Customer Name</th>
    <th>Username</th>
    <th>Total Reservations</th>
    <th>Active Reservations</th>
    <th>Total Revenue</th>
    <th>Average Fare</th>
    <th>Last Booking</th>
</tr>

<%
String customerRevenueQuery = "SELECT u.firstname, u.lastname, u.username, " +
                             "COUNT(r.res_id) as total_reservations, " +
                             "COUNT(CASE WHEN r.isActive = true THEN 1 END) as active_reservations, " +
                             "SUM(CASE WHEN r.isActive = true THEN r.total_fare ELSE 0 END) as customer_revenue, " +
                             "AVG(CASE WHEN r.isActive = true THEN r.total_fare END) as avg_customer_fare, " +
                             "MAX(r.creationDate) as last_booking " +
                             "FROM users u " +
                             "JOIN reservations r ON u.user_id = r.user_id " +
                             "GROUP BY u.user_id, u.firstname, u.lastname, u.username " +
                             "HAVING customer_revenue > 0 " +
                             "ORDER BY customer_revenue DESC " +
                             "LIMIT 20";

PreparedStatement psCustomerRevenue = conn.prepareStatement(customerRevenueQuery);
ResultSet customerRevenueResult = psCustomerRevenue.executeQuery();

int rank = 1;
while(customerRevenueResult.next()) {
    String fullName = customerRevenueResult.getString("firstname") + " " + customerRevenueResult.getString("lastname");
    double customerRevenue = customerRevenueResult.getDouble("customer_revenue");
    double avgCustomerFare = customerRevenueResult.getDouble("avg_customer_fare");
    
    out.print("<tr>");
    out.print("<td>" + rank + "</td>");
    out.print("<td>" + fullName + "</td>");
    out.print("<td>" + customerRevenueResult.getString("username") + "</td>");
    out.print("<td>" + customerRevenueResult.getInt("total_reservations") + "</td>");
    out.print("<td>" + customerRevenueResult.getInt("active_reservations") + "</td>");
    out.print("<td><strong>$" + String.format("%.2f", customerRevenue) + "</strong></td>");
    out.print("<td>$" + String.format("%.2f", avgCustomerFare) + "</td>");
    out.print("<td>" + customerRevenueResult.getTimestamp("last_booking") + "</td>");
    out.print("</tr>");
    rank++;
}

conn.close();
%>
</table>

</body>
</html>