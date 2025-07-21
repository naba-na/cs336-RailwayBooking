<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<html>
<head>
<title>Manage Customer Questions</title>
</head>
<body>
<%
    String username = (String) session.getAttribute("username");
    String acc_type = (String) session.getAttribute("acc_type");
    
    if (username == null || !"rep".equals(acc_type)) {
        response.sendRedirect("home.jsp");
        return;
    }
    
    bookingDB db = new bookingDB();
    Connection conn = db.getConnection();
    
    try {
        String createTable = "CREATE TABLE IF NOT EXISTS customer_questions ( " +
                            "question_id INT AUTO_INCREMENT PRIMARY KEY, " +
                            "user_id INT, " +
                            "question_text TEXT NOT NULL, " +
                            "answer_text TEXT, " +
                            "status ENUM('pending', 'answered') DEFAULT 'pending', " +
                            "rep_username VARCHAR(50), " +
                            "created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                            "answered_date TIMESTAMP NULL, " +
                            "FOREIGN KEY (user_id) REFERENCES users(user_id) " +
                            ")";
        PreparedStatement psCreate = conn.prepareStatement(createTable);
        psCreate.executeUpdate();
    } catch (Exception e) {
    }
    
    String answerQuestionId = request.getParameter("answerQuestionId");
    String answerText = request.getParameter("answerText");
    String message = "";
    
    if (answerQuestionId != null && answerText != null && !answerText.trim().isEmpty()) {
        try {
            String updateAnswer = "UPDATE customer_questions " +
                                 "SET answer_text = ?, status = 'answered', rep_username = ?, answered_date = CURRENT_TIMESTAMP " +
                                 "WHERE question_id = ?";
            PreparedStatement psAnswer = conn.prepareStatement(updateAnswer);
            psAnswer.setString(1, answerText);
            psAnswer.setString(2, username);
            psAnswer.setString(3, answerQuestionId);
            
            int result = psAnswer.executeUpdate();
            if (result > 0) {
                message = "<p>Question answered successfully!</p>";
            }
        } catch (Exception e) {
            message = "<p>Error answering question: " + e.getMessage() + "</p>";
        }
    }
    
    String searchKeyword = request.getParameter("searchKeyword");
    String statusFilter = request.getParameter("statusFilter");
    
    String baseQuery = "SELECT cq.question_id, cq.question_text, cq.answer_text, cq.status, cq.rep_username, " +
                      "cq.created_date, cq.answered_date, u.username as customer_username, u.firstname, u.lastname " +
                      "FROM customer_questions cq " +
                      "LEFT JOIN users u ON cq.user_id = u.user_id " +
                      "WHERE 1=1";
    
    if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
        baseQuery += " AND (cq.question_text LIKE ? OR cq.answer_text LIKE ?)";
    }
    
    if (statusFilter != null && !statusFilter.isEmpty()) {
        baseQuery += " AND cq.status = ?";
    }
    
    baseQuery += " ORDER BY cq.created_date DESC";
    
    PreparedStatement psQuestions = conn.prepareStatement(baseQuery);
    int paramIndex = 1;
    
    if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
        String searchPattern = "%" + searchKeyword + "%";
        psQuestions.setString(paramIndex++, searchPattern);
        psQuestions.setString(paramIndex++, searchPattern);
    }
    
    if (statusFilter != null && !statusFilter.isEmpty()) {
        psQuestions.setString(paramIndex, statusFilter);
    }
    
    ResultSet questionsResult = psQuestions.executeQuery();
%>

<h1>Manage Customer Questions</h1>
<p><a href="repPanel.jsp">Back to Rep Panel</a> | <a href="browseQuestions.jsp">Browse All Q&A</a></p>

<%= message %>

<h2>Search Questions</h2>
<form method="get">
    <label>Search by keyword:</label><br/>
    <input type="text" name="searchKeyword" placeholder="Search in questions and answers..." value="<%= searchKeyword != null ? searchKeyword : "" %>"><br/>
    
    <label>Status:</label><br/>
    <select name="statusFilter">
        <option value="">All Status</option>
        <option value="pending" <%= "pending".equals(statusFilter) ? "selected" : "" %>>Pending</option>
        <option value="answered" <%= "answered".equals(statusFilter) ? "selected" : "" %>>Answered</option>
    </select><br/>
    <input type="submit" value="Search">
</form>

<%
boolean hasQuestions = false;
while(questionsResult.next()) {
    hasQuestions = true;
    int questionId = questionsResult.getInt("question_id");
    String status = questionsResult.getString("status");
    String customerName = questionsResult.getString("firstname") + " " + questionsResult.getString("lastname");
    String customerUsername = questionsResult.getString("customer_username");
    
    out.println("<h3>Question #" + questionId + " - " + status.toUpperCase() + "</h3>");
    out.println("<p><strong>From:</strong> " + customerName + " (" + customerUsername + ") | " + questionsResult.getTimestamp("created_date") + "</p>");
    
    out.println("<p><strong>Question:</strong> " + questionsResult.getString("question_text") + "</p>");
    
    if ("answered".equals(status)) {
        out.println("<p><strong>Answer:</strong> " + questionsResult.getString("answer_text") + "</p>");
        out.println("<p><em>Answered by: " + questionsResult.getString("rep_username") + " on " + questionsResult.getTimestamp("answered_date") + "</em></p>");
    } else {
        out.println("<form method='post'>");
        out.println("<input type='hidden' name='answerQuestionId' value='" + questionId + "'>");
        out.println("<label><strong>Your Answer:</strong></label><br/>");
        out.println("<textarea name='answerText' rows='4' cols='50' placeholder='Type your answer here...' required></textarea><br/>");
        out.println("<input type='submit' value='Submit Answer'>");
        out.println("</form>");
    }
    
    out.println("<hr>");
}

if (!hasQuestions) {
    out.println("<p>No questions found matching your criteria.</p>");
}

conn.close();
%>

</body>
</html>