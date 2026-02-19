<%@ page import="java.rmi.Naming, common.InventoryService, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // ၁။ Security & Session Check
    Object roleObj = session.getAttribute("role");
    if (roleObj == null || !"Supplier".equalsIgnoreCase(roleObj.toString())) {
        response.sendRedirect("../login.jsp");
        return;
    }

    int mySupplierId = (int) session.getAttribute("supplier_id");
    InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");

    // ၂။ Data Fetching
    List<String[]> stocks = service.getSupplierInventoryMonitor(mySupplierId);

    // ၃။ Metrics Aggregation
    int totalSkus = stocks.size();
    int lowStockCount = 0;
    for(String[] item : stocks) {
        try {
            int qty = Integer.parseInt(item[1]);
            int threshold = Integer.parseInt(item[3]);
            if(qty < threshold) lowStockCount++;
        } catch(Exception e) {}
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Inventory Desk | SupplyNode</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <style>
        body { background-color: #F8FAFC; color: #1E293B; }
        .main-content { margin-left: 320px; transition: all 0.4s ease; }
        @media (max-width: 1024px) { .main-content { margin-left: 0; } }

        .executive-card { background: white; border: 1px solid rgba(16, 185, 129, 0.1); transition: all 0.4s ease; }
        .executive-card:hover { border-color: #10b981; box-shadow: 0 25px 50px -12px rgba(16, 185, 129, 0.12); }

        .animate-reveal { animation: reveal 0.7s cubic-bezier(0.4, 0, 0.2, 1) forwards; opacity: 0; }
        @keyframes reveal { from { opacity: 0; transform: translateY(25px); } to { opacity: 1; transform: translateY(0); } }

        .status-pill { padding: 4px 12px; border-radius: 8px; font-size: 8px; font-weight: 900; text-transform: uppercase; letter-spacing: 0.1em; }
    </style>
</head>
<body class="font-sans antialiased">

<jsp:include page="/templates/supplier_sidebar.jsp" />

<main class="main-content min-h-screen p-6 lg:p-12 relative">
    <jsp:include page="/includes/header.jsp" />

    <%-- 1. Hero Header Section --%>
    <div class="mb-14 flex flex-col xl:flex-row justify-between items-start xl:items-end gap-8 animate-reveal">
        <div class="space-y-3">
            <h2 class="text-6xl font-black text-slate-900 tracking-tighter leading-none italic uppercase">
                Inventory <span class="text-emerald-500">Desk</span>
            </h2>
            <div class="flex items-center gap-4">
                <span class="w-12 h-1 bg-emerald-500 rounded-full"></span>
                <p class="text-slate-400 text-[10px] font-black uppercase tracking-[0.5em] italic leading-none">
                    Real-time Global Resource Monitoring
                </p>
            </div>
        </div>

        <div class="flex gap-4">
            <div class="bg-white px-8 py-5 rounded-[2.5rem] shadow-sm border border-slate-100 flex items-center gap-5">
                <div class="w-10 h-10 bg-slate-50 rounded-xl flex items-center justify-center text-slate-400">
                    <i class="fas fa-barcode"></i>
                </div>
                <div>
                    <span class="text-[8px] font-black text-slate-400 uppercase tracking-widest block mb-1">Total Assets</span>
                    <span class="text-2xl font-black text-slate-900 italic tracking-tighter leading-none"><%= totalSkus %> SKUs</span>
                </div>
            </div>
            <div class="bg-rose-50 px-8 py-5 rounded-[2.5rem] shadow-sm border border-rose-100 flex items-center gap-5">
                <div class="w-10 h-10 bg-rose-500 text-white rounded-xl flex items-center justify-center shadow-lg shadow-rose-200">
                    <i class="fas fa-triangle-exclamation"></i>
                </div>
                <div>
                    <span class="text-[8px] font-black text-rose-400 uppercase tracking-widest block mb-1">Critical Nodes</span>
                    <span class="text-2xl font-black text-rose-600 italic tracking-tighter leading-none"><%= lowStockCount %> Units</span>
                </div>
            </div>
        </div>
    </div>

    <%-- 2. Inventory Grid --%>
    <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-8 animate-reveal" style="animation-delay: 0.2s;">
        <% if(stocks.isEmpty()) { %>
        <div class="col-span-full py-32 text-center bg-white rounded-[4rem] border-2 border-dashed border-slate-100">
            <i class="fas fa-box-open text-6xl text-slate-100 mb-6 block"></i>
            <p class="text-[11px] font-black text-slate-300 uppercase tracking-[0.5em] italic">Zero Assets in Registry</p>
        </div>
        <% } else {
            for(String[] s : stocks) {
                int qty = Integer.parseInt(s[1]);
                int threshold = Integer.parseInt(s[3]);
                boolean isLow = (qty < threshold);
                boolean isOut = (qty <= 0);
        %>
        <div class="executive-card p-10 rounded-[3.5rem] relative overflow-hidden group">
            <%-- Status Badge --%>
            <div class="flex justify-between items-start mb-10">
                <div class="w-14 h-14 bg-slate-50 rounded-2xl flex items-center justify-center text-slate-400 group-hover:bg-emerald-500 group-hover:text-white transition-all duration-500 border border-slate-100">
                    <i class="fas fa-cubes-stacked text-xl"></i>
                </div>
                <div class="flex flex-col items-end gap-2">
                    <% if(isOut) { %>
                    <span class="status-pill bg-rose-500 text-white shadow-lg shadow-rose-200">Depleted</span>
                    <% } else if(isLow) { %>
                    <span class="status-pill bg-amber-100 text-amber-600 border border-amber-200 animate-pulse">Critical Level</span>
                    <% } else { %>
                    <span class="status-pill bg-emerald-50 text-emerald-600 border border-emerald-100">Optimal Sync</span>
                    <% } %>
                </div>
            </div>

            <%-- Asset Title --%>
            <div class="mb-10">
                <h3 class="text-2xl font-black text-slate-900 uppercase italic tracking-tighter leading-tight truncate group-hover:text-emerald-600 transition-colors">
                    <%= s[0] %>
                </h3>
                <div class="flex items-center gap-2 mt-3 text-slate-400">
                    <i class="fas fa-warehouse text-[10px]"></i>
                    <span class="text-[9px] font-bold uppercase tracking-widest italic leading-none"><%= s[2] %></span>
                </div>
            </div>

            <%-- Metrics --%>
            <div class="flex justify-between items-end pt-8 border-t border-slate-50">
                <div>
                    <span class="text-[8px] font-black text-slate-300 uppercase tracking-widest block mb-2 italic leading-none">Safety Threshold</span>
                    <span class="px-3 py-1 bg-slate-50 rounded-lg text-xs font-black text-slate-500 italic"><%= s[3] %> <span class="text-[8px] not-italic">units</span></span>
                </div>
                <div class="text-right">
                    <span class="text-5xl font-black tracking-tighter italic leading-none <%= isLow ? "text-rose-600" : "text-slate-900" %>">
                        <%= qty %>
                    </span>
                    <span class="block text-[8px] font-black text-slate-300 uppercase tracking-widest mt-2 italic">Available In Node</span>
                </div>
            </div>
        </div>
        <% } } %>
    </div>

    <%-- 3. Fulfillment CTA --%>
    <div class="mt-16 p-12 bg-slate-950 rounded-[4rem] shadow-2xl relative overflow-hidden animate-reveal group" style="animation-delay: 0.4s;">
        <div class="relative z-10 flex flex-col lg:flex-row justify-between items-center gap-10">
            <div class="space-y-4 text-center lg:text-left">
                <div class="flex items-center justify-center lg:justify-start gap-3">
                    <span class="w-10 h-1 bg-emerald-500 rounded-full"></span>
                    <h4 class="text-emerald-500 font-black text-[10px] uppercase tracking-[0.5em] italic">Strategic Protocol</h4>
                </div>
                <h3 class="text-white text-3xl font-black italic uppercase tracking-tighter leading-tight">Authorize Node <br>Replenishment?</h3>
                <p class="text-slate-500 text-xs font-medium italic">Synchronize with incoming supply requests to maintain terminal integrity.</p>
            </div>

            <a href="supplier_orders.jsp" class="bg-emerald-500 text-slate-950 px-12 py-6 rounded-[2rem] font-black text-[10px] uppercase tracking-[0.4em] hover:bg-white transition-all shadow-xl shadow-emerald-500/20 active:scale-95 flex items-center gap-4 group/btn">
                <span>Access Supply Ledger</span>
                <i class="fas fa-arrow-right-long group-hover/btn:translate-x-2 transition-transform"></i>
            </a>
        </div>
        <%-- Background Decorative Icon --%>
        <i class="fas fa-shield-halved absolute -right-10 -bottom-10 text-[15rem] text-white/5 -rotate-12 group-hover:rotate-0 transition-transform duration-700"></i>
    </div>

    <jsp:include page="/includes/footer.jsp" />
</main>



</body>
</html>