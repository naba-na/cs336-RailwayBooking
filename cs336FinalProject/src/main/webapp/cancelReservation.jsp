<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page language="java" %>
<%@ page import="java.io.*,java.util.*,java.sql.*,java.time.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
<%
bookingDB db = new bookingDB();
Connection conn = db.getConnection();

String username = (String) session.getAttribute("username");
String resID = request.getParameter("resID");

String findUserID = "SELECT user_id FROM users WHERE username = ? LIMIT 1";
PreparedStatement psUsers = conn.prepareStatement(findUserID);
psUsers.setString(1, username);
ResultSet resultUsers = psUsers.executeQuery();
resultUsers.next();
String user_id = resultUsers.getString(1);

String findRes = "SELECT * FROM reservations WHERE resID = ? LIMIT 1";
PreparedStatement psRes = conn.prepareStatement(findRes);
psRes.setString(1, resID);
ResultSet resultRes = psRes.executeQuery();

if(!resultRes.isBeforeFirst()){
	out.print("Reservation not found, make sure the ID you entered is correct.");
}else{
	resultRes.next();
	String checkUserID = resultRes.getString(3);
	String reservationID = resultRes.getString(1);
	
	if(user_id != checkUserID){
		out.print("You do not have permission to cancel this reservation, please check if entered ID was correct.");
	}else{
		String cancelRes = "UPDATE reservations SET isActive = false WHERE res_id = ?";
		PreparedStatement psCRes = conn.prepareStatement(cancelRes);
		psCRes.setString(1, reservationID);
		int resultUpdate = psCRes.executeUpdate();
		if(resultUpdate > 1){
			out.print("Reservation successfully canceled.");
		}else{
			out.print("Error canceling reservation, please try again.");
		}
	}
}
%>

<a href="home.jsp">back to home</a>
</body>
</html>