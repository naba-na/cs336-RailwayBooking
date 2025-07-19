<%@ page import="javax.servlet.http.*,javax.servlet.*" %>

<%@ page language="java" %>
<html>
<head><title>Login Page</title></head>
<body>
    <h2>Login</h2>
    <form action="verifyLogin.jsp" method="post">
        Username: <input type="text" name="username" required><br/>
        Password: <input type="password" name="password" required><br/>
        <input type="submit" value="Login">
    </form>
    <p style="color:red;">${message}</p>
    
    <a href="registerPage.jsp">Register</a>
</body>
</html>
