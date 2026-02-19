<%@ page import="java.rmi.Naming, common.InventoryService, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // ၁။ Security & Session Check
    Object roleObj = session.getAttribute("role");
    if (roleObj == null || !"STOREKEEPER".equalsIgnoreCase(roleObj.toString())) {
        response.sendRedirect("../login.jsp");
        return;
    }

    int myBranchId = (int) session.getAttribute("branch_id");
    InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");

    // ၂။ ဒေတာများ ဆွဲယူခြင်း
    Map<String, Object> summary = service.getBranchStats(myBranchId);
    List<String[]> alerts = service.getLowStockAlerts(myBranchId, 5);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Live Console | OMNI FLOW</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <style>
        body { background-color: #F8FAFC; color: #1E293B; }
        /* Main Content ကို Sidebar space အတွက် ml-72 ပေးထားပြီး Header အတွက် pt-24 ပေးထားပါသည် */
        .main-content { margin-left: 280px; padding-top: 90px; transition: all 0.4s ease; }
        @media (max-width: 1024px) { .main-content { margin-left: 0; } }

        .executive-card { background: white; border: 1px solid rgba(99, 102, 241, 0.1); transition: all 0.3s ease; }
        .executive-card:hover { border-color: #6366f1; box-shadow: 0 25px 50px -12px rgba(99, 102, 241, 0.1); }

        .animate-reveal { animation: reveal 0.6s cubic-bezier(0.4, 0, 0.2, 1) forwards; opacity: 0; }
        @keyframes reveal { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
    </style>
</head>
<body class="font-sans antialiased selection:bg-indigo-100 selection:text-indigo-600">

<jsp:include page="/templates/sidebar_storekeeper.jsp" />

<main class="main-content min-h-screen p-6 lg:p-12 relative">
    <jsp:include page="/includes/header.jsp" />

    <%-- 1. Hero Title Section --%>
    <div class="mb-14 flex flex-col xl:flex-row justify-between items-start xl:items-end gap-8 animate-reveal">
        <div class="space-y-3">
            <h2 class="text-6xl font-black text-slate-900 tracking-tighter leading-none italic uppercase">
                Live <span class="text-indigo-600">Console</span>
            </h2>
            <div class="flex items-center gap-4">
                <span class="w-12 h-1 bg-indigo-500 rounded-full"></span>
                <p class="text-slate-400 text-[10px] font-black uppercase tracking-[0.5em] italic leading-none">
                    Node: <%= session.getAttribute("branch_name") != null ? session.getAttribute("branch_name") : "Logistics Hub" %>
                </p>
            </div>
        </div>

        <div class="flex gap-4">
            <a href="stock_in.jsp" class="bg-indigo-600 text-white px-10 py-5 rounded-[2.5rem] font-black text-[10px] uppercase tracking-widest hover:bg-slate-900 transition-all shadow-xl shadow-indigo-100 flex items-center gap-3">
                <i class="fas fa-plus-circle text-indigo-300"></i> Register Inbound
            </a>
        </div>
    </div>

    <%-- 2. Performance Metrics --%>
    <div class="grid grid-cols-1 xl:grid-cols-3 gap-8 mb-12 animate-reveal" style="animation-delay: 0.1s;">
        <%-- Total Items Card --%>
        <div class="executive-card p-10 rounded-[3.5rem] relative overflow-hidden group">
            <div class="w-16 h-16 bg-slate-50 rounded-2xl flex items-center justify-center text-slate-400 group-hover:bg-indigo-600 group-hover:text-white transition-all duration-500 shadow-inner mb-8">
                <i class="fas fa-boxes-stacked text-xl"></i>
            </div>
            <div>
                <span class="text-[9px] font-black text-slate-400 uppercase tracking-widest block mb-2">Local Asset Registry</span>
                <p class="text-5xl font-black text-slate-900 tracking-tighter italic">
                    <%= String.format("%,d", (summary != null) ? (Long)summary.get("total_items") : 0) %>
                    <span class="text-xs not-italic text-slate-300 ml-2 uppercase">Units</span>
                </p>
            </div>
            <i class="fas fa-cube absolute -right-6 -bottom-6 text-8xl text-slate-50 group-hover:text-indigo-50 transition-colors"></i>
        </div>

        <%-- Node Valuation Card (Large) --%>
        <div class="xl:col-span-2 bg-slate-950 p-10 rounded-[3.5rem] shadow-2xl flex flex-col md:flex-row items-center justify-between group relative overflow-hidden border border-indigo-900/20">
            <div class="absolute -right-10 -top-10 text-[15rem] text-white/5 italic font-black pointer-events-none">SYNC</div>
            <div class="flex items-center gap-10 relative z-10">
                <div class="w-24 h-24 bg-indigo-500 text-white rounded-[2.5rem] flex items-center justify-center text-4xl shadow-[0_20px_40px_rgba(99,102,241,0.3)]">
                    <i class="fas fa-vault"></i>
                </div>
                <div>
                    <span class="text-indigo-400 text-[9px] font-black uppercase tracking-[0.4em] mb-3 block italic">Real-time Node Valuation</span>
                    <p class="text-6xl font-black text-white tracking-tighter uppercase italic leading-none">
                        <%= String.format("%,.0f", (summary != null) ? (Double)summary.get("inventory_value") : 0.0) %>
                        <span class="text-sm font-bold opacity-30 italic tracking-widest ml-3">MMK</span>
                    </p>
                </div>
            </div>
            <a href="my_inventory.jsp" class="relative z-10 mt-6 md:mt-0 w-20 h-20 bg-white/5 rounded-[2rem] flex items-center justify-center text-white hover:bg-indigo-500 transition-all shadow-xl backdrop-blur-md border border-white/5 group-hover:rotate-12 group-hover:scale-110">
                <i class="fas fa-arrow-right-long text-xl"></i>
            </a>
        </div>
    </div>

    <%-- 3. Safety Protocol Alert (Inventory Breach) --%>
    <div class="executive-card rounded-[4rem] overflow-hidden animate-reveal shadow-sm" style="animation-delay: 0.2s;">
        <div class="p-10 border-b border-slate-50 flex flex-wrap justify-between items-center bg-slate-50/40">
            <div>
                <h3 class="text-2xl font-black italic uppercase text-slate-800 tracking-tighter leading-none">Inventory Breach Monitor</h3>
                <p class="text-[9px] text-slate-400 font-bold uppercase tracking-widest mt-3 italic">Automated Threshold Surveillance System</p>
            </div>
            <div class="flex items-center gap-4 bg-rose-50 px-8 py-3 rounded-full border border-rose-100 animate-pulse mt-4 md:mt-0">
                <span class="w-3 h-3 bg-rose-500 rounded-full shadow-[0_0_15px_rgba(244,63,94,0.8)]"></span>
                <span class="text-rose-600 text-[10px] font-black uppercase tracking-[0.2em]">Active Depletion Detected</span>
            </div>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse">
                <tbody class="divide-y divide-slate-50">
                <% if(alerts == null || alerts.isEmpty()) { %>
                <tr>
                    <td class="p-32 text-center">
                        <div class="flex flex-col items-center opacity-20">
                            <i class="fas fa-shield-check text-6xl mb-4"></i>
                            <p class="font-black italic uppercase tracking-[0.4em] text-[10px]">All Local Nodes are Synchronized and Balanced</p>
                        </div>
                    </td>
                </tr>
                <% } else {
                    for(String[] a : alerts) { %>
                <tr class="hover:bg-rose-50/30 transition-all duration-500 group">
                    <td class="p-10">
                        <div class="flex items-center gap-10">
                            <div class="w-20 h-20 bg-rose-50 text-rose-500 rounded-[2rem] flex items-center justify-center text-2xl shadow-inner group-hover:bg-rose-500 group-hover:text-white transition-all duration-500 group-hover:rotate-6">
                                <i class="fas fa-triangle-exclamation"></i>
                            </div>
                            <div>
                                <span class="font-black text-slate-800 block text-2xl italic uppercase tracking-tighter leading-none mb-3"><%= a[1] %></span>
                                <div class="flex items-center gap-3">
                                    <span class="text-[10px] bg-rose-100 text-rose-600 font-black px-4 py-1.5 rounded-lg uppercase tracking-wider italic">Critical Level: <%= a[2] %> Units</span>
                                    <span class="text-[9px] text-slate-400 font-bold uppercase tracking-widest italic opacity-60">Handshake ID: #SR-<%= a[0] %></span>
                                </div>
                            </div>
                        </div>
                    </td>
                    <td class="p-10 text-right">
                        <a href="stock_in.jsp?refill=<%= a[0] %>" class="inline-flex items-center gap-5 bg-slate-900 text-white px-12 py-6 rounded-[2.5rem] text-[10px] font-black uppercase tracking-[0.2em] hover:bg-indigo-600 transition-all shadow-2xl active:scale-95 group-hover:-translate-x-4">
                            Refill Asset <i class="fas fa-arrow-right-long opacity-50"></i>
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

<script>
    // Header Sync Check
    console.log("Terminal Operations: Online");
</script>

</body>
</html>