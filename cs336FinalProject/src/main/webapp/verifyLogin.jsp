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
		
		String select = "SELECT * FROM %s WHERE username = '%s' AND password = '%s'"; // %s -> String.format()
		
		String accountTables[] = {"customers", "employees_reps", "employees_admins"};
		String resultString = "Invalid login. Please check credentials or register for an account!";

		for (String accType: accountTables) {
			ResultSet result = conn.prepareStatement(String.format(select, accType, username, password)).executeQuery();

			if (result.isBeforeFirst()) {
				resultString = "Successfully logged in!";
				session.setAttribute("username", username);
				break;
			}

		}
		out.println(resultString);
		conn.close();
		%>
			
	<a href="home.jsp">Click here to proceed to homepage</a>
	

	</body>
</html>
