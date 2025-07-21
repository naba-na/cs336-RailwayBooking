<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Customer Representative Panel</title>
<style>
    .rep-container { max-width: 1200px; margin: 0 auto; padding: 20px; }
    .dashboard-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin: 20px 0; }
    .dashboard-card { border: 1px solid #ddd; padding: 20px; border-radius: 8px; background: #f9f9f9; }
    .dashboard-card h3 { margin-top: 0; color: #333; }
    .btn { display: inline-block; padding: 10px 15px; margin: 5px; background: #007cba; color: white; text-decoration: none; border-radius: 4px; }
    .btn:hover { background: #005a87; }
    .btn-success { background: #28a745; }
    .btn-success:hover { background: #218838; }
    .btn-warning { background: #ffc107; color: #212529; }
    .btn-warning:hover { background: #e0a800; }
    .stats-box { background: white; padding: 15px; margin: 10px 0; border-left: 4px solid #28a745; }
    .urgent { background: #fff3cd; border-left: 4px solid #856404; }
</style>
</head>
<body>
<%
    String username = (String) session.getAttribute("username");
    String acc_type = (String) session.getAttribute("acc_type");
    
    if (username == null || !"rep".equals(acc_type)) {
        response.sendRedirect("home.jsp");
        return;
    }
    
    bookingDB db = new bookingDB();
    Connection conn = db.getConnection();
    
    String statsQuery = "SELECT " +
                       "(SELECT COUNT(*) FROM reservations WHERE isActive = true) as active_reservations, " +
                       "(SELECT COUNT(*) FROM trains) as total_trains, " +
                       "(SELECT COUNT(*) FROM stations) as total_stations, " +
                       "(SELECT COUNT(*) FROM transitlines) as total_lines";
    
    PreparedStatement psStats = conn.prepareStatement(statsQuery);
    ResultSet statsResult = psStats.executeQuery();
    statsResult.next();
    
    int activeReservations = statsResult.getInt("active_reservations");
    int totalTrains = statsResult.getInt("total_trains");
    int totalStations = statsResult.getInt("total_stations");
    int totalLines = statsResult.getInt("total_lines");
    
    int pendingQuestions = 0;
    try {
        String questionQuery = "SELECT COUNT(*) as pending FROM customer_questions WHERE status = 'pending'";
        PreparedStatement psQuestions = conn.prepareStatement(questionQuery);
        ResultSet questionResult = psQuestions.executeQuery();
        if (questionResult.next()) {
            pendingQuestions = questionResult.getInt("pending");
        }
    } catch (Exception e) {
    }
    
    conn.close();
%>

<div class="rep-container">
    <h1>🎧 Customer Representative Dashboard</h1>
    <p>Welcome, <strong><%= username %></strong> | <a href="home.jsp">← Back to Home</a></p>
    
    <div class="dashboard-grid">
        <div class="stats-box">
            <h3>📊 System Overview</h3>
            <p><strong>Active Reservations:</strong> <%= activeReservations %></p>
            <p><strong>Total Trains:</strong> <%= totalTrains %></p>
            <p><strong>Total Stations:</strong> <%= totalStations %></p>
            <p><strong>Transit Lines:</strong> <%= totalLines %></p>
        </div>
        
        <% if (pendingQuestions > 0) { %>
        <div class="stats-box urgent">
            <h3>⚠️ Urgent</h3>
            <p><strong>Pending Customer Questions:</strong> <%= pendingQuestions %></p>
            <a href="manageQuestions.jsp" class="btn btn-warning">Review Questions</a>
        </div>
        <% } %>
    </div>
    
    <div class="dashboard-grid">
        
        <div class="dashboard-card">
            <h3>🚂 Train Schedule Management</h3>
            <p>Add, edit, and delete train schedules and routes.</p>
            <a href="manageSchedules.jsp" class="btn">Manage Schedules</a>
            <a href="addSchedule.jsp" class="btn btn-success">Add New Schedule</a>
        </div>
        
        <div class="dashboard-card">
            <h3>❓ Customer Support</h3>
            <p>Manage customer questions and provide answers.</p>
            <a href="manageQuestions.jsp" class="btn">Manage Questions</a>
            <a href="browseQuestions.jsp" class="btn">Browse Q&A</a>
            <% if (pendingQuestions > 0) { %>
                <span class="btn btn-warning"><%= pendingQuestions %> Pending</span>
            <% } %>
        </div>
        
        <div class="dashboard-card">
            <h3>🚉 Station Reports</h3>
            <p>Generate train schedules for specific stations.</p>
            <a href="stationSchedules.jsp" class="btn">Station Schedules</a>
        </div>
        
        <div class="dashboard-card">
            <h3>👥 Customer Reports</h3>
            <p>View customers with reservations on specific lines and dates.</p>
            <a href="customerReports.jsp" class="btn">Customer Reports</a>
        </div>
        
    </div>
</div>

</body>
</html>