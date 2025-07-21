<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page language="java" %>
<%@ page import="java.io.*,java.util.*,java.sql.*,java.time.*"%>
<html>
<head>
<title>View Reservations</title>
</head>
<body>
<%
bookingDB db = new bookingDB();
Connection conn = db.getConnection();

String username = (String) session.getAttribute("username");

String findUserID = "SELECT user_id FROM users WHERE username = ? LIMIT 1";
PreparedStatement psUsers = conn.prepareStatement(findUserID);
psUsers.setString(1, username);
ResultSet resultUsers = psUsers.executeQuery();
resultUsers.next();
String user_id = resultUsers.getString(1);

String getActiveRes = "SELECT * FROM reservations WHERE user_id = ? AND isActive = true";
PreparedStatement psARes = conn.prepareStatement(getActiveRes);
psARes.setString(1, user_id);
ResultSet resultARes = psARes.executeQuery();

String getPastRes = "SELECT * FROM reservations WHERE user_id = ? AND isActive = false";
PreparedStatement psPRes = conn.prepareStatement(getPastRes);
psPRes.setString(1, user_id);
ResultSet resultPRes = psPRes.executeQuery();
%>

<h1>Reservations</h1>

<h2>Active Reservations</h2>
<table border="1">

<tr>
<th>Reservation ID</th>
<th>Date Created</th>
<th>Your ID</th>
<th>Date Reserved</th>
<th>Time of Departure</th>
<th>Time of Arrival</th>
<th>Line Name</th>
<th>Origin Station</th>
<th>Origin Stop ID</th>
<th>Destination Station</th>
<th>Destination Stop ID</th>
<th>Total Fare</th>
<th>Currently Active</th>
<th></th>
<th></th>
</tr>

<%
if(!resultARes.isBeforeFirst()){
	out.print("<tr><td colspan='15'>No active reservations!</td></tr>");
}else{
	while(resultARes.next()){
		out.print("<tr>");
		for(int i = 1; i <= 13; i++){
			out.print("<td>");
			out.print(resultARes.getString(i));
			out.print("</td>");
		}	
		out.print("<td></td><td></td>");
		out.print("</tr>");
	}
}
%>
</table>

<h2>Past Reservations</h2>
<table border="1">

<tr>
<th>Reservation ID</th>
<th>Date Created</th>
<th>Your ID</th>
<th>Date Reserved</th>
<th>Time of Departure</th>
<th>Time of Arrival</th>
<th>Line Name</th>
<th>Origin Station</th>
<th>Origin Stop ID</th>
<th>Destination Station</th>
<th>Destination Stop ID</th>
<th>Total Fare</th>
<th>Currently Active</th>
<th></th>
<th></th>
</tr>

<%
if(!resultPRes.isBeforeFirst()){
	out.print("<tr><td colspan='15'>No past reservations!</td></tr>");
}else{
	while(resultPRes.next()){
		out.print("<tr>");
		for(int i = 1; i <= 13; i++){
			out.print("<td>");
			out.print(resultPRes.getString(i));
			out.print("</td>");
		}	
		out.print("<td></td><td></td>");
		out.print("</tr>");
	}
}

conn.close();
%>

</table>

<form action="cancelReservation.jsp" method="post">
	Enter ID of reservation you want to cancel: <input type="text" name="resID" required>
	<input type="submit" value="Cancel Reservation">
</form>

<a href="home.jsp">back to home</a>
	
</body>
</html>