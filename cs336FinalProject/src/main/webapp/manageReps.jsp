<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Manage Representatives</title>
<style>
    .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
    table { border-collapse: collapse; width: 100%; margin: 20px 0; }
    th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
    th { background-color: #f2f2f2; }
    .btn { display: inline-block; padding: 8px 12px; margin: 2px; text-decoration: none; border-radius: 4px; font-size: 12px; }
    .btn-edit { background: #007cba; color: white; }
    .btn-delete { background: #dc3545; color: white; }
    .btn-add { background: #28a745; color: white; padding: 10px 15px; margin: 10px 0; }
    .btn:hover { opacity: 0.8; }
    .success { color: green; font-weight: bold; }
    .error { color: red; font-weight: bold; }
</style>
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
                message = "<p class='success'>Representative deleted successfully!</p>";
            } else {
                message = "<p class='error'>Failed to delete representative.</p>";
            }
        } catch (Exception e) {
            message = "<p class='error'>Error: " + e.getMessage() + "</p>";
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

<div class="container">
    <h1>👥 Manage Customer Representatives</h1>
    <p><a href="adminPanel.jsp">← Back to Admin Panel</a></p>
    
    <%= message %>
    
    <a href="addRep.jsp" class="btn btn-add">➕ Add New Representative</a>
    
    <table>
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
        out.print("<a href='editRep.jsp?id=" + userId + "' class='btn btn-edit'>✏️ Edit</a>");
        out.print("<a href='manageReps.jsp?delete=" + userId + "' class='btn btn-delete' onclick='return confirm(\"Are you sure you want to delete this representative? This action cannot be undone.\")'>🗑️ Delete</a>");
        out.print("</td>");
        out.print("</tr>");
    }
    
    if (!hasReps) {
        out.print("<tr><td colspan='8'>No customer representatives found.</td></tr>");
    }
    %>
    </table>
    
    <div style="margin-top: 30px;">
        <h3>📊 Representative Statistics</h3>
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
    </div>
</div>

</body>
</html>