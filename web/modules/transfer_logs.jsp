<%@ page import="java.rmi.Naming, common.InventoryService, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // ၁။ Security Check
    if (session.getAttribute("user_id") == null || !"Manager".equals(session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp"); return;
    }
    request.setAttribute("active_page", "transfer_logs.jsp");

    int branchId = (int) session.getAttribute("branch_id");
    String dateFilter = request.getParameter("log_date");

    // ၂။ RMI Connection
    InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");
    List<String[]> logs = service.getBranchAuditLogs(branchId, dateFilter);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Operation Traces | OMNI FLOW</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body { background-color: #F8FAFC; color: #1E293B; }
        .main-content { margin-left: 320px; transition: all 0.4s ease; }
        @media (max-width: 1024px) { .main-content { margin-left: 0; } }

        .executive-card { background: white; border: 1px solid rgba(99, 102, 241, 0.1); transition: all 0.3s ease; }
        .executive-card:hover { border-color: #6366f1; box-shadow: 0 20px 40px -15px rgba(99, 102, 241, 0.1); }

        .animate-reveal { animation: reveal 0.6s ease-out forwards; opacity: 0; }
        @keyframes reveal { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }

        /* Time Indicator Dot */
        .time-dot { width: 8px; height: 8px; border-radius: 50%; background: #6366f1; position: relative; }
        .time-dot::after { content: ''; position: absolute; inset: -4px; border: 1px solid #6366f1; border-radius: 50%; opacity: 0.3; }
    </style>
</head>
<body class="font-sans antialiased">

<jsp:include page="/templates/sidebar_manager.jsp" />

<main class="main-content min-h-screen p-6 lg:p-12 relative">
    <jsp:include page="/includes/header.jsp" />

    <%-- 1. Header Section --%>
    <div class="mb-12 flex flex-col xl:flex-row justify-between items-start xl:items-center gap-8 animate-reveal">
        <div class="space-y-2">
            <h2 class="text-6xl font-black text-slate-900 tracking-tighter leading-none italic uppercase">
                Operation <span class="text-indigo-600">Traces</span>
            </h2>
            <div class="flex items-center gap-4">
                <span class="w-12 h-1 bg-indigo-500 rounded-full"></span>
                <p class="text-slate-400 text-[9px] font-bold uppercase tracking-[0.5em]">Forensic Node Activity Logs</p>
            </div>
        </div>

        <%-- Date Filter Form --%>
        <form action="" method="GET" class="no-print bg-white p-4 rounded-3xl shadow-sm border border-slate-100 flex items-center gap-4">
            <div class="flex items-center gap-3 px-4 py-2 bg-slate-50 rounded-xl">
                <i class="fas fa-calendar-day text-indigo-400 text-xs"></i>
                <input type="date" name="log_date" value="<%= (dateFilter != null) ? dateFilter : "" %>"
                       class="bg-transparent border-none text-[10px] font-black uppercase outline-none text-slate-600">
            </div>
            <button type="submit" class="bg-indigo-600 text-white px-8 py-3 rounded-xl font-black uppercase text-[10px] tracking-widest hover:bg-slate-900 transition-all shadow-lg shadow-indigo-100">
                Sync Logs
            </button>
            <% if(dateFilter != null && !dateFilter.isEmpty()) { %>
            <a href="transfer_logs.jsp" class="text-[9px] font-black uppercase text-rose-500 px-2 hover:underline">Reset</a>
            <% } %>
        </form>
    </div>

    <%-- 2. Audit Trail Analytics Table --%>
    <div class="executive-card rounded-[4rem] overflow-hidden animate-reveal" style="animation-delay: 0.2s;">
        <div class="p-10 border-b border-slate-50 flex justify-between items-center bg-slate-50/30">
            <div>
                <h3 class="text-2xl font-black italic uppercase text-slate-800 tracking-tighter leading-none">Security Audit Trail</h3>
                <p class="text-[9px] font-black text-slate-400 uppercase tracking-widest mt-2">Sequential processing of local node events</p>
            </div>
            <div class="w-12 h-12 rounded-2xl bg-white border border-slate-100 flex items-center justify-center text-indigo-500 shadow-sm">
                <i class="fas fa-terminal text-sm"></i>
            </div>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-left">
                <thead class="bg-slate-50 text-[10px] font-black uppercase text-slate-400 tracking-[0.2em] border-b border-slate-100">
                <tr>
                    <th class="p-10">Time Sequence</th>
                    <th class="p-10">Operator Node</th>
                    <th class="p-10">Operational Payload</th>
                </tr>
                </thead>
                <tbody class="divide-y divide-slate-50">
                <% if(logs == null || logs.isEmpty()) { %>
                <tr>
                    <td colspan="3" class="p-32 text-center">
                        <div class="flex flex-col items-center opacity-20">
                            <i class="fas fa-fingerprint text-6xl mb-4"></i>
                            <p class="font-black italic uppercase tracking-[0.4em] text-[10px]">No active traces in node memory</p>
                        </div>
                    </td>
                </tr>
                <% } else {
                    for(String[] l : logs) { %>
                <tr class="hover:bg-indigo-50/40 transition-all duration-300 group">
                    <td class="p-10">
                        <div class="flex items-center gap-4">
                            <div class="time-dot"></div>
                            <div>
                                <span class="font-black text-slate-800 text-sm block leading-none mb-1"><%= l[0].split(" ")[0] %></span>
                                <span class="text-[9px] text-indigo-500 font-black italic uppercase tracking-widest leading-none"><%= l[0].split(" ")[1] %></span>
                            </div>
                        </div>
                    </td>
                    <td class="p-10">
                        <div class="inline-flex items-center gap-3 px-4 py-2 bg-slate-50 rounded-xl border border-transparent group-hover:border-indigo-100 transition-all">
                            <i class="fas fa-user-shield text-[10px] text-slate-400"></i>
                            <span class="font-black text-slate-700 uppercase italic tracking-tighter text-xs">
                                @<%= l[1] %>
                            </span>
                        </div>
                    </td>
                    <td class="p-10">
                        <div class="relative pl-6 before:absolute before:left-0 before:top-1 before:bottom-1 before:w-1 before:bg-indigo-100 before:rounded-full">
                            <p class="text-slate-500 font-bold leading-relaxed text-xs italic">
                                "<%= l[2] %>"
                            </p>
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