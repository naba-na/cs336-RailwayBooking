<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<html>
<head>
<title>Admin Panel</title>
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
    
    String statsQuery = "SELECT " +
                       "(SELECT COUNT(*) FROM users u JOIN customers c ON u.user_id = c.user_id) as total_customers, " +
                       "(SELECT COUNT(*) FROM users u JOIN employees e ON u.user_id = e.user_id WHERE e.acc_type = 'rep') as total_reps, " +
                       "(SELECT COUNT(*) FROM reservations WHERE isActive = true) as active_reservations, " +
                       "(SELECT COUNT(*) FROM trains) as total_trains, " +
                       "(SELECT SUM(total_fare) FROM reservations WHERE isActive = true) as total_revenue";
    
    PreparedStatement psStats = conn.prepareStatement(statsQuery);
    ResultSet statsResult = psStats.executeQuery();
    statsResult.next();
    
    int totalCustomers = statsResult.getInt("total_customers");
    int totalReps = statsResult.getInt("total_reps");
    int activeReservations = statsResult.getInt("active_reservations");
    int totalTrains = statsResult.getInt("total_trains");
    double totalRevenue = statsResult.getDouble("total_revenue");
    
    conn.close();
%>

<h1>Admin Dashboard</h1>
<p>Welcome, <strong><%= username %></strong> | <a href="home.jsp">Back to Home</a></p>

<h2>System Overview</h2>
<p><strong>Total Customers:</strong> <%= totalCustomers %></p>
<p><strong>Customer Representatives:</strong> <%= totalReps %></p>
<p><strong>Active Reservations:</strong> <%= activeReservations %></p>
<p><strong>Total Trains:</strong> <%= totalTrains %></p>
<p><strong>Total Active Revenue:</strong> $<%= String.format("%.2f", totalRevenue) %></p>

<h2>Customer Representative Management</h2>
<p>Add, edit, and manage customer service representatives.</p>
<a href="manageReps.jsp">Manage Representatives</a> | 
<a href="addRep.jsp">Add New Rep</a>

<h2>Sales Reports</h2>
<p>Generate monthly sales reports and analytics.</p>
<a href="salesReports.jsp">Monthly Sales Reports</a>

<h2>Reservation Reports</h2>
<p>View reservations by transit line and customer.</p>
<a href="reservationReports.jsp">Reservation Reports</a>

<h2>Revenue Analysis</h2>
<p>Analyze revenue by transit line and customer.</p>
<a href="revenueReports.jsp">Revenue Reports</a>

<h2>Customer Analytics</h2>
<p>Find best customers and most active transit lines.</p>
<a href="customerAnalytics.jsp">Best Customers</a> | 
<a href="transitLineAnalytics.jsp">Top Transit Lines</a>

</body>
</html>