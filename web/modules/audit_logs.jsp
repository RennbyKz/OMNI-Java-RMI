<%@ page import="java.rmi.Naming, common.InventoryService, java.util.List, java.text.SimpleDateFormat" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  if (session.getAttribute("user_id") == null || !session.getAttribute("role").equals("Admin")) {
    response.sendRedirect("../login.jsp");
    return;
  }
  request.setAttribute("active_page", "audit_logs");
  String method = request.getMethod();
  InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");
  String delIdParam = request.getParameter("delete_id");

  if ("GET".equalsIgnoreCase(method) && delIdParam != null && !delIdParam.trim().isEmpty()) {
    try {
      service.deleteLog(Integer.parseInt(delIdParam.trim()));
      response.sendRedirect("audit_logs.jsp?msg=deleted");
      return;
    } catch (Exception e) {
      response.sendRedirect("audit_logs.jsp?msg=error");
      return;
    }
  }
  if ("POST".equalsIgnoreCase(method) && request.getParameter("clear_all") != null) {
    service.clearAllLogs();
    response.sendRedirect("audit_logs.jsp?msg=cleared");
    return;
  }

  String selBranch = request.getParameter("branch_id") != null ? request.getParameter("branch_id") : "ALL";
  String selDate = request.getParameter("log_date") != null ? request.getParameter("log_date") : "";

  List<String[]> logs = service.getAllLogs(selBranch, selDate);
  List<String[]> branches = service.getBranches();
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>System Trace | OMNI CORE</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
  <style>
    body { background-color: #F6F4F0; scroll-behavior: smooth; }
    .main-content { margin-left: 290px; transition: all 0.4s ease; }
    @media (max-width: 1024px) { .main-content { margin-left: 0; } }

    .glass-card { background: rgba(255, 255, 255, 0.7); backdrop-filter: blur(12px); border: 1px solid rgba(77, 161, 169, 0.15); }
    .btn-action { transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
    .btn-action:hover { transform: translateY(-2px); shadow: 0 10px 15px -3px rgba(0,0,0,0.1); }

    .log-table thead th { background-color: #F6F4F0; color: #4DA1A9; }
    .custom-select { appearance: none; background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='%234DA1A9'%3E%3Cpath stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='C19 9l-7 7-7-7'%3E%3C/path%3E%3C/svg%3E"); background-repeat: no-repeat; background-position: right 0.5rem center; background-size: 1.2em; }
  </style>
</head>
<body class="font-sans text-[#2E5077] antialiased">

<jsp:include page="/templates/sidebar_admin.jsp"/>

<main class="main-content min-h-screen p-6 lg:p-10 relative">
  <jsp:include page="/includes/header.jsp"/>

  <%-- Page Header --%>
  <div class="mb-10 flex flex-col xl:flex-row justify-between items-start xl:items-end gap-6 no-print px-4 mt-10">
    <div>

      <div class="flex items-center gap-3 mt-3">
        <span class="w-10 h-1 bg-[#79D7BE] rounded-full"></span>
        <p class="text-[#4DA1A9] text-[10px] font-bold uppercase tracking-[0.3em]">Immutable Security Protocol Logs</p>
      </div>
    </div>

    <div class="flex flex-wrap items-center gap-4">
      <button onclick="window.print()" class="bg-white text-[#2E5077] border border-[#4DA1A9]/20 px-6 py-4 rounded-2xl font-bold text-[10px] uppercase tracking-widest hover:bg-[#F6F4F0] transition shadow-sm flex items-center gap-2">
        <i class="fas fa-file-invoice text-[#4DA1A9]"></i> Generate Audit Report
      </button>

      <form action="audit_logs.jsp" method="POST" onsubmit="return confirmClear(event)" class="inline">
        <input type="hidden" name="clear_all" value="true">
        <button type="submit" class="bg-rose-50 text-rose-500 border border-rose-100 px-6 py-4 rounded-2xl font-black text-[10px] uppercase tracking-widest hover:bg-rose-500 hover:text-white transition-all shadow-sm">
          <i class="fas fa-eraser mr-2"></i> Purge History
        </button>
      </form>
    </div>
  </div>

  <%-- Filter Dashboard --%>
  <div class="px-4 mb-8 no-print">
    <div class="glass-card p-5 rounded-[2.5rem] flex flex-wrap gap-4 items-center">
      <form method="GET" class="flex flex-wrap items-center gap-4 flex-1">
        <div class="relative min-w-[200px] flex-1 lg:flex-none">
          <i class="fas fa-globe absolute left-4 top-1/2 -translate-y-1/2 text-[#79D7BE] text-xs"></i>
          <select name="branch_id" class="custom-select w-full pl-10 pr-10 py-3 bg-[#F6F4F0] border-none rounded-xl font-bold text-[11px] uppercase tracking-wider text-[#2E5077] focus:ring-2 focus:ring-[#79D7BE] outline-none cursor-pointer">
            <option value="ALL">Global Node Scope</option>
            <% for (String[] b : branches) { %>
            <option value="<%= b[0] %>" <%= selBranch.equals(b[0]) ? "selected" : "" %>><%= b[1] %></option>
            <% } %>
          </select>
        </div>

        <div class="relative flex-1 lg:flex-none">
          <input type="date" name="log_date" value="<%= selDate %>" class="w-full bg-[#F6F4F0] border-none rounded-xl px-5 py-3 text-[11px] font-bold text-[#2E5077] outline-none focus:ring-2 focus:ring-[#79D7BE] uppercase">
        </div>

        <button type="submit" class="bg-[#2E5077] text-white px-8 py-3 rounded-xl text-[11px] font-black uppercase tracking-widest hover:bg-[#4DA1A9] transition shadow-md">
          Apply Filter
        </button>

        <% if(!selDate.isEmpty() || !selBranch.equals("ALL")) { %>
        <a href="audit_logs.jsp" class="text-rose-400 text-[10px] font-bold uppercase tracking-widest hover:underline">Reset</a>
        <% } %>
      </form>
    </div>
  </div>

  <%-- Audit Table --%>
  <div class="px-4 mb-10">
    <div class="bg-white rounded-[3rem] shadow-xl shadow-slate-200/50 overflow-hidden border border-[#4DA1A9]/10">
      <table class="w-full text-left log-table">
        <thead>
        <tr class="text-[9px] uppercase font-black tracking-[0.2em] border-b border-[#F6F4F0]">
          <th class="px-10 py-6">Handshake Timestamp</th>
          <th class="px-10 py-6">Operator Identity</th>
          <th class="px-10 py-6">Operation Details</th>
          <th class="px-10 py-6">Source Node</th>
          <th class="px-10 py-6 text-right no-print">Command</th>
        </tr>
        </thead>
        <tbody class="divide-y divide-[#F6F4F0]">
        <% if(logs != null && !logs.isEmpty()) {
          for (String[] l : logs) { %>
        <tr class="hover:bg-[#F6F4F0]/50 transition-all duration-300 group">
          <td class="px-10 py-8">
            <span class="font-bold text-[#2E5077] text-sm block tracking-tighter"><%= l[1].split(" ")[0] %></span>
            <div class="flex items-center gap-2 mt-1.5">
              <span class="w-1.5 h-1.5 bg-[#79D7BE] rounded-full"></span>
              <span class="text-[9px] text-[#4DA1A9] font-black uppercase tracking-tighter italic">
                                <%= l[1].split(" ")[1] %>
                            </span>
            </div>
          </td>
          <td class="px-10 py-8">
                        <span class="font-black text-[#2E5077] uppercase text-[11px] italic tracking-tight bg-[#F6F4F0] px-3 py-1 rounded-lg">
                            <i class="fas fa-user-shield mr-2 text-[#4DA1A9]"></i><%= l[2] %>
                        </span>
          </td>
          <td class="px-10 py-8">
            <p class="text-slate-500 font-bold leading-relaxed text-[11px] italic group-hover:text-[#2E5077] transition-colors">
              "<%= l[3] %>"
            </p>
          </td>
          <td class="px-10 py-8">
            <div class="flex items-center gap-2">
              <i class="fas fa-network-wired text-[#79D7BE] text-[10px]"></i>
              <span class="text-[10px] font-black text-slate-400 uppercase tracking-widest"><%= l[4] %></span>
            </div>
          </td>
          <td class="px-10 py-8 text-right no-print">
            <button onclick="confirmDelete(<%= l[0] %>)" class="w-10 h-10 bg-rose-50 text-rose-300 rounded-xl hover:bg-rose-500 hover:text-white transition-all shadow-sm inline-flex items-center justify-center">
              <i class="fas fa-trash-alt text-xs"></i>
            </button>
          </td>
        </tr>
        <% } } else { %>
        <tr>
          <td colspan="5" class="p-24 text-center">
            <i class="fas fa-fingerprint text-slate-100 text-6xl mb-4"></i>
            <p class="font-bold text-slate-300 italic uppercase tracking-widest text-xs">No activity traces detected in current scope</p>
          </td>
        </tr>
        <% } %>
        </tbody>
      </table>
    </div>
  </div>

  <jsp:include page="/includes/footer.jsp"/>
</main>



<script>
  function confirmDelete(id) {
    Swal.fire({
      title: '<span class="uppercase italic tracking-tighter">Remove Trace?</span>',
      text: "This specific audit entry will be permanently redacted from the system.",
      icon: 'warning',
      showCancelButton: true,
      confirmButtonColor: '#2E5077',
      cancelButtonColor: '#F6F4F0',
      confirmButtonText: 'CONFIRM DELETE',
      background: '#F6F4F0',
      customClass: { popup: 'rounded-[2rem]' }
    }).then((result) => {
      if (result.isConfirmed) window.location.href = 'audit_logs.jsp?delete_id=' + id;
    });
  }

  function confirmClear(e) {
    e.preventDefault();
    Swal.fire({
      title: '<span class="uppercase italic tracking-tighter text-rose-500">System Purge?</span>',
      text: "CRITICAL: This action will permanently erase the entire operational history!",
      icon: 'error',
      showCancelButton: true,
      confirmButtonColor: '#f43f5e',
      confirmButtonText: 'YES, PURGE ALL',
      background: '#F6F4F0',
      customClass: { popup: 'rounded-[2rem]' }
    }).then((result) => {
      if (result.isConfirmed) e.target.submit();
    });
  }

  // Success Alerts
  const params = new URLSearchParams(window.location.search);
  if(params.get('msg') === 'deleted') {
    Swal.fire({ icon: 'success', title: 'TRACE REMOVED', text: 'Specific log entry deleted.', confirmButtonColor: '#2E5077', background: '#F6F4F0', customClass: { popup: 'rounded-[2rem]' } });
  } else if(params.get('msg') === 'cleared') {
    Swal.fire({ icon: 'success', title: 'SYSTEM PURGED', text: 'Operational history cleared.', confirmButtonColor: '#2E5077', background: '#F6F4F0', customClass: { popup: 'rounded-[2rem]' } });
  }
</script>
</body>
</html>