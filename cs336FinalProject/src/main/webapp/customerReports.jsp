<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<html>
<head>
<title>Customer Reports</title>
</head>
<body>
<%
    String username = (String) session.getAttribute("username");
    String acc_type = (String) session.getAttribute("acc_type");
    
    if (username == null || !"rep".equals(acc_type)) {
        response.sendRedirect("home.jsp");
        return;
    }
    
    String selectedLine = request.getParameter("transitLine");
    String selectedDate = request.getParameter("travelDate");
    
    bookingDB db = new bookingDB();
    Connection conn = db.getConnection();
%>

<h1>Customer Reports</h1>
<p><a href="repPanel.jsp">Back to Rep Panel</a></p>

<h3>Generate Customer Report</h3>
<p>Find all customers who have reservations on a specific transit line and date.</p>

<form method="get">
    <label><strong>Transit Line:</strong></label><br/>
    <select name="transitLine" required>
        <option value="">Select Transit Line...</option>
        <%
        String getLines = "SELECT DISTINCT line_name FROM transitlines ORDER BY line_name";
        PreparedStatement psLines = conn.prepareStatement(getLines);
        ResultSet linesResult = psLines.executeQuery();
        
        while(linesResult.next()) {
            String lineName = linesResult.getString("line_name");
            String selected = lineName.equals(selectedLine) ? "selected" : "";
            out.println("<option value='" + lineName + "' " + selected + ">" + lineName + "</option>");
        }
        %>
    </select><br/>
    
    <label><strong>Travel Date:</strong></label><br/>
    <input type="date" name="travelDate" value="<%= selectedDate != null ? selectedDate : "" %>" required><br/>
    
    <input type="submit" value="Generate Report">
</form>

<% if (selectedLine != null && selectedDate != null && !selectedLine.trim().isEmpty() && !selectedDate.trim().isEmpty()) { %>

<%
String getCustomers = "SELECT DISTINCT u.username, u.firstname, u.lastname, u.email, r.res_id, tl.fare, " +
                     "r.total_fare, r.isActive, t.train_id, " +
                     "st_origin.name as origin_station, st_dest.name as dest_station " +
                     "FROM reservations r " +
                     "JOIN users u ON r.user_id = u.user_id " +
                     "JOIN trains t ON r.line_name = t.line_name " +
                     "JOIN transitlines tl on r.line_name = tl.line_name " +
                     "JOIN stops s_origin ON r.origin_stop_id = s_origin.stop_id " +
                     "JOIN stops s_dest ON r.dest_stop_id = s_dest.stop_id " +
                     "JOIN stations st_origin ON s_origin.station_id = st_origin.station_id " +
                     "JOIN stations st_dest ON s_dest.station_id = st_dest.station_id " +
                     "WHERE t.line_name = ? AND r.res_date = ? " +
                     "ORDER BY u.lastname, u.firstname, r.res_id";

PreparedStatement psCustomers = conn.prepareStatement(getCustomers);
psCustomers.setString(1, selectedLine);
psCustomers.setString(2, selectedDate);
ResultSet customersResult = psCustomers.executeQuery();

String getSummary = "SELECT COUNT(DISTINCT r.user_id) as unique_customers, " +
                   "COUNT(r.res_id) as total_reservations, " +
                   "SUM(r.total_fare) as total_revenue, " +
                   "COUNT(CASE WHEN r.isActive = true THEN 1 END) as active_reservations, " +
                   "COUNT(CASE WHEN r.isActive = false THEN 1 END) as cancelled_reservations " +
                   "FROM reservations r " +
                   "JOIN trains t ON r.line_name = t.line_name " +
                   "WHERE t.line_name = ? AND r.res_date = ?";

PreparedStatement psSummary = conn.prepareStatement(getSummary);
psSummary.setString(1, selectedLine);
psSummary.setString(2, selectedDate);
ResultSet summaryResult = psSummary.executeQuery();
summaryResult.next();

int uniqueCustomers = summaryResult.getInt("unique_customers");
int totalReservations = summaryResult.getInt("total_reservations");
double totalRevenue = summaryResult.getDouble("total_revenue");
int activeReservations = summaryResult.getInt("active_reservations");
int cancelledReservations = summaryResult.getInt("cancelled_reservations");
%>

<h3>Report Summary</h3>
<p><strong>Transit Line:</strong> <%= selectedLine %></p>
<p><strong>Travel Date:</strong> <%= selectedDate %></p>
<p><strong>Unique Customers:</strong> <%= uniqueCustomers %></p>
<p><strong>Total Reservations:</strong> <%= totalReservations %> (Active: <%= activeReservations %>, Cancelled: <%= cancelledReservations %>)</p>
<p><strong>Total Revenue:</strong> $<%= String.format("%.2f", totalRevenue) %></p>

<h3>Customer Details</h3>
<table border="1">
<tr>
    <th>Customer Name</th>
    <th>Username</th>
    <th>Email</th>
    <th>Reservation ID</th>
    <th>Train ID</th>
    <th>From → To</th>
    <th>Line's Fare</th>
    <th>Customer's Fare</th>
    <th>Status</th>
</tr>

<%
boolean hasCustomers = false;
while(customersResult.next()) {
    hasCustomers = true;
    String fullName = customersResult.getString("firstname") + " " + customersResult.getString("lastname");
    String route = customersResult.getString("origin_station") + " → " + customersResult.getString("dest_station");
    String status = customersResult.getString("isActive");
    
    out.print("<tr>");
    out.print("<td>" + fullName + "</td>");
    out.print("<td>" + customersResult.getString("username") + "</td>");
    out.print("<td>" + customersResult.getString("email") + "</td>");
    out.print("<td>" + customersResult.getInt("res_id") + "</td>");
    out.print("<td>" + customersResult.getInt("train_id") + "</td>");
    out.print("<td>" + route + "</td>");
    out.print("<td>" + String.format("%.2f", customersResult.getDouble("fare")) + "</td>");
    out.print("<td>$" + String.format("%.2f", customersResult.getDouble("total_fare")) + "</td>");
    out.print("<td>" + status.substring(0,1).toUpperCase() + status.substring(1) + "</td>");
    out.print("</tr>");
}

if (!hasCustomers) {
    out.print("<tr><td colspan='9'>No customers found with reservations on " + selectedLine + " for " + selectedDate + ".</td></tr>");
}
%>
</table>

<p><em>Tip: You can copy this data to Excel or print this page for your records.</em></p>

<% } %>

<%
conn.close();
%>

</body>
</html>