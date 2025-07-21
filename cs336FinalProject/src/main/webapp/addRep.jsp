<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<html>
<head>
<title>Add Representative</title>
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
                        message = "<p>Username already exists!</p>";
                    } else {
                        message = "<p>Email already exists!</p>";
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
                            message = "<p>Representative added successfully! <a href='manageReps.jsp'>View all representatives</a></p>";
                            newUsername = "";
                            password = "";
                            firstname = "";
                            lastname = "";
                            email = "";
                            ssn = "";
                        } else {
                            message = "<p>Failed to add employee record.</p>";
                        }
                    } else {
                        message = "<p>Failed to create user account.</p>";
                    }
                }
            } catch (Exception e) {
                message = "<p>Error: " + e.getMessage() + "</p>";
            } finally {
                conn.close();
            }
        } else {
            message = "<p>Please fill in all fields.</p>";
        }
    }
%>

<h1>Add New Representative</h1>
<p><a href="manageReps.jsp">Back to Manage Representatives</a></p>

<%= message %>

<form method="post">
    <label>Username:</label><br/>
    <input type="text" name="username" required value="<%= request.getParameter("username") != null ? request.getParameter("username") : "" %>"><br/>
    
    <label>Password:</label><br/>
    <input type="password" name="password" required><br/>
    
    <label>First Name:</label><br/>
    <input type="text" name="firstname" required value="<%= request.getParameter("firstname") != null ? request.getParameter("firstname") : "" %>"><br/>
    
    <label>Last Name:</label><br/>
    <input type="text" name="lastname" required value="<%= request.getParameter("lastname") != null ? request.getParameter("lastname") : "" %>"><br/>
    
    <label>Email:</label><br/>
    <input type="email" name="email" required value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>"><br/>
    
    <label>SSN (XXX-XX-XXXX):</label><br/>
    <input type="text" name="ssn" pattern="[0-9]{3}-[0-9]{2}-[0-9]{4}" placeholder="123-45-6789" required value="<%= request.getParameter("ssn") != null ? request.getParameter("ssn") : "" %>"><br/>
    
    <label>Account Type:</label><br/>
    <select name="acc_type" required>
        <option value="">Select Account Type</option>
        <option value="rep" <%= "rep".equals(request.getParameter("acc_type")) ? "selected" : "" %>>Customer Representative</option>
        <option value="admin" <%= "admin".equals(request.getParameter("acc_type")) ? "selected" : "" %>>Administrator</option>
    </select><br/>
    
    <input type="submit" value="Add Representative">
</form>

</body>
</html>