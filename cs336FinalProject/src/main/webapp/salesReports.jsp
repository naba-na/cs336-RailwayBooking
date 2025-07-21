<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*,java.time.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Sales Reports</title>
<style>
    .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
    table { border-collapse: collapse; width: 100%; margin: 20px 0; }
    th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
    th { background-color: #f2f2f2; }
    .form-section { background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0; }
    .btn { background: #007cba; color: white; padding: 10px 15px; border: none; border-radius: 4px; cursor: pointer; }
    .btn:hover { background: #005a87; }
    .summary-card { background: #e7f3ff; padding: 15px; border-radius: 8px; margin: 15px 0; }
    select { padding: 8px; margin: 5px; border: 1px solid #ddd; border-radius: 4px; }
</style>
</head>
<body>
<%
    String username = (String) session.getAttribute("username");
    String acc_type = (String) session.getAttribute("acc_type");
    
    if (username == null || !"admin".equals(acc_type)) {
        response.sendRedirect("home.jsp");
        return;
    }
    
    String selectedMonth = request.getParameter("month");
    String selectedYear = request.getParameter("year");
    
    if (selectedMonth == null || selectedYear == null) {
        LocalDate now = LocalDate.now();
        selectedMonth = String.format("%02d", now.getMonthValue());
        selectedYear = String.valueOf(now.getYear());
    }
    
    bookingDB db = new bookingDB();
    Connection conn = db.getConnection();
%>

<div class="container">
    <h1>📈 Monthly Sales Reports</h1>
    <p><a href="adminPanel.jsp">← Back to Admin Panel</a></p>
    
    <div class="form-section">
        <h3>Select Report Period</h3>
        <form method="get">
            <select name="month" required>
                <% for (int i = 1; i <= 12; i++) { 
                    String monthValue = String.format("%02d", i);
                    String monthName = Month.of(i).name();
                    String selected = monthValue.equals(selectedMonth) ? "selected" : "";
                %>
                    <option value="<%= monthValue %>" <%= selected %>><%= monthName %></option>
                <% } %>
            </select>
            
            <select name="year" required>
                <% for (int year = 2020; year <= LocalDate.now().getYear() + 1; year++) { 
                    String selected = String.valueOf(year).equals(selectedYear) ? "selected" : "";
                %>
                    <option value="<%= year %>" <%= selected %>><%= year %></option>
                <% } %>
            </select>
            
            <button type="submit" class="btn">Generate Report</button>
        </form>
    </div>
    
    <%
    String startDate = selectedYear + "-" + selectedMonth + "-01";
    String endDate = selectedYear + "-" + selectedMonth + "-31";
    String monthName = Month.of(Integer.parseInt(selectedMonth)).name();
    
    String summaryQuery = "SELECT " +
                         "COUNT(r.res_id) as total_bookings, " +
                         "COUNT(CASE WHEN isActive = true THEN 1 END) as active_bookings, " +
                         "COUNT(CASE WHEN isActive = false THEN 1 END) as cancelled_bookings, " +
                         "SUM(CASE WHEN isActive = true THEN r.total_fare ELSE 0 END) as total_revenue, " +
                         "SUM(CASE WHEN isActive = false THEN r.total_fare ELSE 0 END) as cancelled_revenue, " +
                         "COUNT(DISTINCT r.user_id) as unique_customers " +
                         "FROM reservations r " +
                         "WHERE r.creationDate >= ? AND r.creationDate < DATE_ADD(?, INTERVAL 1 MONTH)";
    
    PreparedStatement psSummary = conn.prepareStatement(summaryQuery);
    psSummary.setString(1, startDate);
    psSummary.setString(2, startDate);
    ResultSet summaryResult = psSummary.executeQuery();
    summaryResult.next();
    
    int totalBookings = summaryResult.getInt("total_bookings");
    int activeBookings = summaryResult.getInt("active_bookings");
    int cancelledBookings = summaryResult.getInt("cancelled_bookings");
    double totalRevenue = summaryResult.getDouble("total_revenue");
    double cancelledRevenue = summaryResult.getDouble("cancelled_revenue");
    int uniqueCustomers = summaryResult.getInt("unique_customers");
    %>
    
    <div class="summary-card">
        <h3>📊 Sales Summary for <%= monthName %> <%= selectedYear %></h3>
        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px;">
            <div>
                <p><strong>Total Bookings:</strong> <%= totalBookings %></p>
                <p><strong>Active Bookings:</strong> <%= activeBookings %></p>
                <p><strong>Cancelled Bookings:</strong> <%= cancelledBookings %></p>
            </div>
            <div>
                <p><strong>Total Revenue:</strong> $<%= String.format("%.2f", totalRevenue) %></p>
                <p><strong>Cancelled Revenue:</strong> $<%= String.format("%.2f", cancelledRevenue) %></p>
                <p><strong>Net Revenue:</strong> $<%= String.format("%.2f", totalRevenue) %></p>
            </div>
            <div>
                <p><strong>Unique Customers:</strong> <%= uniqueCustomers %></p>
                <p><strong>Avg Revenue per Customer:</strong> $<%= uniqueCustomers > 0 ? String.format("%.2f", totalRevenue / uniqueCustomers) : "0.00" %></p>
                <p><strong>Cancellation Rate:</strong> <%= totalBookings > 0 ? String.format("%.1f%%", (cancelledBookings * 100.0) / totalBookings) : "0%" %></p>
            </div>
        </div>
    </div>
    
    <h3>🛤️ Sales by Transit Line</h3>
    <table>
    <tr>
        <th>Transit Line</th>
        <th>Total Bookings</th>
        <th>Active Bookings</th>
        <th>Cancelled Bookings</th>
        <th>Total Revenue</th>
        <th>Avg Fare</th>
    </tr>
    
    <%
    String lineQuery = "SELECT t.line_name, " +
                      "COUNT(r.res_id) as total_bookings, " +
                      "COUNT(CASE WHEN isActive = true THEN 1 END) as active_bookings, " +
                      "COUNT(CASE WHEN isActive = false THEN 1 END) as cancelled_bookings, " +
                      "SUM(CASE WHEN isActive = true THEN r.total_fare ELSE 0 END) as total_revenue, " +
                      "AVG(CASE WHEN isActive = true THEN r.total_fare END) as avg_fare " +
                      "FROM reservations r " +
                      "JOIN trains t ON r.line_name = t.line_name " +
                      "WHERE r.creationDate >= ? AND r.creationDate < DATE_ADD(?, INTERVAL 1 MONTH) " +
                      "GROUP BY t.line_name " +
                      "ORDER BY total_revenue DESC";
    
    PreparedStatement psLine = conn.prepareStatement(lineQuery);
    psLine.setString(1, startDate);
    psLine.setString(2, startDate);
    ResultSet lineResult = psLine.executeQuery();
    
    while(lineResult.next()) {
        out.print("<tr>");
        out.print("<td>" + lineResult.getString("line_name") + "</td>");
        out.print("<td>" + lineResult.getInt("total_bookings") + "</td>");
        out.print("<td>" + lineResult.getInt("active_bookings") + "</td>");
        out.print("<td>" + lineResult.getInt("cancelled_bookings") + "</td>");
        out.print("<td>$" + String.format("%.2f", lineResult.getDouble("total_revenue")) + "</td>");
        out.print("<td>$" + String.format("%.2f", lineResult.getDouble("avg_fare")) + "</td>");
        out.print("</tr>");
    }
    
    conn.close();
    %>
    </table>
</div>

</body>
</html>