<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<html>
<head>
<title>Manage Representatives</title>
</head>
<body>
<%
    String username = (String) session.getAttribute("username");
    String acc_type = (String) session.getAttribute("acc_type");
    
    if (username == null || !"admin".equals(acc_type)) {
        response.sendRedirect("home.jsp");
        return;
    }
    
    String deleteId = request.getParameter("delete");
    String message = "";
    
    if (deleteId != null) {
        bookingDB db = new bookingDB();
        Connection conn = db.getConnection();
        
        try {
            String deleteEmployee = "DELETE FROM employees WHERE user_id = ?";
            PreparedStatement psDelEmp = conn.prepareStatement(deleteEmployee);
            psDelEmp.setString(1, deleteId);
            psDelEmp.executeUpdate();
            
            String deleteUser = "DELETE FROM users WHERE user_id = ?";
            PreparedStatement psDelUser = conn.prepareStatement(deleteUser);
            psDelUser.setString(1, deleteId);
            int result = psDelUser.executeUpdate();
            
            if (result > 0) {
                message = "<p>Representative deleted successfully!</p>";
            } else {
                message = "<p>Failed to delete representative.</p>";
            }
        } catch (Exception e) {
            message = "<p>Error: " + e.getMessage() + "</p>";
        } finally {
            conn.close();
        }
    }
    
    bookingDB db = new bookingDB();
    Connection conn = db.getConnection();
    
    String getReps = "SELECT u.user_id, u.username, u.firstname, u.lastname, u.email, e.ssn, e.acc_type " +
                    "FROM users u " +
                    "JOIN employees e ON u.user_id = e.user_id " +
                    "WHERE e.acc_type = 'rep' " +
                    "ORDER BY u.lastname, u.firstname";
    
    PreparedStatement psReps = conn.prepareStatement(getReps);
    ResultSet repsResult = psReps.executeQuery();
%>

<h1>Manage Customer Representatives</h1>
<p><a href="adminPanel.jsp">Back to Admin Panel</a></p>

<%= message %>

<a href="addRep.jsp">Add New Representative</a>

<table border="1">
<tr>
    <th>ID</th>
    <th>Username</th>
    <th>First Name</th>
    <th>Last Name</th>
    <th>Email</th>
    <th>SSN</th>
    <th>Account Type</th>
    <th>Actions</th>
</tr>

<%
boolean hasReps = false;
while(repsResult.next()){
    hasReps = true;
    int userId = repsResult.getInt("user_id");
    out.print("<tr>");
    out.print("<td>" + userId + "</td>");
    out.print("<td>" + repsResult.getString("username") + "</td>");
    out.print("<td>" + repsResult.getString("firstname") + "</td>");
    out.print("<td>" + repsResult.getString("lastname") + "</td>");
    out.print("<td>" + repsResult.getString("email") + "</td>");
    out.print("<td>" + repsResult.getString("ssn") + "</td>");
    out.print("<td>" + repsResult.getString("acc_type").toUpperCase() + "</td>");
    out.print("<td>");
    out.print("<a href='editRep.jsp?id=" + userId + "'>Edit</a> | ");
    out.print("<a href='manageReps.jsp?delete=" + userId + "' onclick='return confirm(\"Are you sure you want to delete this representative? This action cannot be undone.\")'>Delete</a>");
    out.print("</td>");
    out.print("</tr>");
}

if (!hasReps) {
    out.print("<tr><td colspan='8'>No customer representatives found.</td></tr>");
}
%>
</table>

<h3>Representative Statistics</h3>
<%
bookingDB db2 = new bookingDB();
Connection conn2 = db2.getConnection();

String repStats = "SELECT " +
                 "COUNT(*) as total_reps, " +
                 "(SELECT COUNT(*) FROM users u JOIN employees e ON u.user_id = e.user_id WHERE e.acc_type = 'admin') as total_admins " +
                 "FROM users u " +
                 "JOIN employees e ON u.user_id = e.user_id " +
                 "WHERE e.acc_type = 'rep'";

PreparedStatement psStats = conn2.prepareStatement(repStats);
ResultSet statsResult = psStats.executeQuery();
statsResult.next();

out.println("<p><strong>Total Representatives:</strong> " + statsResult.getInt("total_reps") + "</p>");
out.println("<p><strong>Total Administrators:</strong> " + statsResult.getInt("total_admins") + "</p>");

conn.close();
conn2.close();
%>

</body>
</html>