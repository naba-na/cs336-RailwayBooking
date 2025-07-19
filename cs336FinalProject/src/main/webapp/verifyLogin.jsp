<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page language="java" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>

<html>
<head>
</head>
<body>
<%

	bookingDB db = new bookingDB();
	Connection conn = db.getConnection();
	String username = request.getParameter("username");
	String password = request.getParameter("password");
	
	String select = "SELECT * FROM users WHERE username = ? AND password = ?";
	PreparedStatement ps1 = conn.prepareStatement(select);
	ps1.setString(1, username);
	ps1.setString(2, password);
	
	ResultSet result = ps1.executeQuery();
	int repIndex = result.findColumn("isRep");
	int adminIndex = result.findColumn("isAdmin");
	%>
		
	
	<% 
	
	if(!result.isBeforeFirst()) { 
		//print if the credentials dont exist in database
		out.println("Invalid login. Please register first!");
	} else { 
		result.next();
		//check for privileges
		if(result.getBoolean(repIndex)) {
		 	out.println("Customer representative successfully logged in!");
			session.setAttribute("isRep", true);
		} else if (result.getBoolean(adminIndex)){
			out.println("Admin successfully logged in!");
			session.setAttribute("isAdmin", true);
		} else{
			out.println("Successfully logged in!");
		}
		
		//allow user to access website
		session.setAttribute("username", username);
			
	}
	%>
			
	<a href="home.jsp">Click here to proceed to homepage</a>
	

</body>
</html>
