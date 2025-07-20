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
    
    <h2>Search train stops</h2>
    <form action="searchStops.jsp" method="post">
    	Train ID: <input type="text" name="trainid" required>
    	<label for="sortValue">Sort by:</label> 
    		<select name="sortValue" id="sortValue">
    			<option value="t.fare">Fare</option>
    			<option value="s.arrival_time">Stop Arrival Time</option>
    			<option value="s.departure_time">Stop Departure Time</option>
    		</select>
    	<input type="radio" name="sortDirect" value="ASC"/>Ascending
    	<input type="radio" name="sortDirect" value="DESC"/>Descending
    	<input type="submit" value="Search">
    </form>
    
</body>
</html>
