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
String origin_stop_id = request.getParameter("origin");
String destination_station_name = request.getParameter("destination");
String date = request.getParameter("date");
String isRound = request.getParameter("isRound");
String discount = request.getParameter("discount");
String username = (String) session.getAttribute("username");
LocalDate currentLocalDate = LocalDate.now();
String currentDate = currentLocalDate.toString();

//find userID
String findUserID = "SELECT user_id FROM users WHERE username = ? LIMIT 1";
PreparedStatement psUsers = conn.prepareStatement(findUserID);
psUsers.setString(1, username);
ResultSet resultUsers = psUsers.executeQuery();
resultUsers.next();
String user_id = resultUsers.getString(1);

//find dest_station_id from dest_station_name
String findStation = "SELECT station_id FROM stations WHERE station_name = ? LIMIT 1";
PreparedStatement psStation = conn.prepareStatement(findStation);
psStation.setString(1, destination_station_name);
ResultSet resultStations = psStation.executeQuery();
resultStations.next();
String dest_station_id = resultStations.getString(1); 

//find origin_station_name and origin_departure_time from origin_stop_id
String findOrigin = "SELECT st.station_name, s.departure_time, st.station_id FROM stations st JOIN stops s ON s.station_id = st.station_id WHERE s.stop_id = ? LIMIT 1";
PreparedStatement psOrigin = conn.prepareStatement(findOrigin);
psOrigin.setString(1, origin_stop_id);
ResultSet resultOrigin = psOrigin.executeQuery();
resultOrigin.next();
String origin_station_name = resultOrigin.getString(1);
String origin_departure_time = resultOrigin.getString(2);
String origin_station_id = resultOrigin.getString(3);

//find line_name from transitlinecontainsstops using origin_stop_id
String findLine = "SELECT tlcs.line_name FROM TransitLines_Contains_Stops WHERE stop_id = ?";
PreparedStatement psLine = conn.prepareStatement(findLine);
psLine.setString(1, origin_stop_id);
ResultSet resultLine = psLine.executeQuery();
resultLine.next();
String line_name = resultLine.getString(1);

//recursively search stops to find total fare
//first string origin stop id, 2nd line_name, 3nd and 6th dest station id, 4rd + 5th fare column
String findRoute = "WITH RECURSIVE route AS (SELECT s.stop_id, s.station_id, s.nextstop_id, s.arrival_time, s.departure_time, tlcs.line_name, 1 AS stops_visited, 0 AS depth "
						+ "FROM stops s JOIN TransitLines_Contains_Stops tlcs ON s.stop_id = tlcs.stop_id "
						+ "WHERE s.stop_id = ? AND tcls.line_name = ? UNION ALL SELECT s2.stop_id, s2.station_id, s2.nextstop_id, s2.arrival_time, s2.departure_time, r.line_name, r.stops_visited + 1, r.depth + 1 "
						+ "FROM route r JOIN stops s2 ON s2.stop_id = r.nextstop_id JOIN TransitLines_Contains_Stops tlcs2 ON s2.stop_id = tlcs2.stop_id AND tlcs2.line_name = r.line_name WHERE r.station_id != ?) "
						+ "SELECT r.*, ?, ts.total AS total_stops_on_route, (? / ts.total) * r.stops_visited AS calculated_fare FROM route r JOIN transitlines tl ON r.line_name = tl.line_name "
						+ "JOIN (SELECT line_name, COUNT(*) AS total FROM TransitLines_Contains_Stops GROUP BY line_name) ts ON r.line_name = ts.line_name "
						+ "WHERE r.station_id = ? ORDER BY r.depth LIMIT 1";
PreparedStatement psRoute = conn.prepareStatement(findRoute);
psRoute.setString(1, origin_stop_id);
psRoute.setString(2, line_name);
psRoute.setString(2, dest_station_id);
psRoute.setString(3, discount);
psRoute.setString(4, discount);
psRoute.setString(5, dest_station_id);
ResultSet route = psRoute.executeQuery();
route.next();
float fareTotal = route.getFloat(route.findColumn("calculated_fare"));
String dest_stop_id = route.getString(route.findColumn("stop_id"));
String dest_arrival_time = route.getString(route.findColumn("arrival_time"));


String insertRes = "INSERT INTO reservations(creationDate, user_id, res_date, res_time, dest_arrival_time, line_name, origin_station_name, origin_stop_id, destination_station_name, dest_stop_id, total_fare, isActive) "
							+ " VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, true)";
PreparedStatement psRes = conn.prepareStatement(insertRes);
psRes.setString(1, currentDate);
psRes.setString(2, user_id);
psRes.setString(3, date);
psRes.setString(4, origin_departure_time);
psRes.setString(5, dest_arrival_time);
psRes.setString(6, line_name);
psRes.setString(7, origin_station_name);
psRes.setString(8, origin_stop_id);
psRes.setString(9, destination_station_name);
psRes.setString(10, dest_stop_id);
psRes.setFloat(11, fareTotal);

//repeat route finding for roundtrip
if(isRound == "Y"){
	//find suitable line
	//string one original destination, s2 original origin
	String findReturnLine = "SELECT tlcs1.line_name, s1.stop_id FROM TransitLines_Contains_Stops tlcs1 JOIN stops s1 ON tlcs1.stop_id = s1.stop_id "
							+ "JOIN TransitLines_Contains_Stops tlcs2 ON tlcs1.line_name = tlcs2.line_name JOIN stops s2 ON tlcs2.stop_id = s2.stop_id "
							+ "WHERE s1.station_id = ? AND s2.station_id = ? AND s1.departure_time > ? AN s1.departure_time < s2.arrival_time GROUP BY tlcs1.line_name LIMIT 1";
	PreparedStatement psReturnLine = conn.prepareStatement(findReturnLine);
	psReturnLine.setString(1, dest_station_id);
	psReturnLine.setString(2, origin_station_id);
	psReturnLine.setString(3, dest_arrival_time);
	ResultSet resultReturnLine = psReturnLine.executeQuery();
	if(!resultReturnLine.isBeforeFirst()){
		out.println("Error finding route for return trip, only creating one-way reservation.");
	}else{
		resultReturnLine.next();
		String return_line_name = resultReturnLine.getString(1);
		
		
	}
	
}


int result = psRes.executeUpdate();
if(result < 1){
	out.println("Error occurred creating reservation, please try again.");
}else{
	out.println("Reservation successfully created!");
}

conn.close();

%>
</body>
</html>