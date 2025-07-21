<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Top 5 Most Active Transit Lines</title>
<style>
    .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
    table { border-collapse: collapse; width: 100%; margin: 20px 0; }
    th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
    th { background-color: #f2f2f2; }
    .winner-card { background: linear-gradient(135deg, #28a745, #20c997); padding: 20px; border-radius: 8px; margin: 20px 0; text-align: center; color: white; }
    .podium { display: grid; grid-template-columns: repeat(5, 1fr); gap: 15px; margin: 20px 0; }
    .podium-card { padding: 15px; border-radius: 8px; text-align: center; }
    .rank-1 { background: linear-gradient(135deg, #FFD700, #FFA500); }
    .rank-2 { background: linear-gradient(135deg, #C0C0C0, #A9A9A9); }
    .rank-3 { background: linear-gradient(135deg, #CD7F32, #B87333); }
    .rank-4 { background: linear-gradient(135deg, #87CEEB, #4682B4); }
    .rank-5 { background: linear-gradient(135deg, #DDA0DD, #9370DB); }
    .metric-card { background: #e7f3ff; padding: 15px; border-radius: 8px; margin: 10px 0; }
    .stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin: 20px 0; }
    .rank-number { font-size: 24px; font-weight: bold; margin-bottom: 10px; }
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
    
    bookingDB db = new bookingDB();
    Connection conn = db.getConnection();
%>

<div class="container">
    <h1>🚂 Top 5 Most Active Transit Lines</h1>
    <p><a href="adminPanel.jsp">← Back to Admin Panel</a></p>
    
    <%
    String topLineQuery = "SELECT t.line_name, tl.fare, tl.fareChild, tl.fareSenior, tl.fareDisabled, " +
                         "COUNT(r.res_id) as total_reservations, " +
                         "COUNT(CASE WHEN r.status = 'active' THEN 1 END) as active_reservations, " +
                         "SUM(CASE WHEN r.status = 'active' THEN r.total_fare ELSE 0 END) as total_revenue, " +
                         "COUNT(DISTINCT r.user_id) as unique_customers, " +
                         "COUNT(DISTINCT t.train_id) as train_count, " +
                         "AVG(CASE WHEN r.status = 'active' THEN r.total_fare END) as avg_fare " +
                         "FROM trains t " +
                         "JOIN transitlines tl ON t.line_name = tl.line_name " +
                         "LEFT JOIN reservations r ON t.train_id = r.train_id " +
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
    
    <div class="winner-card">
        <h2>🏆 #1 MOST ACTIVE TRANSIT LINE</h2>
        <h3><%= topLineName %></h3>
        <p><strong>Total Reservations:</strong> <%= topReservations %> | <strong>Revenue:</strong> $<%= String.format("%.2f", topRevenue) %></p>
        <p><strong>Unique Customers:</strong> <%= topResult.getInt("unique_customers") %> | <strong>Trains:</strong> <%= topResult.getInt("train_count") %></p>
        <p><strong>Average Fare:</strong> $<%= String.format("%.2f", topResult.getDouble("avg_fare")) %></p>
    </div>
    <% } %>
    
    <%
    String top5Query = "SELECT t.line_name, " +
                      "COUNT(r.res_id) as total_reservations, " +
                      "COUNT(CASE WHEN r.status = 'active' THEN 1 END) as active_reservations, " +
                      "SUM(CASE WHEN r.status = 'active' THEN r.total_fare ELSE 0 END) as total_revenue, " +
                      "COUNT(DISTINCT r.user_id) as unique_customers, " +
                      "COUNT(DISTINCT t.train_id) as train_count " +
                      "FROM trains t " +
                      "LEFT JOIN reservations r ON t.train_id = r.train_id " +
                      "GROUP BY t.line_name " +
                      "ORDER BY total_reservations DESC, total_revenue DESC " +
                      "LIMIT 5";
    
    PreparedStatement psTop5 = conn.prepareStatement(top5Query);
    ResultSet top5Result = psTop5.executeQuery();
    
    String[] rankClasses = {"rank-1", "rank-2", "rank-3", "rank-4", "rank-5"};
    String[] medals = {"🥇", "🥈", "🥉", "🏅", "🎖️"};
    int rank = 0;
    %>
    
    <h2>🏆 Top 5 Transit Lines</h2>
    <div class="podium">
        <%
        while(top5Result.next() && rank < 5) {
            String lineName = top5Result.getString("line_name");
            int reservations = top5Result.getInt("total_reservations");
            double revenue = top5Result.getDouble("total_revenue");
            
            out.println("<div class='podium-card " + rankClasses[rank] + "'>");
            out.println("<div class='rank-number'>" + medals[rank] + " #" + (rank + 1) + "</div>");
            out.println("<h4>" + lineName + "</h4>");
            out.println("<p><strong>" + reservations + "</strong> reservations</p>");
            out.println("<p>$" + String.format("%.2f", revenue) + " revenue</p>");
            out.println("<p>" + top5Result.getInt("unique_customers") + " customers</p>");
            out.println("</div>");
            rank++;
        }
        %>
    </div>
    
    <div class="stats-grid">
        
        <%
        String highestRevenueQuery = "SELECT t.line_name, " +
                                    "SUM(CASE WHEN r.status = 'active' THEN r.total_fare ELSE 0 END) as total_revenue, " +
                                    "COUNT(CASE WHEN r.status = 'active' THEN 1 END) as active_reservations " +
                                    "FROM trains t " +
                                    "LEFT JOIN reservations r ON t.train_id = r.train_id " +
                                    "GROUP BY t.line_name " +
                                    "HAVING total_revenue > 0 " +
                                    "ORDER BY total_revenue DESC " +
                                    "LIMIT 1";
        
        PreparedStatement psRevenue = conn.prepareStatement(highestRevenueQuery);
        ResultSet revenueResult = psRevenue.executeQuery();
        
        if (revenueResult.next()) {
        %>
        <div class="metric-card">
            <h3>💰 Highest Revenue Line</h3>
            <p><strong><%= revenueResult.getString("line_name") %></strong></p>
            <p>$<%= String.format("%.2f", revenueResult.getDouble("total_revenue")) %></p>
            <p><%= revenueResult.getInt("active_reservations") %> active reservations</p>
        </div>
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
        <div class="metric-card">
            <h3>💎 Most Expensive Line</h3>
            <p><strong><%= expensiveResult.getString("line_name") %></strong></p>
            <p>Adult: $<%= String.format("%.2f", expensiveResult.getDouble("fare")) %></p>
            <p>Child: $<%= String.format("%.2f", expensiveResult.getDouble("fareChild")) %></p>
        </div>
        <% } %>
        
        <%
        String ratioQuery = "SELECT t.line_name, " +
                           "COUNT(DISTINCT r.user_id) as unique_customers, " +
                           "COUNT(DISTINCT t.train_id) as train_count, " +
                           "ROUND(COUNT(DISTINCT r.user_id) / COUNT(DISTINCT t.train_id), 2) as customer_per_train " +
                           "FROM trains t " +
                           "LEFT JOIN reservations r ON t.train_id = r.train_id " +
                           "GROUP BY t.line_name " +
                           "HAVING train_count > 0 AND unique_customers > 0 " +
                           "ORDER BY customer_per_train DESC " +
                           "LIMIT 1";
        
        PreparedStatement psRatio = conn.prepareStatement(ratioQuery);
        ResultSet ratioResult = psRatio.executeQuery();
        
        if (ratioResult.next()) {
        %>
        <div class="metric-card">
            <h3>⚡ Best Efficiency</h3>
            <p><strong><%= ratioResult.getString("line_name") %></strong></p>
            <p><%= String.format("%.1f", ratioResult.getDouble("customer_per_train")) %> customers per train</p>
            <p><%= ratioResult.getInt("unique_customers") %> customers | <%= ratioResult.getInt("train_count") %> trains</p>
        </div>
        <% } %>
    </div>
    
    <h2>📊 All Transit Lines Performance</h2>
    <table>
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
                          "COUNT(CASE WHEN r.status = 'active' THEN 1 END) as active_reservations, " +
                          "SUM(CASE WHEN r.status = 'active' THEN r.total_fare ELSE 0 END) as total_revenue, " +
                          "COUNT(DISTINCT r.user_id) as unique_customers, " +
                          "COUNT(DISTINCT t.train_id) as train_count " +
                          "FROM trains t " +
                          "JOIN transitlines tl ON t.line_name = tl.line_name " +
                          "LEFT JOIN reservations r ON t.train_id = r.train_id " +
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
        
        String rankStyle = "";
        if (detailRank <= 5) {
            rankStyle = "style='background-color: #fff3cd; font-weight: bold;'";
        }
        
        out.print("<tr " + rankStyle + ">");
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
    
    <div style="margin: 20px 0; padding: 15px; background: #f8f9fa; border-radius: 8px;">
        <p><strong>Activity Score Calculation:</strong> (Total Reservations × 0.4) + (Unique Customers × 0.3) + (Total Revenue × 0.003)</p>
        <p><em>This score helps identify the most active lines considering booking volume, customer diversity, and revenue generation.</em></p>
    </div>
</div>

</body>
</html>