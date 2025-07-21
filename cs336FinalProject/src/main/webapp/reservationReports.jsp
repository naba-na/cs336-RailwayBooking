<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Reservation Reports</title>
<style>
    .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
    table { border-collapse: collapse; width: 100%; margin: 20px 0; }
    th, td { border: 1px solid #ddd; padding: 8px; text-align: left; font-size: 12px; }
    th { background-color: #f2f2f2; }
    .form-section { background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0; }
    .btn { background: #007cba; color: white; padding: 10px 15px; border: none; border-radius: 4px; cursor: pointer; }
    .btn:hover { background: #005a87; }
    select, input { padding: 8px; margin: 5px; border: 1px solid #ddd; border-radius: 4px; }
    .report-tabs { display: flex; margin: 20px 0; }
    .tab { padding: 10px 20px; background: #e9ecef; margin-right: 5px; cursor: pointer; border-radius: 4px 4px 0 0; }
    .tab.active { background: #007cba; color: white; }
    .tab-content { display: none; }
    .tab-content.active { display: block; }
</style>
<script>
function showTab(tabName) {
    var contents = document.getElementsByClassName('tab-content');
    for (var i = 0; i < contents.length; i++) {
        contents[i].classList.remove('active');
    }
    
    var tabs = document.getElementsByClassName('tab');
    for (var i = 0; i < tabs.length; i++) {
        tabs[i].classList.remove('active');
    }
    
    document.getElementById(tabName).classList.add('active');
    event.target.classList.add('active');
}
</script>
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

<div class="container">
    <h1>🎫 Reservation Reports</h1>
    <p><a href="adminPanel.jsp">← Back to Admin Panel</a></p>
    
    <div class="report-tabs">
        <div class="tab active" onclick="showTab('byTransitLine')">By Transit Line</div>
        <div class="tab" onclick="showTab('byCustomer')">By Customer Name</div>
    </div>
    
    <div id="byTransitLine" class="tab-content active">
        <div class="form-section">
            <h3>🛤️ Reservations by Transit Line</h3>
            <form method="get" action="#byTransitLine">
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
                <button type="submit" class="btn">Generate Report</button>
            </form>
        </div>
        
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
        
        <h4>📋 Results</h4>
        <table>
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
            String rowClass = "cancelled".equals(status) ? "style='background-color: #ffe8e8;'" : "";
            
            out.print("<tr " + rowClass + ">");
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
    </div>
    
    <div id="byCustomer" class="tab-content">
        <div class="form-section">
            <h3>👤 Reservations by Customer Name</h3>
            <form method="get" action="#byCustomer">
                <input type="hidden" name="reportType" value="customer">
                <input type="text" name="customerName" placeholder="Enter customer name (first or last)" value="<%= request.getParameter("customerName") != null ? request.getParameter("customerName") : "" %>">
                <button type="submit" class="btn">Search</button>
            </form>
        </div>
        
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
        
        <h4>📋 Results</h4>
        <table>
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
            String rowClass = "cancelled".equals(status) ? "style='background-color: #ffe8e8;'" : "";
            
            out.print("<tr " + rowClass + ">");
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
    </div>
    
    <%
    conn.close();
    %>
</div>

</body>
</html>