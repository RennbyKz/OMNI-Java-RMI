<%@ page import="java.rmi.Naming, common.InventoryService, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // ၁။ Security Check
    if (session.getAttribute("user_id") == null || !"Manager".equals(session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp"); return;
    }

    String userIdStr = request.getParameter("uid");
    if (userIdStr == null || userIdStr.isEmpty()) {
        response.sendRedirect("branch_staff.jsp"); return;
    }

    int userId = Integer.parseInt(userIdStr);
    InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");
    List<String[]> logs = service.getStaffAuditLogs(userId);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Activity Trace | OMNI FLOW</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <style>
        body { background-color: #F8FAFC; color: #1E293B; }
        .main-content { margin-left: 320px; transition: all 0.4s ease; }
        @media (max-width: 1024px) { .main-content { margin-left: 0; } }

        .executive-card { background: white; border: 1px solid rgba(99, 102, 241, 0.1); transition: all 0.3s ease; }

        /* Timeline Vertical Line */
        .timeline-line { position: relative; }
        .timeline-line::before {
            content: ''; position: absolute; left: 31px; top: 0; bottom: 0;
            width: 2px; background: linear-gradient(to bottom, #6366f1 0%, #e2e8f0 100%);
            opacity: 0.2;
        }

        .animate-reveal { animation: reveal 0.6s cubic-bezier(0.4, 0, 0.2, 1) forwards; opacity: 0; }
        @keyframes reveal { from { opacity: 0; transform: translateX(-20px); } to { opacity: 1; transform: translateX(0); } }
    </style>
</head>
<body class="font-sans antialiased">

<jsp:include page="/templates/sidebar_manager.jsp" />

<main class="main-content min-h-screen p-6 lg:p-12 relative">
    <jsp:include page="/includes/header.jsp" />

    <%-- Page Header & Back Navigation --%>
    <div class="mb-14 flex flex-col md:flex-row justify-between items-start md:items-center gap-6 animate-reveal">
        <div class="space-y-3">
            <a href="branch_staff.jsp" class="inline-flex items-center gap-2 text-indigo-500 hover:text-indigo-700 transition-all font-black uppercase text-[10px] tracking-widest group">
                <i class="fas fa-chevron-left group-hover:-translate-x-1 transition-transform"></i> Return to Personnel Hub
            </a>
            <h2 class="text-6xl font-black text-slate-900 tracking-tighter leading-none italic uppercase">
                Operator <span class="text-indigo-600">Trace</span>
            </h2>
            <div class="flex items-center gap-4">
                <span class="w-12 h-1 bg-indigo-500 rounded-full"></span>
                <p class="text-slate-400 text-[9px] font-black uppercase tracking-[0.5em] italic">Behavioral Forensic Log</p>
            </div>
        </div>

        <div class="px-6 py-4 bg-white border border-slate-100 rounded-3xl shadow-sm">
            <span class="text-[8px] font-black text-slate-400 uppercase tracking-widest block mb-1">Target ID</span>
            <code class="text-indigo-600 font-black text-sm uppercase">#OP-NODE-0<%= userId %></code>
        </div>
    </div>

    <%-- Activity Feed --%>
    <div class="max-w-5xl timeline-line">
        <% if(logs.isEmpty()) { %>
        <div class="ml-16 executive-card p-20 rounded-[4rem] text-center shadow-sm">
            <div class="w-20 h-20 bg-slate-50 rounded-full flex items-center justify-center mx-auto mb-6">
                <i class="fas fa-fingerprint text-3xl text-slate-200"></i>
            </div>
            <p class="text-slate-400 font-black italic uppercase tracking-[0.4em] text-[10px]">No historical handshake found in registry</p>
        </div>
        <% } else { %>
        <div class="space-y-8">
            <% for(String[] log : logs) { %>
            <div class="relative pl-16 animate-reveal">
                <%-- Timeline Node Dot --%>
                <div class="absolute left-[24px] top-1/2 -translate-y-1/2 w-4 h-4 rounded-full bg-white border-4 border-indigo-500 shadow-[0_0_10px_rgba(99,102,241,0.5)] z-10"></div>

                <div class="executive-card p-8 rounded-[3rem] flex items-center justify-between group hover:shadow-xl hover:shadow-indigo-50 transition-all duration-500">
                    <div class="flex items-center gap-8">
                        <div class="w-14 h-14 bg-slate-50 rounded-2xl flex items-center justify-center text-slate-400 group-hover:bg-indigo-600 group-hover:text-white transition-all duration-500">
                            <i class="fas fa-bolt-lightning text-lg"></i>
                        </div>
                        <div>
                            <p class="font-bold text-slate-700 text-[13px] italic leading-relaxed mb-1">
                                "<%= log[0] %>"
                            </p>
                            <span class="text-[9px] font-black text-indigo-400 uppercase tracking-[0.3em] italic">System handshake verified</span>
                        </div>
                    </div>

                    <div class="text-right border-l border-slate-50 pl-8">
                        <div class="flex flex-col">
                            <span class="text-xs font-black text-slate-900 tabular-nums tracking-tighter">
                                <%= log[1].split(" ")[0] %>
                            </span>
                            <span class="text-[10px] font-black text-indigo-500 italic mt-1 uppercase">
                                <%= log[1].split(" ")[1] %>
                            </span>
                        </div>
                        <span class="block text-[7px] font-black text-slate-300 uppercase tracking-widest mt-2">Log Sequence</span>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
        <% } %>
    </div>

    <jsp:include page="/includes/footer.jsp" />
</main>

</body>
</html>