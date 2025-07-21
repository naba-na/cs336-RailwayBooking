<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Book Reservation</title>
</head>
<body>
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<h2>Book Reservation</h2>
<p><strong>Train:</strong> #<%= request.getParameter("train_id") %> (<%= request.getParameter("line_name") %>)</p>
<p><strong>From:</strong> <%= request.getParameter("origin") %></p>
<p><strong>To:</strong> <%= request.getParameter("destination") %></p>
<p><strong>Date:</strong> <%= request.getParameter("date") %></p>

<form action="processReservation.jsp" method="post">
    <input type="hidden" name="train_id" value="<%= request.getParameter("train_id") %>">
    <input type="hidden" name="origin" value="<%= request.getParameter("origin") %>">
    <input type="hidden" name="destination" value="<%= request.getParameter("destination") %>">
    <input type="hidden" name="date" value="<%= request.getParameter("date") %>">
    <input type="hidden" name="line_name" value="<%= request.getParameter("line_name") %>">
    
    Passenger Type: 
    <select name="passenger_type" required>
        <option value="adult">Adult</option>
        <option value="child">Child</option>
        <option value="senior">Senior</option>
        <option value="disabled">Disabled</option>
    </select><br><br>
    
    Trip Type:
    <input type="radio" name="trip_type" value="one_way" required> One Way
    <input type="radio" name="trip_type" value="round_trip" required> Round Trip<br><br>
    
    <input type="submit" value="Confirm Reservation">
</form>

<a href="home.jsp">Cancel</a>
</body>
</html>