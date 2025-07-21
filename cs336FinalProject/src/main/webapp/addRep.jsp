<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Add Representative</title>
<style>
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .form-group { margin: 15px 0; }
    label { display: block; margin-bottom: 5px; font-weight: bold; }
    input, select { width: 100%; padding: 10px; margin-bottom: 10px; border: 1px solid #ddd; border-radius: 4px; }
    .btn { background: #007cba; color: white; padding: 12px 24px; border: none; border-radius: 4px; cursor: pointer; }
    .btn:hover { background: #005a87; }
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
    
    String message = "";
    
    if ("POST".equals(request.getMethod())) {
        String newUsername = request.getParameter("username");
        String password = request.getParameter("password");
        String firstname = request.getParameter("firstname");
        String lastname = request.getParameter("lastname");
        String email = request.getParameter("email");
        String ssn = request.getParameter("ssn");
        String accountType = request.getParameter("acc_type");
        
        if (newUsername != null && password != null && firstname != null && lastname != null && email != null && ssn != null && accountType != null) {
            bookingDB db = new bookingDB();
            Connection conn = db.getConnection();
            
            try {
                String checkExists = "SELECT username, email FROM users WHERE username = ? OR email = ?";
                PreparedStatement psCheck = conn.prepareStatement(checkExists);
                psCheck.setString(1, newUsername);
                psCheck.setString(2, email);
                ResultSet checkResult = psCheck.executeQuery();
                
                if (checkResult.next()) {
                    if (checkResult.getString("username").equals(newUsername)) {
                        message = "<div class='error'>Username already exists!</div>";
                    } else {
                        message = "<div class='error'>Email already exists!</div>";
                    }
                } else {
                    String insertUser = "INSERT INTO users (username, password, firstname, lastname, email) VALUES (?, ?, ?, ?, ?)";
                    PreparedStatement psUser = conn.prepareStatement(insertUser, Statement.RETURN_GENERATED_KEYS);
                    psUser.setString(1, newUsername);
                    psUser.setString(2, password);
                    psUser.setString(3, firstname);
                    psUser.setString(4, lastname);
                    psUser.setString(5, email);
                    
                    int userResult = psUser.executeUpdate();
                    
                    if (userResult > 0) {
                        ResultSet generatedKeys = psUser.getGeneratedKeys();
                        generatedKeys.next();
                        int userId = generatedKeys.getInt(1);
                        
                        String insertEmployee = "INSERT INTO employees (user_id, ssn, acc_type) VALUES (?, ?, ?)";
                        PreparedStatement psEmployee = conn.prepareStatement(insertEmployee);
                        psEmployee.setInt(1, userId);
                        psEmployee.setString(2, ssn);
                        psEmployee.setString(3, accountType);
                        
                        int empResult = psEmployee.executeUpdate();
                        
                        if (empResult > 0) {
                            message = "<div class='success'>Representative added successfully! <a href='manageReps.jsp'>View all representatives</a></div>";
                            newUsername = "";
                            password = "";
                            firstname = "";
                            lastname = "";
                            email = "";
                            ssn = "";
                        } else {
                            message = "<div class='error'>Failed to add employee record.</div>";
                        }
                    } else {
                        message = "<div class='error'>Failed to create user account.</div>";
                    }
                }
            } catch (Exception e) {
                message = "<div class='error'>Error: " + e.getMessage() + "</div>";
            } finally {
                conn.close();
            }
        } else {
            message = "<div class='error'>Please fill in all fields.</div>";
        }
    }
%>

<div class="container">
    <h1>➕ Add New Representative</h1>
    <p><a href="manageReps.jsp">← Back to Manage Representatives</a></p>
    
    <%= message %>
    
    <form method="post">
        <div class="form-group">
            <label for="username">Username:</label>
            <input type="text" name="username" id="username" required value="<%= request.getParameter("username") != null ? request.getParameter("username") : "" %>">
        </div>
        
        <div class="form-group">
            <label for="password">Password:</label>
            <input type="password" name="password" id="password" required>
        </div>
        
        <div class="form-group">
            <label for="firstname">First Name:</label>
            <input type="text" name="firstname" id="firstname" required value="<%= request.getParameter("firstname") != null ? request.getParameter("firstname") : "" %>">
        </div>
        
        <div class="form-group">
            <label for="lastname">Last Name:</label>
            <input type="text" name="lastname" id="lastname" required value="<%= request.getParameter("lastname") != null ? request.getParameter("lastname") : "" %>">
        </div>
        
        <div class="form-group">
            <label for="email">Email:</label>
            <input type="email" name="email" id="email" required value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>">
        </div>
        
        <div class="form-group">
            <label for="ssn">SSN (XXX-XX-XXXX):</label>
            <input type="text" name="ssn" id="ssn" pattern="[0-9]{3}-[0-9]{2}-[0-9]{4}" placeholder="123-45-6789" required value="<%= request.getParameter("ssn") != null ? request.getParameter("ssn") : "" %>">
        </div>
        
        <div class="form-group">
            <label for="acc_type">Account Type:</label>
            <select name="acc_type" id="acc_type" required>
                <option value="">Select Account Type</option>
                <option value="rep" <%= "rep".equals(request.getParameter("acc_type")) ? "selected" : "" %>>Customer Representative</option>
                <option value="admin" <%= "admin".equals(request.getParameter("acc_type")) ? "selected" : "" %>>Administrator</option>
            </select>
        </div>
        
        <button type="submit" class="btn">Add Representative</button>
    </form>
</div>

</body>
</html>