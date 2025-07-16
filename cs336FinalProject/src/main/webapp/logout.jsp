<%@ page import="javax.servlet.http.*,javax.servlet.*" %>

<%@ page session="true" %>
<%
    session.invalidate();
    response.sendRedirect("login.jsp");
%>
