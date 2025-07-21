<%@ page import="javax.servlet.http.*,javax.servlet.*" %>

<%@ page session="true" %>

<script>
         function goToAdminPanel() {
            window.location.assign("adminPanel.jsp");
         }
         function goToRepPanel() {
            window.location.assign("repPanel.jsp");
         }
</script>

<%
    String username = (String) session.getAttribute("username");
    String acc_type = (String) session.getAttribute("acc_type");
    if (username == null || acc_type == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    if (acc_type.equals("admin")) {
        %> <button type="button" onclick="goToAdminPanel()">Admin Panel</button> <%
    }
    else if (acc_type.equals("rep")) {
        %> <button type="button" onclick="goToRepPanel()">Representative Panel</button> <%
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
    <h2>Make reservation</h2>
    <form action="makeReservation.jsp" method="post">
    	Origin Stop ID (please ensure correct time and transit line): <input type="text" name="origin" required>
    	Destination Station Name: <input type="text" name="destination" required>
    	Date: <input type="date" name="date" required>
    	<label for="discount">Select one that applies:</label> 
    		<select name="discount" id="discount" required>
    			<option value="fare">None</option>
    			<option value="fareChild">Child</option>
    			<option value="fareSenior">Senior</option>
    			<option value="fareDisabled">Disabled</option>
    		</select>
    	<input type="radio" name="isRound" value="N" required/>One-way
    	<input type="radio" name="isRound" value="Y" required/>Round-Trip
    	<input type="submit" value="Book Reservation">
    </form>
    
    <a href="viewReservations.jsp">View Reservations</a>
    <br>
    <a href="browseQuestions.jsp">Browse Questions</a>
    
</body>
</html>
