<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<html>
<head>
<title>Top 5 Most Active Transit Lines</title>
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

<h1>Top 5 Most Active Transit Lines</h1>
<p><a href="adminPanel.jsp">Back to Admin Panel</a></p>

<%
String topLineQuery = "SELECT t.line_name, tl.fare, tl.fareChild, tl.fareSenior, tl.fareDisabled, " +
                     "COUNT(r.res_id) as total_reservations, " +
                     "COUNT(CASE WHEN r.isActive = true THEN 1 END) as active_reservations, " +
                     "SUM(CASE WHEN r.isActive = true THEN r.total_fare ELSE 0 END) as total_revenue, " +
                     "COUNT(DISTINCT r.user_id) as unique_customers, " +
                     "COUNT(DISTINCT t.train_id) as train_count, " +
                     "AVG(CASE WHEN r.isActive = true THEN r.total_fare END) as avg_fare " +
                     "FROM trains t " +
                     "JOIN transitlines tl ON t.line_name = tl.line_name " +
                     "LEFT JOIN reservations r ON t.line_name = r.line_name " +
                     "GROUP BY t.line_name, tl.fare, tl.fareChild, tl.fareSenior, tl.fareDisabled " +
                     "ORDER BY total_reservations DESC, total_revenue DESC " +
                     "LIMIT 1";

PreparedStatement psTop = conn.prepareStatement(topLineQuery);
ResultSet topResult = psTop.executeQuery();

if (topResult.next()) {
    String topLineName = topResult.getString("line_name");
    int topReservations = topResult.getInt("total_reservations");
    double topRevenue = topResult.getDouble("total_revenue");
%>

<h2>#1 MOST ACTIVE TRANSIT LINE</h2>
<h3><%= topLineName %></h3>
<p><strong>Total Reservations:</strong> <%= topReservations %> | <strong>Revenue:</strong> $<%= String.format("%.2f", topRevenue) %></p>
<p><strong>Unique Customers:</strong> <%= topResult.getInt("unique_customers") %> | <strong>Trains:</strong> <%= topResult.getInt("train_count") %></p>
<p><strong>Average Fare:</strong> $<%= String.format("%.2f", topResult.getDouble("avg_fare")) %></p>

<% } %>

<%
String top5Query = "SELECT t.line_name, " +
                  "COUNT(r.res_id) as total_reservations, " +
                  "COUNT(CASE WHEN r.isActive = true THEN 1 END) as active_reservations, " +
                  "SUM(CASE WHEN r.isActive = true THEN r.total_fare ELSE 0 END) as total_revenue, " +
                  "COUNT(DISTINCT r.user_id) as unique_customers, " +
                  "COUNT(DISTINCT t.train_id) as train_count " +
                  "FROM trains t " +
                  "LEFT JOIN reservations r ON t.line_name = r.line_name " +
                  "GROUP BY t.line_name " +
                  "ORDER BY total_reservations DESC, total_revenue DESC " +
                  "LIMIT 5";

PreparedStatement psTop5 = conn.prepareStatement(top5Query);
ResultSet top5Result = psTop5.executeQuery();

String[] medals = {"#1", "#2", "#3", "#4", "#5"};
int rank = 0;
%>

<h2>Top 5 Transit Lines</h2>
<table border="1">
<tr>
    <th>Rank</th>
    <th>Transit Line</th>
    <th>Reservations</th>
    <th>Revenue</th>
    <th>Customers</th>
</tr>
<%
while(top5Result.next() && rank < 5) {
    String lineName = top5Result.getString("line_name");
    int reservations = top5Result.getInt("total_reservations");
    double revenue = top5Result.getDouble("total_revenue");
    
    out.println("<tr>");
    out.println("<td>" + medals[rank] + "</td>");
    out.println("<td>" + lineName + "</td>");
    out.println("<td>" + reservations + "</td>");
    out.println("<td>$" + String.format("%.2f", revenue) + "</td>");
    out.println("<td>" + top5Result.getInt("unique_customers") + "</td>");
    out.println("</tr>");
    rank++;
}
%>
</table>

<%
String highestRevenueQuery = "SELECT t.line_name, " +
                            "SUM(CASE WHEN r.isActive = true THEN r.total_fare ELSE 0 END) as total_revenue, " +
                            "COUNT(CASE WHEN r.isActive = true THEN 1 END) as active_reservations " +
                            "FROM trains t " +
                            "LEFT JOIN reservations r ON t.line_name = r.line_name " +
                            "GROUP BY t.line_name " +
                            "HAVING total_revenue > 0 " +
                            "ORDER BY total_revenue DESC " +
                            "LIMIT 1";

PreparedStatement psRevenue = conn.prepareStatement(highestRevenueQuery);
ResultSet revenueResult = psRevenue.executeQuery();

if (revenueResult.next()) {
%>
<h3>Highest Revenue Line</h3>
<p><strong><%= revenueResult.getString("line_name") %></strong></p>
<p>$<%= String.format("%.2f", revenueResult.getDouble("total_revenue")) %></p>
<p><%= revenueResult.getInt("active_reservations") %> active reservations</p>
<% } %>

<%
String expensiveQuery = "SELECT line_name, fare, fareChild, fareSenior, fareDisabled " +
                       "FROM transitlines " +
                       "ORDER BY fare DESC " +
                       "LIMIT 1";

PreparedStatement psExpensive = conn.prepareStatement(expensiveQuery);
ResultSet expensiveResult = psExpensive.executeQuery();

if (expensiveResult.next()) {
%>
<h3>Most Expensive Line</h3>
<p><strong><%= expensiveResult.getString("line_name") %></strong></p>
<p>Adult: $<%= String.format("%.2f", expensiveResult.getDouble("fare")) %></p>
<p>Child: $<%= String.format("%.2f", expensiveResult.getDouble("fareChild")) %></p>
<% } %>

<%
String ratioQuery = "SELECT t.line_name, " +
                   "COUNT(DISTINCT r.user_id) as unique_customers, " +
                   "COUNT(DISTINCT t.train_id) as train_count, " +
                   "ROUND(COUNT(DISTINCT r.user_id) / COUNT(DISTINCT t.train_id), 2) as customer_per_train " +
                   "FROM trains t " +
                   "LEFT JOIN reservations r ON t.line_name = r.line_name " +
                   "GROUP BY t.line_name " +
                   "HAVING train_count > 0 AND unique_customers > 0 " +
                   "ORDER BY customer_per_train DESC " +
                   "LIMIT 1";

PreparedStatement psRatio = conn.prepareStatement(ratioQuery);
ResultSet ratioResult = psRatio.executeQuery();

if (ratioResult.next()) {
%>
<h3>Best Efficiency</h3>
<p><strong><%= ratioResult.getString("line_name") %></strong></p>
<p><%= String.format("%.1f", ratioResult.getDouble("customer_per_train")) %> customers per train</p>
<p><%= ratioResult.getInt("unique_customers") %> customers | <%= ratioResult.getInt("train_count") %> trains</p>
<% } %>

<h2>All Transit Lines Performance</h2>
<table border="1">
<tr>
    <th>Rank</th>
    <th>Transit Line</th>
    <th>Total Reservations</th>
    <th>Active Reservations</th>
    <th>Total Revenue</th>
    <th>Unique Customers</th>
    <th>Trains</th>
    <th>Adult Fare</th>
    <th>Avg Revenue per Train</th>
    <th>Activity Score</th>
</tr>

<%
String allLinesQuery = "SELECT t.line_name, tl.fare, " +
                      "COUNT(r.res_id) as total_reservations, " +
                      "COUNT(CASE WHEN r.isActive = true THEN 1 END) as active_reservations, " +
                      "SUM(CASE WHEN r.isActive = true THEN r.total_fare ELSE 0 END) as total_revenue, " +
                      "COUNT(DISTINCT r.user_id) as unique_customers, " +
                      "COUNT(DISTINCT t.train_id) as train_count " +
                      "FROM trains t " +
                      "JOIN transitlines tl ON t.line_name = tl.line_name " +
                      "LEFT JOIN reservations r ON t.line_name = r.line_name " +
                      "GROUP BY t.line_name, tl.fare " +
                      "ORDER BY total_reservations DESC, total_revenue DESC";

PreparedStatement psAll = conn.prepareStatement(allLinesQuery);
ResultSet allResult = psAll.executeQuery();

int detailRank = 1;
while(allResult.next()) {
    double totalRevenue = allResult.getDouble("total_revenue");
    int trainCount = allResult.getInt("train_count");
    int totalReservations = allResult.getInt("total_reservations");
    int uniqueCustomers = allResult.getInt("unique_customers");
    
    double avgRevenuePerTrain = trainCount > 0 ? totalRevenue / trainCount : 0;
    
    double activityScore = (totalReservations * 0.4) + (uniqueCustomers * 0.3) + (totalRevenue * 0.003);
    
    out.print("<tr>");
    out.print("<td>" + detailRank + "</td>");
    out.print("<td>" + allResult.getString("line_name") + "</td>");
    out.print("<td>" + totalReservations + "</td>");
    out.print("<td>" + allResult.getInt("active_reservations") + "</td>");
    out.print("<td>$" + String.format("%.2f", totalRevenue) + "</td>");
    out.print("<td>" + uniqueCustomers + "</td>");
    out.print("<td>" + trainCount + "</td>");
    out.print("<td>$" + String.format("%.2f", allResult.getDouble("fare")) + "</td>");
    out.print("<td>$" + String.format("%.2f", avgRevenuePerTrain) + "</td>");
    out.print("<td>" + String.format("%.1f", activityScore) + "</td>");
    out.print("</tr>");
    detailRank++;
}

conn.close();
%>
</table>

<p><strong>Activity Score Calculation:</strong> (Total Reservations × 0.4) + (Unique Customers × 0.3) + (Total Revenue × 0.003)</p>
<p><em>This score helps identify the most active lines considering booking volume, customer diversity, and revenue generation.</em></p>

</body>
</html>