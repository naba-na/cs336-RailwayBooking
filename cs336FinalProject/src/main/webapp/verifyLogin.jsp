<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page language="java" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>

<html>
	<body>
		<%

		bookingDB db = new bookingDB();
		Connection conn = db.getConnection();
		String username = request.getParameter("username");
		String password = request.getParameter("password");
		
		String select = "SELECT * FROM users WHERE username = '%s' AND password = '%s'"; // %s -> String.format()
		ResultSet result = conn.prepareStatement(String.format(select, username, password)).executeQuery();
		if (result.isBeforeFirst()) {
			out.println("Successfully logged in!");
			session.setAttribute("username", username);
		}
		else {
			out.println("Invalid login. Please check credentials or register for an account!");
		}
		conn.close();
		%>
			
	<a href="home.jsp">Click here to proceed to homepage</a>
	

	</body>
</html>
