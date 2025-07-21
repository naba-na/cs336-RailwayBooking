<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Admin Panel</title>
<style>
    .admin-container { max-width: 1200px; margin: 0 auto; padding: 20px; }
    .dashboard-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin: 20px 0; }
    .dashboard-card { border: 1px solid #ddd; padding: 20px; border-radius: 8px; background: #f9f9f9; }
    .dashboard-card h3 { margin-top: 0; color: #333; }
    .btn { display: inline-block; padding: 10px 15px; margin: 5px; background: #007cba; color: white; text-decoration: none; border-radius: 4px; }
    .btn:hover { background: #005a87; }
    .btn-danger { background: #dc3545; }
    .btn-danger:hover { background: #c82333; }
    .btn-success { background: #28a745; }
    .btn-success:hover { background: #218838; }
    .stats-box { background: white; padding: 15px; margin: 10px 0; border-left: 4px solid #007cba; }
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

<div class="admin-container">
    <h1>🔧 Admin Dashboard</h1>
    <p>Welcome, <strong><%= username %></strong> | <a href="home.jsp">← Back to Home</a></p>
    
    <div class="dashboard-grid">
        <div class="stats-box">
            <h3>📊 System Overview</h3>
            <p><strong>Total Customers:</strong> <%= totalCustomers %></p>
            <p><strong>Customer Representatives:</strong> <%= totalReps %></p>
            <p><strong>Active Reservations:</strong> <%= activeReservations %></p>
            <p><strong>Total Trains:</strong> <%= totalTrains %></p>
            <p><strong>Total Active Revenue:</strong> $<%= String.format("%.2f", totalRevenue) %></p>
        </div>
    </div>
    
    <div class="dashboard-grid">
        
        <div class="dashboard-card">
            <h3>👥 Customer Representative Management</h3>
            <p>Add, edit, and manage customer service representatives.</p>
            <a href="manageReps.jsp" class="btn">Manage Representatives</a>
            <a href="addRep.jsp" class="btn btn-success">Add New Rep</a>
        </div>
        
        <div class="dashboard-card">
            <h3>📈 Sales Reports</h3>
            <p>Generate monthly sales reports and analytics.</p>
            <a href="salesReports.jsp" class="btn">Monthly Sales Reports</a>
        </div>
        
        <div class="dashboard-card">
            <h3>🎫 Reservation Reports</h3>
            <p>View reservations by transit line and customer.</p>
            <a href="reservationReports.jsp" class="btn">Reservation Reports</a>
        </div>
        
        <div class="dashboard-card">
            <h3>💰 Revenue Analysis</h3>
            <p>Analyze revenue by transit line and customer.</p>
            <a href="revenueReports.jsp" class="btn">Revenue Reports</a>
        </div>
        
        <div class="dashboard-card">
            <h3>🌟 Customer Analytics</h3>
            <p>Find best customers and most active transit lines.</p>
            <a href="customerAnalytics.jsp" class="btn">Best Customers</a>
            <a href="transitLineAnalytics.jsp" class="btn">Top Transit Lines</a>
        </div>
        
        <div class="dashboard-card">
            <h3>⚙️ System Management</h3>
            <p>Advanced system administration tools.</p>
            <a href="systemReports.jsp" class="btn">System Reports</a>
        </div>
        
    </div>
</div>

</body>
</html>