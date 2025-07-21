<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336final.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Manage Customer Questions</title>
<style>
    .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
    .question-card { border: 1px solid #ddd; margin: 15px 0; padding: 15px; border-radius: 8px; }
    .pending { border-left: 4px solid #ffc107; background: #fff9c4; }
    .answered { border-left: 4px solid #28a745; background: #f8fff8; }
    .question-header { display: flex; justify-content: between; align-items: center; margin-bottom: 10px; }
    .question-meta { font-size: 12px; color: #666; }
    .question-text { font-size: 16px; margin: 10px 0; }
    .answer-section { background: #f8f9fa; padding: 10px; margin: 10px 0; border-radius: 4px; }
    .btn { display: inline-block; padding: 8px 12px; margin: 5px; text-decoration: none; border-radius: 4px; }
    .btn-primary { background: #007cba; color: white; border: none; cursor: pointer; }
    .btn-success { background: #28a745; color: white; border: none; cursor: pointer; }
    .btn-danger { background: #dc3545; color: white; }
    .btn:hover { opacity: 0.8; }
    textarea { width: 100%; min-height: 80px; padding: 8px; border: 1px solid #ddd; border-radius: 4px; }
    .search-box { margin: 20px 0; padding: 15px; background: #f8f9fa; border-radius: 8px; }
</style>
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
                message = "<div style='background: #d4edda; color: #155724; padding: 10px; border-radius: 4px; margin: 10px 0;'>Question answered successfully!</div>";
            }
        } catch (Exception e) {
            message = "<div style='background: #f8d7da; color: #721c24; padding: 10px; border-radius: 4px; margin: 10px 0;'>Error answering question: " + e.getMessage() + "</div>";
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

<div class="container">
    <h1>❓ Manage Customer Questions</h1>
    <p><a href="repPanel.jsp">← Back to Rep Panel</a> | <a href="browseQuestions.jsp">Browse All Q&A</a></p>
    
    <%= message %>
    
    <div class="search-box">
        <h3>🔍 Search Questions</h3>
        <form method="get">
            <div style="display: grid; grid-template-columns: 1fr 200px 100px; gap: 10px; align-items: end;">
                <div>
                    <label>Search by keyword:</label>
                    <input type="text" name="searchKeyword" placeholder="Search in questions and answers..." value="<%= searchKeyword != null ? searchKeyword : "" %>">
                </div>
                <div>
                    <label>Status:</label>
                    <select name="statusFilter">
                        <option value="">All Status</option>
                        <option value="pending" <%= "pending".equals(statusFilter) ? "selected" : "" %>>Pending</option>
                        <option value="answered" <%= "answered".equals(statusFilter) ? "selected" : "" %>>Answered</option>
                    </select>
                </div>
                <button type="submit" class="btn btn-primary">Search</button>
            </div>
        </form>
    </div>
    
    <div>
        <%
        boolean hasQuestions = false;
        while(questionsResult.next()) {
            hasQuestions = true;
            int questionId = questionsResult.getInt("question_id");
            String status = questionsResult.getString("status");
            String customerName = questionsResult.getString("firstname") + " " + questionsResult.getString("lastname");
            String customerUsername = questionsResult.getString("customer_username");
            
            out.println("<div class='question-card " + status + "'>");
            out.println("<div class='question-header'>");
            out.println("<div>");
            out.println("<strong>Question #" + questionId + "</strong> - " + status.toUpperCase());
            out.println("<div class='question-meta'>From: " + customerName + " (" + customerUsername + ") | " + questionsResult.getTimestamp("created_date") + "</div>");
            out.println("</div>");
            out.println("</div>");
            
            out.println("<div class='question-text'>");
            out.println("<strong>Question:</strong> " + questionsResult.getString("question_text"));
            out.println("</div>");
            
            if ("answered".equals(status)) {
                out.println("<div class='answer-section'>");
                out.println("<strong>Answer:</strong> " + questionsResult.getString("answer_text"));
                out.println("<div class='question-meta'>Answered by: " + questionsResult.getString("rep_username") + " on " + questionsResult.getTimestamp("answered_date") + "</div>");
                out.println("</div>");
            } else {
                out.println("<form method='post'>");
                out.println("<input type='hidden' name='answerQuestionId' value='" + questionId + "'>");
                out.println("<div style='margin: 10px 0;'>");
                out.println("<label><strong>Your Answer:</strong></label>");
                out.println("<textarea name='answerText' placeholder='Type your answer here...' required></textarea>");
                out.println("</div>");
                out.println("<button type='submit' class='btn btn-success'>Submit Answer</button>");
                out.println("</form>");
            }
            
            out.println("</div>");
        }
        
        if (!hasQuestions) {
            out.println("<div class='question-card'>");
            out.println("<p>No questions found matching your criteria.</p>");
            out.println("</div>");
        }
        
        conn.close();
        %>
    </div>
</div>

</body>
</html>