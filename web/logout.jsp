<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  // Session အားလုံးကို ဖျက်ဆီးခြင်း
  session.invalidate();
  // Login page သို့ message ဖြင့် ပြန်ပို့ခြင်း
  response.sendRedirect("login.jsp?msg=logged_out");
%>