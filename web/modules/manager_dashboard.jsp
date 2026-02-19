<%@ page import="java.rmi.Naming, common.InventoryService, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session.getAttribute("user_id") == null || !"Manager".equals(session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp"); return;
    }
    request.setAttribute("active_page", "manager_dashboard.jsp");

    Integer branchId = (Integer) session.getAttribute("branch_id");
    String branchName = (session.getAttribute("branch_name") != null) ? (String) session.getAttribute("branch_name") : "Local Node";
    Map<String, Object> stats = new HashMap<>();
    List<String[]> alerts = new ArrayList<>();

    try {
        InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");
        stats = service.getManagerStats(branchId != null ? branchId : 0);
        if (stats.containsKey("alerts")) { alerts = (List<String[]>) stats.get("alerts"); }
    } catch (Exception e) { e.printStackTrace(); }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Executive Console | OMNI FLOW</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body { background-color: #F8FAFC; color: #1E293B; }
        .main-content { margin-left: 320px; transition: all 0.4s ease; }
        @media (max-width: 1024px) { .main-content { margin-left: 0; } }

        /* New Layout Styles */
        .premium-card {
            background: white;
            border: 1px solid rgba(226, 232, 240, 0.8);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.02), 0 2px 4px -1px rgba(0, 0, 0, 0.01);
            transition: all 0.5s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .premium-card:hover {
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.05);
            transform: translateY(-5px);
            border-color: #6366f1;
        }

        /* Stats Circle */
        .stats-circle {
            background: conic-gradient(#6366f1 var(--progress), #F1F5F9 0deg);
            border-radius: 50%;
        }

        .animate-reveal { animation: reveal 0.8s ease-out forwards; opacity: 0; }
        @keyframes reveal { from { opacity: 0; transform: translateY(30px); } to { opacity: 1; transform: translateY(0); } }
    </style>
</head>
<body class="font-sans antialiased">

<jsp:include page="/templates/sidebar_manager.jsp" />

<main class="main-content min-h-screen p-6 lg:p-12 relative">
    <jsp:include page="/includes/header.jsp" />

    <%-- 1. Modern Welcome Header --%>
    <div class="mb-12 flex flex-col xl:flex-row justify-between items-start xl:items-center gap-8 animate-reveal">
        <div class="space-y-2">
            <h2 class="text-6xl font-black text-slate-900 tracking-tighter leading-none italic uppercase">
                Console <span class="text-indigo-600">Overview</span>
            </h2>
            <div class="flex items-center gap-4">
                <span class="w-12 h-1 bg-indigo-500 rounded-full"></span>
                <p class="text-slate-400 text-[10px] font-bold uppercase tracking-[0.5em]">Node Identity: <%= branchName %></p>
            </div>
        </div>

        <div class="flex gap-4">
            <button onclick="window.print()" class="p-5 bg-white border border-slate-200 rounded-2xl text-slate-400 hover:text-indigo-600 hover:border-indigo-200 transition-all">
                <i class="fas fa-print"></i>
            </button>
            <a href="stock_requests.jsp" class="bg-indigo-600 text-white px-10 py-5 rounded-[2rem] font-black text-[10px] uppercase tracking-widest hover:bg-slate-900 transition-all shadow-xl shadow-indigo-200 flex items-center gap-3">
                <i class="fas fa-plus"></i> Initiate Procurement
            </a>
        </div>
    </div>

    <%-- 2. Asymmetric Grid Layout (Main Stats) --%>
    <div class="grid grid-cols-1 xl:grid-cols-12 gap-8 mb-12 animate-reveal" style="animation-delay: 0.2s;">

        <%-- Large Summary Card --%>
        <div class="xl:col-span-8 premium-card p-10 rounded-[3.5rem] flex flex-col md:flex-row items-center gap-10">
            <div class="relative w-48 h-48 flex items-center justify-center">
                <svg class="w-full h-full transform -rotate-90">
                    <circle cx="96" cy="96" r="80" stroke="currentColor" stroke-width="12" fill="transparent" class="text-slate-100" />
                    <circle cx="96" cy="96" r="80" stroke="currentColor" stroke-width="12" fill="transparent" stroke-dasharray="502" stroke-dashoffset="150" class="text-indigo-600" />
                </svg>
                <div class="absolute inset-0 flex flex-col items-center justify-center">
                    <span class="text-4xl font-black text-slate-900 italic"><%= stats.getOrDefault("pendingRequests", 0) %></span>
                    <span class="text-[8px] font-black uppercase text-slate-400 tracking-widest">Active Syncs</span>
                </div>
            </div>
            <div class="flex-1 space-y-6">
                <div>
                    <h4 class="text-2xl font-black italic uppercase text-slate-800">Operational Integrity</h4>
                    <p class="text-xs text-slate-400 font-medium leading-relaxed">System is currently synchronizing local branch data with the central HQ node. No critical failures detected in transmission.</p>
                </div>
                <div class="flex gap-10">
                    <div>
                        <p class="text-[9px] font-black text-indigo-500 uppercase tracking-widest mb-1">Stock Value</p>
                        <p class="text-2xl font-black text-slate-900 italic"><%= String.format("%,.0f", stats.getOrDefault("totalValuation", 0.0)) %> <span class="text-[10px] not-italic text-slate-400">MMK</span></p>
                    </div>
                    <div>
                        <p class="text-[9px] font-black text-emerald-500 uppercase tracking-widest mb-1">Live SKUs</p>
                        <p class="text-2xl font-black text-slate-900 italic"><%= String.format("%,d", stats.getOrDefault("skus", 0)) %></p>
                    </div>
                </div>
            </div>
        </div>

        <%-- Quick Alert Box --%>
        <div class="xl:col-span-4 bg-indigo-600 rounded-[3.5rem] p-10 text-white flex flex-col justify-between shadow-2xl shadow-indigo-200 overflow-hidden relative group">
            <div class="relative z-10">
                <i class="fas fa-bell-on text-2xl mb-6 block text-indigo-300"></i>
                <h4 class="text-[10px] font-black uppercase tracking-[0.4em] mb-4 text-indigo-200">Alert Center</h4>
                <p class="text-4xl font-black italic leading-tight">Critical <br>Inventory <br>Detected</p>
            </div>
            <div class="relative z-10 mt-8">
                <a href="#alerts" class="inline-block bg-white text-indigo-600 px-8 py-3 rounded-full text-[9px] font-black uppercase tracking-widest hover:bg-indigo-50 transition-all">View Analytics</a>
            </div>
            <i class="fas fa-exclamation-triangle absolute -right-6 -bottom-6 text-9xl text-white/10 italic group-hover:scale-110 transition-transform duration-700"></i>
        </div>
    </div>

    <%-- 3. Alert Table --%>
    <div id="alerts" class="premium-card rounded-[4rem] overflow-hidden animate-reveal" style="animation-delay: 0.4s;">
        <div class="p-10 border-b border-slate-50 flex justify-between items-center">
            <div>
                <p class="text-[9px] font-black text-indigo-500 uppercase tracking-[0.3em] mb-2">Automated Report</p>
                <h3 class="text-3xl font-black text-slate-900 tracking-tighter italic uppercase leading-none">Restock Protocol</h3>
            </div>
            <div class="flex items-center gap-2 px-6 py-2 bg-indigo-50 rounded-full">
                <span class="w-2 h-2 bg-indigo-500 rounded-full animate-ping"></span>
                <span class="text-indigo-600 text-[9px] font-black uppercase tracking-widest">Live Sync Active</span>
            </div>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-left">
                <tbody class="divide-y divide-slate-50">
                <% if(alerts == null || alerts.isEmpty()) { %>
                <tr><td class="p-24 text-center text-slate-300 italic font-black uppercase tracking-[0.3em] text-xs">Security Clearance: No stock thresholds breached.</td></tr>
                <% } else {
                    for(String[] a : alerts) { %>
                <tr class="hover:bg-indigo-50/30 transition-all duration-300">
                    <td class="p-10">
                        <div class="flex items-center gap-8">
                            <div class="w-14 h-14 bg-slate-100 text-slate-400 rounded-3xl flex items-center justify-center text-xl">
                                <i class="fas fa-box-open"></i>
                            </div>
                            <div>
                                <span class="font-black text-slate-800 block text-xl italic uppercase tracking-tighter mb-1"><%= a[0] %></span>
                                <span class="text-[10px] text-slate-400 font-bold uppercase tracking-widest"><%= a[1] %></span>
                            </div>
                        </div>
                    </td>
                    <td class="p-10">
                        <p class="text-[9px] font-black text-rose-400 uppercase tracking-widest mb-1">On-Hand</p>
                        <span class="text-3xl font-black text-slate-900 italic tracking-tighter"><%= a[2] %></span>
                    </td>
                    <td class="p-10 text-right">
                        <a href="stock_requests.jsp?auto_refill=<%= a[0] %>" class="bg-slate-900 text-white px-8 py-4 rounded-2xl text-[9px] font-black uppercase tracking-widest hover:bg-indigo-600 transition-all shadow-lg inline-block">
                            Authorize Sync
                        </a>
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