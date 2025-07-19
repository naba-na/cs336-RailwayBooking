<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page language="java" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
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
String username = request.getParameter("username");
String password = request.getParameter("password");

String select = "SELECT * FROM users WHERE username = ?";
PreparedStatement ps1 = conn.prepareStatement(select);
ps1.setString(1, username);
ResultSet result1 = ps1.executeQuery();

if(!result1.isBeforeFirst()){
	String update = "INSERT INTO users(username, password, isAdmin, isRep) VALUES (?, ?, false, false)";
	PreparedStatement ps2 = conn.prepareStatement(update);
	ps2.setString(1, username);
	ps2.setString(2, password);
	int result2 = ps2.executeUpdate();
	
	if(result2 <= 0){
		out.println("Failed to register, please try again.");
	}else{
		out.println("Successfully registered, please log in.");
	}
	
}else{
	out.println("Username is already taken, please try again.");
}


	


conn.close();
%>
<br>
<a href="login.jsp">back to login</a>
</body>
</html>