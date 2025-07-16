<%@ page import="javax.servlet.http.*,javax.servlet.*" %>

<%@ page session="true" %>
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<html>
<head><title>Welcome</title></head>
<body>
    <h2>Welcome, <%= username %>!</h2>
    <form action="logout.jsp" method="post">
        <input type="submit" value="Logout">
    </form>
</body>
</html>
