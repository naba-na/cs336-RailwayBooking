<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<html>
<head>
<title>Edit Representative</title>
</head>
<body>
<%
    String username = (String) session.getAttribute("username");
    String acc_type = (String) session.getAttribute("acc_type");
    
    if (username == null || !"admin".equals(acc_type)) {
        response.sendRedirect("home.jsp");
        return;
    }
    
    String userId = request.getParameter("id");
    String message = "";
    
    if (userId == null) {
        response.sendRedirect("manageReps.jsp");
        return;
    }
    
    bookingDB db = new bookingDB();
    Connection conn = db.getConnection();
    
    if ("POST".equals(request.getMethod())) {
        String newUsername = request.getParameter("username");
        String password = request.getParameter("password");
        String firstname = request.getParameter("firstname");
        String lastname = request.getParameter("lastname");
        String email = request.getParameter("email");
        String ssn = request.getParameter("ssn");
        String accountType = request.getParameter("acc_type");
        
        try {
            String checkExists = "SELECT user_id, username, email FROM users WHERE (username = ? OR email = ?) AND user_id != ?";
            PreparedStatement psCheck = conn.prepareStatement(checkExists);
            psCheck.setString(1, newUsername);
            psCheck.setString(2, email);
            psCheck.setString(3, userId);
            ResultSet checkResult = psCheck.executeQuery();
            
            if (checkResult.next()) {
                if (checkResult.getString("username").equals(newUsername)) {
                    message = "<p>Username already exists!</p>";
                } else {
                    message = "<p>Email already exists!</p>";
                }
            } else {
                String updateUser;
                PreparedStatement psUser;
                
                if (password != null && !password.trim().isEmpty()) {
                    updateUser = "UPDATE users SET username = ?, password = ?, firstname = ?, lastname = ?, email = ? WHERE user_id = ?";
                    psUser = conn.prepareStatement(updateUser);
                    psUser.setString(1, newUsername);
                    psUser.setString(2, password);
                    psUser.setString(3, firstname);
                    psUser.setString(4, lastname);
                    psUser.setString(5, email);
                    psUser.setString(6, userId);
                } else {
                    updateUser = "UPDATE users SET username = ?, firstname = ?, lastname = ?, email = ? WHERE user_id = ?";
                    psUser = conn.prepareStatement(updateUser);
                    psUser.setString(1, newUsername);
                    psUser.setString(2, firstname);
                    psUser.setString(3, lastname);
                    psUser.setString(4, email);
                    psUser.setString(5, userId);
                }
                
                int userResult = psUser.executeUpdate();
                
                if (userResult > 0) {
                    String updateEmployee = "UPDATE employees SET ssn = ?, acc_type = ? WHERE user_id = ?";
                    PreparedStatement psEmployee = conn.prepareStatement(updateEmployee);
                    psEmployee.setString(1, ssn);
                    psEmployee.setString(2, accountType);
                    psEmployee.setString(3, userId);
                    
                    int empResult = psEmployee.executeUpdate();
                    
                    if (empResult > 0) {
                        message = "<p>Representative updated successfully!</p>";
                    } else {
                        message = "<p>Failed to update employee record.</p>";
                    }
                } else {
                    message = "<p>Failed to update user account.</p>";
                }
            }
        } catch (Exception e) {
            message = "<p>Error: " + e.getMessage() + "</p>";
        }
    }
    
    String getRep = "SELECT u.username, u.firstname, u.lastname, u.email, e.ssn, e.acc_type " +
                   "FROM users u " +
                   "JOIN employees e ON u.user_id = e.user_id " +
                   "WHERE u.user_id = ?";
    
    PreparedStatement psRep = conn.prepareStatement(getRep);
    psRep.setString(1, userId);
    ResultSet repResult = psRep.executeQuery();
    
    if (!repResult.next()) {
        conn.close();
        response.sendRedirect("manageReps.jsp");
        return;
    }
    
    String currentUsername = repResult.getString("username");
    String currentFirstname = repResult.getString("firstname");
    String currentLastname = repResult.getString("lastname");
    String currentEmail = repResult.getString("email");
    String currentSsn = repResult.getString("ssn");
    String currentAccType = repResult.getString("acc_type");
    
    conn.close();
%>

<h1>Edit Representative</h1>
<p><a href="manageReps.jsp">Back to Manage Representatives</a></p>

<%= message %>

<form method="post">
    <label>Username:</label><br/>
    <input type="text" name="username" required value="<%= currentUsername %>"><br/>
    
    <label>Password (leave blank to keep current):</label><br/>
    <input type="password" name="password" placeholder="Enter new password or leave blank"><br/>
    
    <label>First Name:</label><br/>
    <input type="text" name="firstname" required value="<%= currentFirstname %>"><br/>
    
    <label>Last Name:</label><br/>
    <input type="text" name="lastname" required value="<%= currentLastname %>"><br/>
    
    <label>Email:</label><br/>
    <input type="email" name="email" required value="<%= currentEmail %>"><br/>
    
    <label>SSN (XXX-XX-XXXX):</label><br/>
    <input type="text" name="ssn" pattern="[0-9]{3}-[0-9]{2}-[0-9]{4}" required value="<%= currentSsn %>"><br/>
    
    <label>Account Type:</label><br/>
    <select name="acc_type" required>
        <option value="rep" <%= "rep".equals(currentAccType) ? "selected" : "" %>>Customer Representative</option>
        <option value="admin" <%= "admin".equals(currentAccType) ? "selected" : "" %>>Administrator</option>
    </select><br/>
    
    <input type="submit" value="Update Representative">
    <a href="manageReps.jsp">Cancel</a>
</form>

</body>
</html>