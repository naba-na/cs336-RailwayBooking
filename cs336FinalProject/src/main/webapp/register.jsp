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
String firstname = request.getParameter("firstname");
String lastname = request.getParameter("lastname");
String email = request.getParameter("email");

String findUsername = "SELECT * FROM users WHERE username = ?";
PreparedStatement ps1 = conn.prepareStatement(findUsername);
ps1.setString(1, username);
ResultSet result1 = ps1.executeQuery();

String findEmail = "SELECT * FROM users WHERE email = ?";
PreparedStatement ps2 = conn.prepareStatement(findEmail);
ps2.setString(1, email);
ResultSet result2 = ps2.executeQuery();

if(!result1.isBeforeFirst() && !result2.isBeforeFirst()){
	String update = "INSERT INTO users(username, password, firstname, lastname, email) VALUES (?, ?, ?, ?, ?)";
	PreparedStatement ps3 = conn.prepareStatement(update);
	ps3.setString(1, username);
	ps3.setString(2, password);
	ps3.setString(3, firstname);
	ps3.setString(4, lastname);
	ps3.setString(5, email);
	int result3 = ps3.executeUpdate();
	
	if(result3 <= 0){
		out.println("Failed to register, please try again.");
	}else{
		out.println("Successfully registered, please log in.");
	}
	
}else if(result1.isBeforeFirst()){
	out.println("Username is already taken, please try again.");
}else{
	out.println("Email is already registered, please try again.");
}

conn.close();
%>
<br>
<a href="login.jsp">Return to Login</a>
</body>
</html>