<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Browse Questions & Answers</title>
<style>
    .container { max-width: 1000px; margin: 0 auto; padding: 20px; }
    .qa-card { border: 1px solid #ddd; margin: 15px 0; padding: 15px; border-radius: 8px; background: #f8fff8; }
    .question-section { background: #e7f3ff; padding: 10px; border-radius: 4px; margin-bottom: 10px; }
    .answer-section { background: #f0f8f0; padding: 10px; border-radius: 4px; }
    .meta-info { font-size: 12px; color: #666; margin: 5px 0; }
    .search-box { background: #f8f9fa; padding: 15px; border-radius: 8px; margin: 20px 0; }
    .btn { display: inline-block; padding: 10px 15px; background: #007cba; color: white; text-decoration: none; border-radius: 4px; border: none; cursor: pointer; }
    .btn:hover { background: #005a87; }
    .ask-question-form { background: #fff3cd; padding: 15px; border-radius: 8px; margin: 20px 0; }
    textarea { width: 100%; min-height: 80px; padding: 8px; border: 1px solid #ddd; border-radius: 4px; }
</style>
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
                    message = "<div style='background: #d4edda; color: #155724; padding: 10px; border-radius: 4px; margin: 10px 0;'>Question submitted successfully! A representative will answer soon.</div>";
                }
            }
        } catch (Exception e) {
            message = "<div style='background: #f8d7da; color: #721c24; padding: 10px; border-radius: 4px; margin: 10px 0;'>Error: " + e.getMessage() + "</div>";
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

<div class="container">
    <h1>💬 Questions & Answers</h1>
    <p>
        <% if ("rep".equals(acc_type)) { %>
            <a href="repPanel.jsp">← Back to Rep Panel</a> | <a href="manageQuestions.jsp">Manage Questions</a>
        <% } else { %>
            <a href="home.jsp">← Back to Home</a>
        <% } %>
    </p>
    
    <%= message %>
    
    <% if (!"rep".equals(acc_type) && !"admin".equals(acc_type)) { %>
    <div class="ask-question-form">
        <h3>❓ Ask a Question</h3>
        <form method="post">
            <textarea name="newQuestion" placeholder="Type your question here..." required></textarea>
            <br>
            <button type="submit" class="btn">Submit Question</button>
        </form>
    </div>
    <% } %>
    
    <div class="search-box">
        <h3>🔍 Search Questions & Answers</h3>
        <form method="get">
            <input type="text" name="searchKeyword" placeholder="Search by keyword..." value="<%= searchKeyword != null ? searchKeyword : "" %>" style="width: 300px; padding: 8px;">
            <button type="submit" class="btn">Search</button>
            <% if (searchKeyword != null && !searchKeyword.trim().isEmpty()) { %>
                <a href="browseQuestions.jsp" class="btn" style="background: #6c757d;">Clear Search</a>
            <% } %>
        </form>
    </div>
    
    <div>
        <h2>📋 Answered Questions</h2>
        <%
        boolean hasQAs = false;
        while(qasResult.next()) {
            hasQAs = true;
            String customerName = qasResult.getString("firstname") + " " + qasResult.getString("lastname");
            
            out.println("<div class='qa-card'>");
            
            out.println("<div class='question-section'>");
            out.println("<strong>Q:</strong> " + qasResult.getString("question_text"));
            out.println("<div class='meta-info'>Asked by: " + customerName + " on " + qasResult.getTimestamp("created_date") + "</div>");
            out.println("</div>");
            
            out.println("<div class='answer-section'>");
            out.println("<strong>A:</strong> " + qasResult.getString("answer_text"));
            out.println("<div class='meta-info'>Answered by: " + qasResult.getString("rep_username") + " on " + qasResult.getTimestamp("answered_date") + "</div>");
            out.println("</div>");
            
            out.println("</div>");
        }
        
        if (!hasQAs) {
            if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
                out.println("<div class='qa-card'><p>No questions found matching '" + searchKeyword + "'.</p></div>");
            } else {
                out.println("<div class='qa-card'><p>No answered questions available yet.</p></div>");
            }
        }
        
        conn.close();
        %>
    </div>
</div>

</body>
</html>