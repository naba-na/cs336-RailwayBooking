<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page language="java" %>
<%@ page import="java.io.*,java.util.*,java.sql.*,java.time.*"%>
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
String trainid = request.getParameter("trainid");
String sortValue = request.getParameter("sortValue");
String sortDirect = request.getParameter("sortDirect");

String findLine = "SELECT line_name FROM trains WHERE train_id = ?";
PreparedStatement psLine = conn.prepareStatement(findLine);
psLine.setString(1, trainid);
ResultSet resultLine = psLine.executeQuery();
String line_name = resultLine.getString(resultLine.findColumn("line_name"));

String stops_in_transitline = "SELECT t.line_name, t.fare, t.fareChild, t.fareSenior, t.fareDisabled, s.stop_id, st.station_name, s.arrival_time, s.departure_time FROM transitlines t JOIN Transitlines_Contains_Stops ts ON t.line_name = ts.line_name JOIN stops s ON ts.stop_id = s.stop_id JOIN stations st ON s.station_id = st.station_id";
stops_in_transitline += " ORDER BY " + sortValue + " " + sortDirect;
PreparedStatement psStops = conn.prepareStatement(stops_in_transitline);
ResultSet results = psStops.executeQuery();
%>

<h1>Stops for train #<%=trainid%></h1>

<br><br>

<table>
<tr>
<th>Line Name</th>
<th>Fare</th>
<th>Fare (Children)</th>
<th>Fare (Senior)</th>
<th>Fare (Disabled)</th>
<th>Stop ID</th>
<th>Station Name</th>
<th>Stop Arrival</th>
<th>Stop Departure</th>
<th></th>
<th></th>
</tr>

<%
while(results.next()){
	out.print("<tr>");
		for(int i = 1; i <= 9; i++){
			out.print("<td>");
			out.print(results.getString(i));
			out.print("</td>");
		}
	out.print("</tr>");
}

conn.close();%>
</table>
<br>
<a href="home.jsp">Click here to proceed to homepage</a>
</body>
</html>