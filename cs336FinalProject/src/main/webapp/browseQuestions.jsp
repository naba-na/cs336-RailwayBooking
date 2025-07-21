<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<html>
<head>
<title>Browse Questions & Answers</title>
</head>
<body>
<%
    String username = (String) session.getAttribute("username");
    String acc_type = (String) session.getAttribute("acc_type");
    
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    bookingDB db = new bookingDB();
    Connection conn = db.getConnection();
    
    String newQuestion = request.getParameter("newQuestion");
    String message = "";
    
    if (newQuestion != null && !newQuestion.trim().isEmpty()) {
        try {
            String getUserId = "SELECT user_id FROM users WHERE username = ?";
            PreparedStatement psUser = conn.prepareStatement(getUserId);
            psUser.setString(1, username);
            ResultSet userResult = psUser.executeQuery();
            
            if (userResult.next()) {
                int userId = userResult.getInt("user_id");
                
                String insertQuestion = "INSERT INTO customer_questions (user_id, question_text) VALUES (?, ?)";
                PreparedStatement psInsert = conn.prepareStatement(insertQuestion);
                psInsert.setInt(1, userId);
                psInsert.setString(2, newQuestion);
                
                int result = psInsert.executeUpdate();
                if (result > 0) {
                    message = "<p>Question submitted successfully! A representative will answer soon.</p>";
                }
            }
        } catch (Exception e) {
            message = "<p>Error: " + e.getMessage() + "</p>";
        }
    }
    
    String searchKeyword = request.getParameter("searchKeyword");
    
    String getQAs = "SELECT cq.question_id, cq.question_text, cq.answer_text, cq.created_date, cq.answered_date, " +
                   "u.firstname, u.lastname, cq.rep_username " +
                   "FROM customer_questions cq " +
                   "LEFT JOIN users u ON cq.user_id = u.user_id " +
                   "WHERE cq.status = 'answered'";
    
    if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
        getQAs += " AND (cq.question_text LIKE ? OR cq.answer_text LIKE ?)";
    }
    
    getQAs += " ORDER BY cq.answered_date DESC";
    
    PreparedStatement psQAs = conn.prepareStatement(getQAs);
    
    if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
        String searchPattern = "%" + searchKeyword + "%";
        psQAs.setString(1, searchPattern);
        psQAs.setString(2, searchPattern);
    }
    
    ResultSet qasResult = psQAs.executeQuery();
%>

<h1>Questions & Answers</h1>
<p>
    <% if ("rep".equals(acc_type)) { %>
        <a href="repPanel.jsp">Back to Rep Panel</a> | <a href="manageQuestions.jsp">Manage Questions</a>
    <% } else { %>
        <a href="home.jsp">Back to Home</a>
    <% } %>
</p>

<%= message %>

<% if (!"rep".equals(acc_type) && !"admin".equals(acc_type)) { %>
<h2>Ask a Question</h2>
<form method="post">
    <textarea name="newQuestion" rows="4" cols="50" placeholder="Type your question here..." required></textarea><br/>
    <input type="submit" value="Submit Question">
</form>
<% } %>

<h2>Search Questions & Answers</h2>
<form method="get">
    <input type="text" name="searchKeyword" placeholder="Search by keyword..." value="<%= searchKeyword != null ? searchKeyword : "" %>">
    <input type="submit" value="Search">
    <% if (searchKeyword != null && !searchKeyword.trim().isEmpty()) { %>
        <a href="browseQuestions.jsp">Clear Search</a>
    <% } %>
</form>

<h2>Answered Questions</h2>
<%
boolean hasQAs = false;
while(qasResult.next()) {
    hasQAs = true;
    String customerName = qasResult.getString("firstname") + " " + qasResult.getString("lastname");
    
    out.println("<h3>Q:</h3>");
    out.println("<p>" + qasResult.getString("question_text") + "</p>");
    out.println("<p><em>Asked by: " + customerName + " on " + qasResult.getTimestamp("created_date") + "</em></p>");
    
    out.println("<h3>A:</h3>");
    out.println("<p>" + qasResult.getString("answer_text") + "</p>");
    out.println("<p><em>Answered by: " + qasResult.getString("rep_username") + " on " + qasResult.getTimestamp("answered_date") + "</em></p>");
    
    out.println("<hr>");
}

if (!hasQAs) {
    if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
        out.println("<p>No questions found matching '" + searchKeyword + "'.</p>");
    } else {
        out.println("<p>No answered questions available yet.</p>");
    }
}

conn.close();
%>

</body>
</html>