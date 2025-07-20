<%@ page import="javax.servlet.http.*,javax.servlet.*" %>

<%@ page session="true" %>
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<html>
<head><title>Welcome</title></head>
<body>
    <h2>Welcome, <%= username %>!</h2>
    <form action="logout.jsp" method="post">
        <input type="submit" value="Logout">
    </form>
    
    <br>
    
    <h2>Search schedules</h2>
    <form action="searchSchedules.jsp" method="post">
    	Origin: <input type="text" name="origin" required>
    	Destination: <input type="text" name="destination" required>
    	Date: <input type="date" name="date" required>
    	<input type="submit" value="Search">
    </form>
</body>
</html>
