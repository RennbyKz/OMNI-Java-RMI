<%@ page import="java.rmi.Naming, common.InventoryService, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  // ၁။ Security Check
  if (session.getAttribute("user_id") == null || !"Manager".equals(session.getAttribute("role"))) {
    response.sendRedirect("../login.jsp"); return;
  }
  request.setAttribute("active_page", "branch_staff.jsp");

  int branchId = (int) session.getAttribute("branch_id");
  String branchName = (String) session.getAttribute("branch_name");

  // ၂။ RMI Connection
  InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");
  List<String[]> staffList = service.getBranchStaffWithActivity(branchId);
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Personnel Node | OMNI FLOW</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
  <style>
    body { background-color: #F8FAFC; color: #1E293B; }
    .main-content { margin-left: 320px; transition: all 0.4s ease; }
    @media (max-width: 1024px) { .main-content { margin-left: 0; } }

    .executive-card { background: white; border: 1px solid rgba(99, 102, 241, 0.1); transition: all 0.4s ease; }
    .executive-card:hover { border-color: #6366f1; box-shadow: 0 25px 50px -12px rgba(99, 102, 241, 0.12); }

    .animate-reveal { animation: reveal 0.7s cubic-bezier(0.4, 0, 0.2, 1) forwards; opacity: 0; }
    @keyframes reveal { from { opacity: 0; transform: translateY(30px); } to { opacity: 1; transform: translateY(0); } }

    .status-pulse { position: relative; }
    .status-pulse::after { content: ''; position: absolute; inset: -3px; border-radius: 50%; border: 2px solid currentColor; opacity: 0; animation: pulse 2s infinite; }
    @keyframes pulse { 0% { transform: scale(1); opacity: 0.5; } 100% { transform: scale(2.5); opacity: 0; } }
  </style>
</head>
<body class="font-sans antialiased">

<jsp:include page="/templates/sidebar_manager.jsp" />

<main class="main-content min-h-screen p-6 lg:p-12 relative">
  <jsp:include page="/includes/header.jsp" />

  <%-- 1. Hero Header Section --%>
  <div class="mb-14 flex flex-col xl:flex-row justify-between items-start xl:items-center gap-8 animate-reveal">
    <div class="space-y-3">
      <h2 class="text-6xl font-black text-slate-900 tracking-tighter leading-none italic uppercase">
        Personnel <span class="text-indigo-600">Node</span>
      </h2>
      <div class="flex items-center gap-4">
        <span class="w-12 h-1 bg-indigo-500 rounded-full"></span>
        <p class="text-slate-400 text-[10px] font-black uppercase tracking-[0.5em] italic leading-none">
          Active Operators: <%= branchName != null ? branchName : "Node Registry" %>
        </p>
      </div>
    </div>

    <div class="bg-white px-10 py-5 rounded-[2.5rem] shadow-sm border border-slate-100 flex items-center gap-5">
      <div class="w-12 h-12 bg-indigo-50 rounded-2xl flex items-center justify-center text-indigo-500">
        <i class="fas fa-users-viewfinder text-xl"></i>
      </div>
      <div>
        <span class="text-[8px] font-black text-slate-400 uppercase tracking-widest block mb-1">Total Unit Strength</span>
        <span class="text-3xl font-black text-slate-900 italic tracking-tighter leading-none"><%= staffList.size() %> Handlers</span>
      </div>
    </div>
  </div>

  <%-- 2. Staff Intelligence Table --%>
  <div class="executive-card rounded-[4rem] overflow-hidden animate-reveal shadow-sm" style="animation-delay: 0.2s;">
    <div class="p-10 border-b border-slate-50 flex justify-between items-center bg-slate-50/40">
      <div>
        <h3 class="text-2xl font-black italic uppercase text-slate-800 tracking-tighter leading-none">Security Clearance Registry</h3>
        <p class="text-[9px] font-black text-slate-400 uppercase tracking-widest mt-2">Verified Node Operators & Behavioral Traces</p>
      </div>
      <div class="w-12 h-12 rounded-2xl bg-white border border-slate-100 flex items-center justify-center text-indigo-500 shadow-sm">
        <i class="fas fa-id-card-clip text-sm"></i>
      </div>
    </div>

    <div class="overflow-x-auto">
      <table class="w-full text-left">
        <thead class="bg-slate-50 text-[10px] font-black uppercase text-slate-400 tracking-[0.25em] border-b border-slate-100">
        <tr>
          <th class="p-10">Identity Alias</th>
          <th class="p-10">Last Operational Handshake</th>
          <th class="p-10 text-center">Node State</th>
          <th class="p-10 text-right">Reference UID</th>
        </tr>
        </thead>
        <tbody class="divide-y divide-slate-50">
        <% if(staffList.isEmpty()) { %>
        <tr>
          <td colspan="4" class="p-32 text-center">
            <div class="flex flex-col items-center opacity-20">
              <i class="fas fa-user-slash text-6xl mb-4"></i>
              <p class="font-black italic uppercase tracking-[0.4em] text-[10px]">No operators detected in node memory</p>
            </div>
          </td>
        </tr>
        <% } else {
          for(String[] s : staffList) {
            boolean isActive = "ACTIVE".equals(s[2]);
        %>
        <tr class="hover:bg-indigo-50/40 transition-all duration-500 group">
          <td class="p-10">
            <div class="flex items-center gap-6">
              <div class="relative">
                <div class="w-16 h-16 bg-slate-100 rounded-[2rem] flex items-center justify-center text-slate-400 group-hover:bg-indigo-600 group-hover:text-white transition-all duration-500 shadow-inner overflow-hidden">
                  <i class="fas fa-user-tie text-2xl group-hover:scale-110 transition-transform"></i>
                </div>
                <div class="absolute -bottom-1 -right-1 w-5 h-5 rounded-full border-4 border-white <%= isActive ? "bg-emerald-500" : "bg-rose-500" %>"></div>
              </div>
              <div>
                <span class="font-black text-slate-800 block text-2xl italic uppercase tracking-tighter leading-none mb-2">@<%= s[1] %></span>
                <span class="text-[9px] font-bold text-indigo-400 uppercase tracking-widest bg-indigo-50 px-3 py-1 rounded-lg">Verified Operator</span>
              </div>
            </div>
          </td>

          <td class="p-10">
            <% if(s[3] != null && !s[3].equals("null") && !s[3].isEmpty()) { %>
            <div class="max-w-xs">
              <p class="text-[11px] font-bold text-slate-600 leading-relaxed italic mb-3 border-l-2 border-indigo-100 pl-4">
                "<%= s[3] %>"
              </p>
              <div class="flex items-center gap-3">
                 <span class="text-[9px] font-black text-indigo-500 uppercase tracking-widest bg-indigo-50 px-2 py-1 rounded flex items-center gap-1.5">
                    <i class="far fa-clock"></i> <%= s[4] %>
                 </span>
                <a href="staff_activity.jsp?uid=<%= s[0] %>" class="text-[8px] font-black uppercase text-slate-400 hover:text-indigo-600 transition-colors tracking-tighter underline underline-offset-4">
                  Inspect Trace <i class="fas fa-arrow-right ml-1"></i>
                </a>
              </div>
            </div>
            <% } else { %>
            <div class="flex items-center gap-3 text-slate-300">
              <i class="fas fa-ghost text-xs opacity-50"></i>
              <span class="text-[10px] font-bold uppercase italic tracking-widest">No recent traces detected</span>
            </div>
            <% } %>
          </td>

          <td class="p-10 text-center">
            <div class="inline-flex items-center gap-3 px-5 py-2.5 rounded-2xl <%= isActive ? "bg-emerald-50 text-emerald-600 border border-emerald-100" : "bg-rose-50 text-rose-500 border border-rose-100" %>">
              <span class="w-2 h-2 rounded-full <%= isActive ? "bg-emerald-500 status-pulse" : "bg-rose-500" %>"></span>
              <span class="font-black text-[10px] uppercase tracking-[0.2em] italic"><%= s[2] %></span>
            </div>
          </td>

          <td class="p-10 text-right">
            <div class="flex flex-col items-end">
              <span class="font-mono text-[10px] text-slate-300 font-bold tracking-tighter italic uppercase mb-1">Sync-Protocol</span>
              <span class="px-3 py-1 bg-slate-50 text-slate-400 rounded-lg font-black text-[9px] border border-slate-100 uppercase">#OP-0<%= s[0] %></span>
            </div>
          </td>
        </tr>
        <% } } %>
        </tbody>
      </table>
    </div>
  </div>

  <jsp:include page="/includes/footer.jsp" />
</main>

</body>
</html>