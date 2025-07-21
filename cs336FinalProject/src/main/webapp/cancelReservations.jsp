<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<html>
<head>
<title>Cancel Reservation</title>
</head>
<body>
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String res_id = request.getParameter("res_id");
    
    if (res_id == null || res_id.trim().isEmpty()) {
        out.println("<h2>Error</h2>");
        out.println("<p>No reservation ID provided.</p>");
    } else {
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
            
            String verifyReservation = "SELECT r.res_id, r.res_date, r.train_id, t.line_name, r.total_fare, " +
                                     "st_origin.station_name as origin_station, st_dest.station_name as dest_station " +
                                     "FROM reservations r " +
                                     "JOIN trains t ON r.train_id = t.train_id " +
                                     "JOIN stops s_origin ON r.origin_stop_id = s_origin.stop_id " +
                                     "JOIN stops s_dest ON r.dest_stop_id = s_dest.stop_id " +
                                     "JOIN stations st_origin ON s_origin.station_id = st_origin.station_id " +
                                     "JOIN stations st_dest ON s_dest.station_id = st_dest.station_id " +
                                     "WHERE r.res_id = ? AND r.user_id = ? AND r.status = 'active'";
            
            PreparedStatement psVerify = conn.prepareStatement(verifyReservation);
            psVerify.setString(1, res_id);
            psVerify.setInt(2, user_id);
            ResultSet verifyResult = psVerify.executeQuery();
            
            if (!verifyResult.next()) {
                throw new Exception("Reservation not found or already cancelled");
            }
            
            String line_name = verifyResult.getString("line_name");
            String origin_station = verifyResult.getString("origin_station");
            String dest_station = verifyResult.getString("dest_station");
            String res_date = verifyResult.getString("res_date");
            int train_id = verifyResult.getInt("train_id");
            double total_fare = verifyResult.getDouble("total_fare");
            
            String cancelReservation = "UPDATE reservations SET status = 'cancelled' WHERE res_id = ? AND user_id = ?";
            PreparedStatement psCancel = conn.prepareStatement(cancelReservation);
            psCancel.setString(1, res_id);
            psCancel.setInt(2, user_id);
            
            int rowsAffected = psCancel.executeUpdate();
            
            if (rowsAffected > 0) {
                out.println("<h2>Reservation Cancelled Successfully</h2>");
                out.println("<p><strong>Cancelled Reservation Details:</strong></p>");
                out.println("<p><strong>Reservation ID:</strong> " + res_id + "</p>");
                out.println("<p><strong>Train:</strong> #" + train_id + " (" + line_name + ")</p>");
                out.println("<p><strong>From:</strong> " + origin_station + "</p>");
                out.println("<p><strong>To:</strong> " + dest_station + "</p>");
                out.println("<p><strong>Travel Date:</strong> " + res_date + "</p>");
                out.println("<p><strong>Refund Amount:</strong> $" + String.format("%.2f", total_fare) + "</p>");
                out.println("<p><em>Your refund will be processed within 3-5 business days.</em></p>");
            } else {
                throw new Exception("Failed to cancel reservation");
            }
            
        } catch (Exception e) {
            out.println("<h2>Cancellation Failed</h2>");
            out.println("<p>Error: " + e.getMessage() + "</p>");
        } finally {
            conn.close();
        }
    }
%>

<p>
    <a href="viewReservations.jsp">View My Reservations</a> | 
    <a href="home.jsp">Return to Home</a>
</p>

</body>
</html>