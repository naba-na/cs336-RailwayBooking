<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<html>
<head>
<title>Customer Representative Panel</title>
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

<h1>Customer Representative Dashboard</h1>
<p>Welcome, <strong><%= username %></strong> | <a href="home.jsp">Back to Home</a></p>

<h2>System Overview</h2>
<p><strong>Active Reservations:</strong> <%= activeReservations %></p>
<p><strong>Total Trains:</strong> <%= totalTrains %></p>
<p><strong>Total Stations:</strong> <%= totalStations %></p>
<p><strong>Transit Lines:</strong> <%= totalLines %></p>

<% if (pendingQuestions > 0) { %>
<p><strong>Pending Customer Questions:</strong> <%= pendingQuestions %></p>
<% } %>

<h2>Train Schedule Management</h2>
<p>Add, edit, and delete train schedules and routes.</p>
<a href="manageSchedules.jsp">Manage Schedules</a> | 
<a href="addSchedule.jsp">Add New Schedule</a>

<h2>Customer Support</h2>
<p>Manage customer questions and provide answers.</p>
<a href="manageQuestions.jsp">Manage Questions</a> | 
<a href="browseQuestions.jsp">Browse Q&A</a>
<% if (pendingQuestions > 0) { %>
    <p><%= pendingQuestions %> questions pending</p>
<% } %>

<h2>Station Reports</h2>
<p>Generate train schedules for specific stations.</p>
<a href="stationSchedules.jsp">Station Schedules</a>

<h2>Customer Reports</h2>
<p>View customers with reservations on specific lines and dates.</p>
<a href="customerReports.jsp">Customer Reports</a>

</body>
</html>