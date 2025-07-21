<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<html>
<head>
<title>Reservation Confirmation</title>
</head>
<body>
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String train_id = request.getParameter("train_id");
    String origin = request.getParameter("origin");
    String destination = request.getParameter("destination");
    String date = request.getParameter("date");
    String passenger_type = request.getParameter("passenger_type");
    String trip_type = request.getParameter("trip_type");
    String line_name = request.getParameter("line_name");
    
    bookingDB db = new bookingDB();
    Connection conn = db.getConnection();
    
    try {
        String getUserId = "SELECT user_id FROM users WHERE username = ?";
        PreparedStatement psUser = conn.prepareStatement(getUserId);
        psUser.setString(1, username);
        ResultSet userResult = psUser.executeQuery();
        
        if (!userResult.next()) {
            throw new Exception("User not found");
        }
        int user_id = userResult.getInt("user_id");
        
        String getStopIds = "SELECT " +
                          "(SELECT s1.stop_id FROM stops s1 " +
                          " JOIN stations st1 ON s1.station_id = st1.station_id " +
                          " JOIN TransitLines_Contains_Stops tcs1 ON s1.stop_id = tcs1.stop_id " +
                          " WHERE st1.station_name = ? AND tcs1.line_name = ?) as origin_stop_id, " +
                          "(SELECT s2.stop_id FROM stops s2 " +
                          " JOIN stations st2 ON s2.station_id = st2.station_id " +
                          " JOIN TransitLines_Contains_Stops tcs2 ON s2.stop_id = tcs2.stop_id " +
                          " WHERE st2.station_name = ? AND tcs2.line_name = ?) as dest_stop_id";
        
        PreparedStatement psStops = conn.prepareStatement(getStopIds);
        psStops.setString(1, origin);
        psStops.setString(2, line_name);
        psStops.setString(3, destination);
        psStops.setString(4, line_name);
        ResultSet stopResult = psStops.executeQuery();
        
        if (!stopResult.next()) {
            throw new Exception("Could not find stops for this route");
        }
        
        int origin_stop_id = stopResult.getInt("origin_stop_id");
        int dest_stop_id = stopResult.getInt("dest_stop_id");
        
        String getFare = "SELECT fare, fareChild, fareSenior, fareDisabled FROM transitlines WHERE line_name = ?";
        PreparedStatement psFare = conn.prepareStatement(getFare);
        psFare.setString(1, line_name);
        ResultSet fareResult = psFare.executeQuery();
        
        if (!fareResult.next()) {
            throw new Exception("Could not find fare information");
        }
        
        double baseFare = 0;
        switch(passenger_type) {
            case "adult": baseFare = fareResult.getDouble("fare"); break;
            case "child": baseFare = fareResult.getDouble("fareChild"); break;
            case "senior": baseFare = fareResult.getDouble("fareSenior"); break;
            case "disabled": baseFare = fareResult.getDouble("fareDisabled"); break;
            default: baseFare = fareResult.getDouble("fare");
        }
        
        double total_fare = baseFare;
        if ("round_trip".equals(trip_type)) {
            total_fare = baseFare * 2;
        }
        
        String insertReservation = "INSERT INTO reservations (res_date, user_id, train_id, origin_stop_id, dest_stop_id, passenger_type, total_fare, status) " +
                                  "VALUES (?, ?, ?, ?, ?, ?, ?, 'active')";
        
        PreparedStatement psInsert = conn.prepareStatement(insertReservation, Statement.RETURN_GENERATED_KEYS);
        psInsert.setString(1, date);
        psInsert.setInt(2, user_id);
        psInsert.setString(3, train_id);
        psInsert.setInt(4, origin_stop_id);
        psInsert.setInt(5, dest_stop_id);
        psInsert.setString(6, passenger_type);
        psInsert.setDouble(7, total_fare);
        
        int rowsAffected = psInsert.executeUpdate();
        
        if (rowsAffected > 0) {
            ResultSet generatedKeys = psInsert.getGeneratedKeys();
            generatedKeys.next();
            int reservation_id = generatedKeys.getInt(1);
            
            out.println("<h2>Reservation Confirmed!</h2>");
            out.println("<p><strong>Reservation ID:</strong> " + reservation_id + "</p>");
            out.println("<p><strong>Train:</strong> #" + train_id + " (" + line_name + ")</p>");
            out.println("<p><strong>From:</strong> " + origin + "</p>");
            out.println("<p><strong>To:</strong> " + destination + "</p>");
            out.println("<p><strong>Date:</strong> " + date + "</p>");
            out.println("<p><strong>Passenger Type:</strong> " + passenger_type.substring(0,1).toUpperCase() + passenger_type.substring(1) + "</p>");
            out.println("<p><strong>Trip Type:</strong> " + (trip_type.equals("round_trip") ? "Round Trip" : "One Way") + "</p>");
            out.println("<p><strong>Total Fare:</strong> $" + String.format("%.2f", total_fare) + "</p>");
        } else {
            throw new Exception("Failed to create reservation");
        }
        
    } catch (Exception e) {
        out.println("<h2>Reservation Failed</h2>");
        out.println("<p>Error: " + e.getMessage() + "</p>");
    } finally {
        conn.close();
    }
%>

<p>
    <a href="viewReservations.jsp">View My Reservations</a> | 
    <a href="home.jsp">Return to Home</a>
</p>

</body>
</html>