<%@ page import="java.rmi.Naming, common.InventoryService, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // ၁။ Security & Session Check
    Object roleObj = session.getAttribute("role");
    if (roleObj == null || !"Supplier".equalsIgnoreCase(roleObj.toString())) {
        response.sendRedirect("../login.jsp");
        return;
    }

    int supplierId = (int) session.getAttribute("supplier_id");
    InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");

    // ၂။ Data Aggregation
    Map<String, Object> stats = service.getSupplierStats(supplierId);

    // ၃။ Stock Monitoring Data
    List<String[]> stockData = service.getSupplierInventoryMonitor(supplierId);

    // ၄။ Recent Orders
    List<String[]> orderRequests = service.getRecentSupplierOrders(supplierId, 5);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Partner Terminal | SupplyNode</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <style>
        body { background-color: #F8FAFC; color: #1E293B; }
        .main-content { margin-left: 320px; transition: all 0.4s ease; }
        @media (max-width: 1024px) { .main-content { margin-left: 0; } }

        .executive-card { background: white; border: 1px solid rgba(16, 185, 129, 0.1); transition: all 0.3s ease; }
        .executive-card:hover { border-color: #10b981; box-shadow: 0 25px 50px -12px rgba(16, 185, 129, 0.15); }

        .animate-reveal { animation: reveal 0.6s cubic-bezier(0.4, 0, 0.2, 1) forwards; opacity: 0; }
        @keyframes reveal { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
    </style>
</head>
<body class="font-sans antialiased">

<jsp:include page="/templates/supplier_sidebar.jsp" />

<main class="main-content min-h-screen p-6 lg:p-12 relative">
    <jsp:include page="/includes/header.jsp" />

    <%-- Page Header --%>
    <div class="mb-14 flex flex-col md:flex-row justify-between items-start md:items-end gap-6 animate-reveal">
        <div>
            <h2 class="text-6xl font-black text-slate-900 tracking-tighter uppercase italic leading-none">Partner <span class="text-emerald-500">Terminal</span></h2>
            <div class="flex items-center gap-4 mt-4">
                <span class="w-12 h-1 bg-emerald-500 rounded-full"></span>
                <p class="text-emerald-600/70 text-[10px] font-black uppercase tracking-[0.4em] italic leading-none">Supply Chain Intelligence Hub</p>
            </div>
        </div>
        <div class="bg-white px-8 py-5 rounded-[2.5rem] shadow-sm border border-slate-100 flex items-center gap-4">
            <span class="text-[8px] font-black text-slate-400 uppercase tracking-widest block mb-1">Node Status</span>
            <div class="flex items-center gap-2">
                <span class="w-2.5 h-2.5 bg-emerald-500 rounded-full animate-pulse shadow-[0_0_10px_#10b981]"></span>
                <span class="text-lg font-black italic text-slate-900 leading-none tracking-tighter uppercase">Synchronized</span>
            </div>
        </div>
    </div>

    <%-- Analytics Cards --%>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-8 mb-14 animate-reveal" style="animation-delay: 0.1s;">
        <div class="bg-slate-950 p-10 rounded-[3rem] shadow-2xl relative overflow-hidden group border border-emerald-500/20">
            <div class="relative z-10">
                <span class="text-[9px] font-black text-emerald-500/50 uppercase tracking-[0.3em] italic">Gross Business Value</span>
                <h4 class="text-4xl font-black text-white mt-4 italic tracking-tighter">
                    <%= String.format("%, .0f", Double.parseDouble(stats.getOrDefault("total_revenue", "0").toString())) %>
                    <span class="text-xs text-emerald-500/40 not-italic uppercase ml-2 tracking-widest">MMK</span>
                </h4>
            </div>
            <i class="fas fa-chart-line absolute -right-6 -bottom-6 text-[10rem] text-emerald-500/5 -rotate-12 group-hover:rotate-0 transition-transform duration-700"></i>
        </div>

        <div class="executive-card p-10 rounded-[3rem]">
            <span class="text-[9px] font-black text-slate-400 uppercase tracking-[0.3em]">Lifecycle Invoices</span>
            <h4 class="text-4xl font-black text-slate-900 mt-4 italic tracking-tighter">
                <%= stats.getOrDefault("total_invoices", "0") %>
                <span class="text-xs text-slate-300 not-italic uppercase ml-2 tracking-widest">Processed</span>
            </h4>
        </div>

        <div class="executive-card p-10 rounded-[3rem]">
            <span class="text-[9px] font-black text-slate-400 uppercase tracking-[0.3em]">Monitored SKUs</span>
            <h4 class="text-4xl font-black text-emerald-500 mt-4 italic tracking-tighter">
                <%= stockData.size() %>
                <span class="text-xs text-slate-300 not-italic uppercase ml-2 tracking-widest">Active Assets</span>
            </h4>
        </div>
    </div>

    <div class="grid grid-cols-1 xl:grid-cols-5 gap-10">

        <%-- Live Stock Monitoring (Left) --%>
        <div class="xl:col-span-2 space-y-8 animate-reveal" style="animation-delay: 0.2s;">
            <div class="executive-card p-10 rounded-[3.5rem] shadow-sm">
                <div class="flex justify-between items-center mb-10">
                    <div class="flex items-center gap-4">
                        <div class="w-12 h-12 bg-emerald-50 text-emerald-600 rounded-2xl flex items-center justify-center border border-emerald-100"><i class="fas fa-microchip"></i></div>
                        <h3 class="font-black italic uppercase text-slate-800 text-lg tracking-tighter">Stock Monitor</h3>
                    </div>
                    <span class="w-2.5 h-2.5 bg-emerald-500 rounded-full shadow-[0_0_10px_#10b981]"></span>
                </div>

                <div class="space-y-4">
                    <% if(stockData.isEmpty()) { %>
                    <div class="py-16 text-center border-2 border-dashed border-slate-100 rounded-[2.5rem]">
                        <i class="fas fa-ghost text-slate-200 text-3xl mb-4 block"></i>
                        <p class="text-[10px] font-black text-slate-300 uppercase italic tracking-widest">Zero assets detected</p>
                    </div>
                    <% } else {
                        for(String[] s : stockData) {
                            int qty = Integer.parseInt(s[1]);
                            int threshold = (s.length > 3) ? Integer.parseInt(s[3]) : 10;
                            boolean isLow = qty < threshold;
                    %>
                    <div class="group flex justify-between items-center p-7 bg-slate-50 rounded-[2.5rem] border border-transparent hover:border-emerald-200 hover:bg-white transition-all duration-500">
                        <div class="flex items-center gap-5">
                            <div class="w-1.5 h-8 <%= isLow ? "bg-rose-500" : "bg-emerald-500" %> rounded-full"></div>
                            <div>
                                <span class="font-black text-slate-800 block text-base italic uppercase tracking-tighter leading-none"><%= s[0] %></span>
                                <span class="text-[9px] font-black text-slate-400 uppercase tracking-widest mt-2 block italic opacity-60">Node: <%= s[2] %></span>
                            </div>
                        </div>
                        <div class="text-right">
                            <span class="text-2xl font-black <%= isLow ? "text-rose-500" : "text-slate-900" %> italic tracking-tighter"><%= qty %></span>
                            <span class="block text-[8px] font-black text-slate-300 uppercase mt-1">Units</span>
                        </div>
                    </div>
                    <% } } %>
                </div>
            </div>
        </div>

        <%-- Recent Orders (Right) --%>
        <div class="xl:col-span-3 space-y-8 animate-reveal" style="animation-delay: 0.3s;">
            <div class="executive-card p-10 rounded-[3.5rem] shadow-sm h-full overflow-hidden">
                <div class="flex justify-between items-center mb-10">
                    <div class="flex items-center gap-4">
                        <div class="w-12 h-12 bg-slate-900 text-white rounded-2xl flex items-center justify-center shadow-xl rotate-3"><i class="fas fa-truck-ramp-box"></i></div>
                        <h3 class="font-black italic uppercase text-slate-800 text-lg tracking-tighter">Acquisition Requests</h3>
                    </div>
                    <a href="supplier_orders.jsp" class="text-[10px] font-black uppercase text-emerald-600 hover:text-slate-900 tracking-widest transition-colors">Audit History <i class="fas fa-arrow-right-long ml-2"></i></a>
                </div>

                <div class="overflow-x-auto">
                    <table class="w-full text-left">
                        <tbody class="divide-y divide-slate-50">
                        <% if(orderRequests.isEmpty()) { %>
                        <tr><td class="py-20 text-center text-slate-300 font-black italic uppercase tracking-widest text-xs">Queue Clear: No pending handshakes</td></tr>
                        <% } else {
                            for(String[] o : orderRequests) { %>
                        <tr class="group hover:bg-emerald-50/30 transition-all duration-300">
                            <td class="py-7">
                                <span class="block text-slate-800 text-lg font-black uppercase italic tracking-tighter leading-none mb-2"><%= o[1] %></span>
                                <div class="flex items-center gap-3">
                                    <span class="w-2 h-2 rounded-full bg-emerald-500"></span>
                                    <span class="text-[9px] text-slate-400 uppercase font-black tracking-widest italic leading-none"><%= o[4] %></span>
                                </div>
                            </td>
                            <td class="py-7 text-center">
                                <div class="inline-block px-5 py-2 bg-slate-50 border border-slate-100 rounded-xl">
                                    <span class="font-black text-slate-900 text-sm italic">x<%= o[2] %></span>
                                </div>
                            </td>
                            <td class="py-7 text-right">
                                <% if("PENDING".equals(o[3])) { %>
                                <a href="supplier_orders.jsp?id=<%= o[0] %>"
                                   class="bg-emerald-500 text-white px-8 py-4 rounded-2xl text-[10px] font-black uppercase tracking-widest hover:bg-slate-900 transition shadow-xl shadow-emerald-500/20 active:scale-95 inline-block">
                                    Authorize Shipment
                                </a>
                                <% } else { %>
                                <span class="px-6 py-3 rounded-2xl text-[9px] font-black uppercase tracking-widest border
                                                <%= "SHIPPED".equals(o[3]) ? "bg-emerald-50 text-emerald-600 border-emerald-100" : "bg-indigo-50 text-indigo-600 border-indigo-100" %>">
                                                <%= o[3] %>
                                </span>
                                <% } %>
                            </td>
                        </tr>
                        <% } } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="/includes/footer.jsp" />
</main>
</body>
</html>