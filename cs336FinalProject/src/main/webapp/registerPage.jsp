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
	<h2>Register</h2>
    <form action="register.jsp" method="post">
        Username: <input type="text" name="username" required><br/>
        Password: <input type="password" name="password" required><br/>
        First Name: <input type="text" name="firstname" required><br/>
        Last Name: <input type="text" name="lastname" required><br/>
        Email: <input type="text" name="email" required><br/>
        
        <input type="submit" value="Register">
    </form>
    <p style="color:red;">${message}</p>
</body>
</html>