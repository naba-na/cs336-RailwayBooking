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
		
		String select = "SELECT user_id FROM users where username = '" + username + "' AND password = '" + password + "'";
		ResultSet result = conn.prepareStatement(select).executeQuery();
		if (result.isBeforeFirst()) {
			out.println("Successfully logged in!");
			session.setAttribute("username", username);
			//Get account type and save to session
			result.next();
			int user_id = result.getInt("user_id");
			select = "SELECT acc_type FROM employees WHERE user_id = " + user_id;
			result = conn.prepareStatement(select).executeQuery();
			String acc_type = "customer";
			if (result.isBeforeFirst()) {
				result.next();
				acc_type = result.getString("acc_type");
			}
			session.setAttribute("acc_type", acc_type);
		}
		else {
			out.println("Invalid login. Please check credentials or register for an account!");
		}
		conn.close();
		%>
			
	<a href="home.jsp">Click here to proceed to homepage</a>
	

	</body>
</html>
