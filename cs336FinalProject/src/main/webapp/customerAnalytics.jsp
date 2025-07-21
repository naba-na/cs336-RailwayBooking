<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Best Customer Analytics</title>
<style>
    .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
    table { border-collapse: collapse; width: 100%; margin: 20px 0; }
    th, td { border: 1px solid #ddd; padding: 10px; text-align: left; }
    th { background-color: #f2f2f2; }
    .winner-card { background: linear-gradient(135deg, #FFD700, #FFA500); padding: 20px; border-radius: 8px; margin: 20px 0; text-align: center; }
    .podium { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin: 20px 0; }
    .podium-card { padding: 15px; border-radius: 8px; text-align: center; }
    .first-place { background: linear-gradient(135deg, #FFD700, #FFA500); }
    .second-place { background: linear-gradient(135deg, #C0C0C0, #A9A9A9); }
    .third-place { background: linear-gradient(135deg, #CD7F32, #B87333); }
    .metric-card { background: #e7f3ff; padding: 15px; border-radius: 8px; margin: 10px 0; }
    .rank { font-size: 18px; font-weight: bold; }
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
    <h1>🌟 Best Customer Analytics</h1>
    <p><a href="adminPanel.jsp">← Back to Admin Panel</a></p>
    
    <%
    String bestCustomerQuery = "SELECT u.firstname, u.lastname, u.username, u.email, " +
                              "COUNT(r.res_id) as total_bookings, " +
                              "COUNT(CASE WHEN r.status = 'active' THEN 1 END) as active_bookings, " +
                              "SUM(CASE WHEN r.status = 'active' THEN r.total_fare ELSE 0 END) as total_revenue, " +
                              "AVG(CASE WHEN r.status = 'active' THEN r.total_fare END) as avg_fare, " +
                              "MIN(r.booking_date) as first_booking, " +
                              "MAX(r.booking_date) as last_booking, " +
                              "COUNT(DISTINCT t.line_name) as lines_used " +
                              "FROM users u " +
                              "JOIN reservations r ON u.user_id = r.user_id " +
                              "JOIN trains t ON r.train_id = t.train_id " +
                              "GROUP BY u.user_id, u.firstname, u.lastname, u.username, u.email " +
                              "HAVING total_revenue > 0 " +
                              "ORDER BY total_revenue DESC, total_bookings DESC " +
                              "LIMIT 1";
    
    PreparedStatement psBest = conn.prepareStatement(bestCustomerQuery);
    ResultSet bestResult = psBest.executeQuery();
    
    if (bestResult.next()) {
        String bestCustomerName = bestResult.getString("firstname") + " " + bestResult.getString("lastname");
        double bestRevenue = bestResult.getDouble("total_revenue");
        int bestBookings = bestResult.getInt("total_bookings");
    %>
    
    <div class="winner-card">
        <h2>🏆 BEST CUSTOMER OVERALL</h2>
        <h3><%= bestCustomerName %> (<%= bestResult.getString("username") %>)</h3>
        <p><strong>Total Revenue Generated:</strong> $<%= String.format("%.2f", bestRevenue) %></p>
        <p><strong>Total Bookings:</strong> <%= bestBookings %> | <strong>Active:</strong> <%= bestResult.getInt("active_bookings") %></p>
        <p><strong>Customer Since:</strong> <%= bestResult.getTimestamp("first_booking") %></p>
        <p><strong>Lines Used:</strong> <%= bestResult.getInt("lines_used") %> | <strong>Average Fare:</strong> $<%= String.format("%.2f", bestResult.getDouble("avg_fare")) %></p>
    </div>
    <% } %>
    
    <%
    String topThreeQuery = "SELECT u.firstname, u.lastname, u.username, " +
                          "COUNT(r.res_id) as total_bookings, " +
                          "SUM(CASE WHEN r.status = 'active' THEN r.total_fare ELSE 0 END) as total_revenue, " +
                          "COUNT(DISTINCT t.line_name) as lines_used " +
                          "FROM users u " +
                          "JOIN reservations r ON u.user_id = r.user_id " +
                          "JOIN trains t ON r.train_id = t.train_id " +
                          "GROUP BY u.user_id, u.firstname, u.lastname, u.username " +
                          "HAVING total_revenue > 0 " +
                          "ORDER BY total_revenue DESC, total_bookings DESC " +
                          "LIMIT 3";
    
    PreparedStatement psTopThree = conn.prepareStatement(topThreeQuery);
    ResultSet topThreeResult = psTopThree.executeQuery();
    
    String[] places = {"first-place", "second-place", "third-place"};
    String[] medals = {"🥇", "🥈", "🥉"};
    int place = 0;
    %>
    
    <h2>🏆 Top 3 Customers</h2>
    <div class="podium">
        <%
        while(topThreeResult.next() && place < 3) {
            String customerName = topThreeResult.getString("firstname") + " " + topThreeResult.getString("lastname");
            double revenue = topThreeResult.getDouble("total_revenue");
            int bookings = topThreeResult.getInt("total_bookings");
            
            out.println("<div class='podium-card " + places[place] + "'>");
            out.println("<div class='rank'>" + medals[place] + " #" + (place + 1) + "</div>");
            out.println("<h4>" + customerName + "</h4>");
            out.println("<p>$" + String.format("%.2f", revenue) + "</p>");
            out.println("<p>" + bookings + " bookings</p>");
            out.println("</div>");
            place++;
        }
        %>
    </div>
    
    <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; margin: 30px 0;">
        
        <%
        String frequentQuery = "SELECT u.firstname, u.lastname, u.username, " +
                              "COUNT(r.res_id) as booking_count, " +
                              "SUM(CASE WHEN r.status = 'active' THEN r.total_fare ELSE 0 END) as total_spent " +
                              "FROM users u " +
                              "JOIN reservations r ON u.user_id = r.user_id " +
                              "GROUP BY u.user_id, u.firstname, u.lastname, u.username " +
                              "ORDER BY booking_count DESC " +
                              "LIMIT 1";
        
        PreparedStatement psFrequent = conn.prepareStatement(frequentQuery);
        ResultSet frequentResult = psFrequent.executeQuery();
        
        if (frequentResult.next()) {
        %>
        <div class="metric-card">
            <h3>🚄 Most Frequent Traveler</h3>
            <p><strong><%= frequentResult.getString("firstname") %> <%= frequentResult.getString("lastname") %></strong></p>
            <p><%= frequentResult.getInt("booking_count") %> total bookings</p>
            <p>Total spent: $<%= String.format("%.2f", frequentResult.getDouble("total_spent")) %></p>
        </div>
        <% } %>
        
        <%
        String highestBookingQuery = "SELECT u.firstname, u.lastname, u.username, r.total_fare, r.booking_date, " +
                                    "t.line_name " +
                                    "FROM users u " +
                                    "JOIN reservations r ON u.user_id = r.user_id " +
                                    "JOIN trains t ON r.train_id = t.train_id " +
                                    "WHERE r.status = 'active' " +
                                    "ORDER BY r.total_fare DESC " +
                                    "LIMIT 1";
        
        PreparedStatement psHighest = conn.prepareStatement(highestBookingQuery);
        ResultSet highestResult = psHighest.executeQuery();
        
        if (highestResult.next()) {
        %>
        <div class="metric-card">
            <h3>💎 Highest Single Booking</h3>
            <p><strong><%= highestResult.getString("firstname") %> <%= highestResult.getString("lastname") %></strong></p>
            <p>$<%= String.format("%.2f", highestResult.getDouble("total_fare")) %></p>
            <p><%= highestResult.getString("line_name") %> | <%= highestResult.getTimestamp("booking_date") %></p>
        </div>
        <% } %>
        
        <%
        String loyalQuery = "SELECT u.firstname, u.lastname, u.username, " +
                           "MIN(r.booking_date) as first_booking, " +
                           "COUNT(r.res_id) as total_bookings, " +
                           "SUM(CASE WHEN r.status = 'active' THEN r.total_fare ELSE 0 END) as total_spent " +
                           "FROM users u " +
                           "JOIN reservations r ON u.user_id = r.user_id " +
                           "GROUP BY u.user_id, u.firstname, u.lastname, u.username " +
                           "ORDER BY first_booking ASC " +
                           "LIMIT 1";
        
        PreparedStatement psLoyal = conn.prepareStatement(loyalQuery);
        ResultSet loyalResult = psLoyal.executeQuery();
        
        if (loyalResult.next()) {
        %>
        <div class="metric-card">
            <h3>💝 Most Loyal Customer</h3>
            <p><strong><%= loyalResult.getString("firstname") %> <%= loyalResult.getString("lastname") %></strong></p>
            <p>Customer since: <%= loyalResult.getTimestamp("first_booking") %></p>
            <p><%= loyalResult.getInt("total_bookings") %> bookings | $<%= String.format("%.2f", loyalResult.getDouble("total_spent")) %> spent</p>
        </div>
        <% } %>
        
        <%
        String diverseQuery = "SELECT u.firstname, u.lastname, u.username, " +
                             "COUNT(DISTINCT t.line_name) as lines_count, " +
                             "COUNT(r.res_id) as total_bookings, " +
                             "SUM(CASE WHEN r.status = 'active' THEN r.total_fare ELSE 0 END) as total_spent " +
                             "FROM users u " +
                             "JOIN reservations r ON u.user_id = r.user_id " +
                             "JOIN trains t ON r.train_id = t.train_id " +
                             "GROUP BY u.user_id, u.firstname, u.lastname, u.username " +
                             "ORDER BY lines_count DESC, total_bookings DESC " +
                             "LIMIT 1";
        
        PreparedStatement psDiverse = conn.prepareStatement(diverseQuery);
        ResultSet diverseResult = psDiverse.executeQuery();
        
        if (diverseResult.next()) {
        %>
        <div class="metric-card">
            <h3>🌍 Most Diverse Traveler</h3>
            <p><strong><%= diverseResult.getString("firstname") %> <%= diverseResult.getString("lastname") %></strong></p>
            <p>Used <%= diverseResult.getInt("lines_count") %> different transit lines</p>
            <p><%= diverseResult.getInt("total_bookings") %> bookings | $<%= String.format("%.2f", diverseResult.getDouble("total_spent")) %> spent</p>
        </div>
        <% } %>
    </div>
    
    <h2>📊 Top 15 Customers (Detailed)</h2>
    <table>
    <tr>
        <th>Rank</th>
        <th>Customer Name</th>
        <th>Username</th>
        <th>Total Revenue</th>
        <th>Total Bookings</th>
        <th>Active Bookings</th>
        <th>Average Fare</th>
        <th>Lines Used</th>
        <th>First Booking</th>
        <th>Last Booking</th>
    </tr>
    
    <%
    String detailedQuery = "SELECT u.firstname, u.lastname, u.username, " +
                          "COUNT(r.res_id) as total_bookings, " +
                          "COUNT(CASE WHEN r.status = 'active' THEN 1 END) as active_bookings, " +
                          "SUM(CASE WHEN r.status = 'active' THEN r.total_fare ELSE 0 END) as total_revenue, " +
                          "AVG(CASE WHEN r.status = 'active' THEN r.total_fare END) as avg_fare, " +
                          "COUNT(DISTINCT t.line_name) as lines_used, " +
                          "MIN(r.booking_date) as first_booking, " +
                          "MAX(r.booking_date) as last_booking " +
                          "FROM users u " +
                          "JOIN reservations r ON u.user_id = r.user_id " +
                          "JOIN trains t ON r.train_id = t.train_id " +
                          "GROUP BY u.user_id, u.firstname, u.lastname, u.username " +
                          "HAVING total_revenue > 0 " +
                          "ORDER BY total_revenue DESC, total_bookings DESC " +
                          "LIMIT 15";
    
    PreparedStatement psDetailed = conn.prepareStatement(detailedQuery);
    ResultSet detailedResult = psDetailed.executeQuery();
    
    int rank = 1;
    while(detailedResult.next()) {
        String fullName = detailedResult.getString("firstname") + " " + detailedResult.getString("lastname");
        String rankStyle = "";
        if (rank <= 3) {
            rankStyle = "style='background-color: #fff3cd; font-weight: bold;'";
        }
        
        out.print("<tr " + rankStyle + ">");
        out.print("<td>" + rank + "</td>");
        out.print("<td>" + fullName + "</td>");
        out.print("<td>" + detailedResult.getString("username") + "</td>");
        out.print("<td><strong>$" + String.format("%.2f", detailedResult.getDouble("total_revenue")) + "</strong></td>");
        out.print("<td>" + detailedResult.getInt("total_bookings") + "</td>");
        out.print("<td>" + detailedResult.getInt("active_bookings") + "</td>");
        out.print("<td>$" + String.format("%.2f", detailedResult.getDouble("avg_fare")) + "</td>");
        out.print("<td>" + detailedResult.getInt("lines_used") + "</td>");
        out.print("<td>" + detailedResult.getTimestamp("first_booking") + "</td>");
        out.print("<td>" + detailedResult.getTimestamp("last_booking") + "</td>");
        out.print("</tr>");
        rank++;
    }
    
    conn.close();
    %>
    </table>
</div>

</body>
</html>