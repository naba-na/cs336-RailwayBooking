<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Edit Representative</title>
<style>
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .form-group { margin: 15px 0; }
    label { display: block; margin-bottom: 5px; font-weight: bold; }
    input, select { width: 100%; padding: 10px; margin-bottom: 10px; border: 1px solid #ddd; border-radius: 4px; }
    .btn { background: #007cba; color: white; padding: 12px 24px; border: none; border-radius: 4px; cursor: pointer; margin-right: 10px; }
    .btn:hover { background: #005a87; }
    .btn-cancel { background: #6c757d; }
    .btn-cancel:hover { background: #5a6268; }
    .success { background: #d4edda; border: 1px solid #c3e6cb; color: #155724; padding: 15px; border-radius: 4px; margin: 15px 0; }
    .error { background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; padding: 15px; border-radius: 4px; margin: 15px 0; }
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
                    message = "<div class='error'>Username already exists!</div>";
                } else {
                    message = "<div class='error'>Email already exists!</div>";
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
                        message = "<div class='success'>Representative updated successfully!</div>";
                    } else {
                        message = "<div class='error'>Failed to update employee record.</div>";
                    }
                } else {
                    message = "<div class='error'>Failed to update user account.</div>";
                }
            }
        } catch (Exception e) {
            message = "<div class='error'>Error: " + e.getMessage() + "</div>";
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

<div class="container">
    <h1>✏️ Edit Representative</h1>
    <p><a href="manageReps.jsp">← Back to Manage Representatives</a></p>
    
    <%= message %>
    
    <form method="post">
        <div class="form-group">
            <label for="username">Username:</label>
            <input type="text" name="username" id="username" required value="<%= currentUsername %>">
        </div>
        
        <div class="form-group">
            <label for="password">Password (leave blank to keep current):</label>
            <input type="password" name="password" id="password" placeholder="Enter new password or leave blank">
        </div>
        
        <div class="form-group">
            <label for="firstname">First Name:</label>
            <input type="text" name="firstname" id="firstname" required value="<%= currentFirstname %>">
        </div>
        
        <div class="form-group">
            <label for="lastname">Last Name:</label>
            <input type="text" name="lastname" id="lastname" required value="<%= currentLastname %>">
        </div>
        
        <div class="form-group">
            <label for="email">Email:</label>
            <input type="email" name="email" id="email" required value="<%= currentEmail %>">
        </div>
        
        <div class="form-group">
            <label for="ssn">SSN (XXX-XX-XXXX):</label>
            <input type="text" name="ssn" id="ssn" pattern="[0-9]{3}-[0-9]{2}-[0-9]{4}" required value="<%= currentSsn %>">
        </div>
        
        <div class="form-group">
            <label for="acc_type">Account Type:</label>
            <select name="acc_type" id="acc_type" required>
                <option value="rep" <%= "rep".equals(currentAccType) ? "selected" : "" %>>Customer Representative</option>
                <option value="admin" <%= "admin".equals(currentAccType) ? "selected" : "" %>>Administrator</option>
            </select>
        </div>
        
        <button type="submit" class="btn">Update Representative</button>
        <a href="manageReps.jsp" class="btn btn-cancel">Cancel</a>
    </form>
</div>

</body>
</html>