<%@ page import="java.rmi.Naming, common.InventoryService, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // ၁။ Security Check
    if (session.getAttribute("user_id") == null || !"Manager".equals(session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp"); return;
    }
    request.setAttribute("active_page", "manager_inventory.jsp");

    int branchId = (int) session.getAttribute("branch_id");
    String branchName = (session.getAttribute("branch_name") != null) ? (String) session.getAttribute("branch_name") : "Local Node";

    InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");
    List<String[]> items = service.getBranchInventory(branchId);

    // ⭐ ၂။ စုစုပေါင်းတန်ဖိုး တွက်ချက်ခြင်း
    long totalValue = 0;
    if (items != null) {
        for(String[] item : items) {
            try {
                double val = Double.parseDouble(item[3]);
                totalValue += (long) val;
            } catch (Exception e) { }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Local Repository | OMNI FLOW</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <style>
        body { background-color: #F8FAFC; color: #1E293B; }
        .main-content { margin-left: 320px; transition: all 0.4s ease; }
        @media (max-width: 1024px) { .main-content { margin-left: 0; } }
        @media print { .no-print { display: none !important; } .main-content { margin-left: 0 !important; } }

        .executive-card { background: white; border: 1px solid rgba(99, 102, 241, 0.1); transition: all 0.3s ease; }
        .executive-card:hover { border-color: #6366f1; box-shadow: 0 25px 50px -12px rgba(99, 102, 241, 0.12); }

        .animate-reveal { animation: reveal 0.7s cubic-bezier(0.4, 0, 0.2, 1) forwards; opacity: 0; }
        @keyframes reveal { from { opacity: 0; transform: translateY(25px); } to { opacity: 1; transform: translateY(0); } }

        .progress-bar { transition: width 1s ease-in-out; }
    </style>
</head>
<body class="font-sans antialiased">

<jsp:include page="/templates/sidebar_manager.jsp" />

<main class="main-content min-h-screen p-6 lg:p-12 relative">
    <div class="no-print"><jsp:include page="/includes/header.jsp" /></div>

    <%-- 1. Hero Header & Quick Stats --%>
    <div class="mb-14 flex flex-col xl:flex-row justify-between items-start xl:items-center gap-8 animate-reveal">
        <div class="space-y-3">
            <h2 class="text-6xl font-black text-slate-900 tracking-tighter leading-none italic uppercase">
                Local <span class="text-indigo-600">Repository</span>
            </h2>
            <div class="flex items-center gap-4">
                <span class="w-12 h-1 bg-indigo-500 rounded-full"></span>
                <p class="text-slate-400 text-[9px] font-black uppercase tracking-[0.5em] italic">
                    Node Origin: <%= branchName %>
                </p>
            </div>
        </div>

        <div class="flex flex-wrap gap-4 no-print">
            <%-- Valuation Badge --%>
            <div class="bg-white px-8 py-5 rounded-[2.5rem] shadow-sm border border-slate-100 flex items-center gap-5">
                <div class="w-12 h-12 bg-emerald-50 rounded-2xl flex items-center justify-center text-emerald-500">
                    <i class="fas fa-coins text-xl"></i>
                </div>
                <div>
                    <span class="text-[8px] font-black text-slate-400 uppercase tracking-widest block mb-1">Asset Valuation</span>
                    <span class="text-2xl font-black text-[#2E5077] italic tracking-tighter">
                        <%= String.format("%, d", totalValue) %> <span class="text-[10px] not-italic text-slate-400">MMK</span>
                    </span>
                </div>
            </div>
            <%-- Print Button --%>
            <button onclick="window.print()" class="bg-[#2E5077] text-white px-8 py-5 rounded-[2.5rem] font-black text-[10px] uppercase tracking-widest hover:bg-slate-900 transition-all shadow-xl active:scale-95 flex items-center gap-3">
                <i class="fas fa-print text-[#79D7BE]"></i> Print Manifest
            </button>
        </div>
    </div>

    <%-- 2. Asset Ledger Table --%>
    <div class="executive-card rounded-[4rem] overflow-hidden animate-reveal shadow-sm" style="animation-delay: 0.2s;">
        <div class="p-10 border-b border-slate-50 flex justify-between items-center bg-slate-50/40">
            <div>
                <h3 class="text-2xl font-black italic uppercase text-slate-800 tracking-tighter leading-none">Intelligence Ledger</h3>
                <p class="text-[9px] font-black text-slate-400 uppercase tracking-widest mt-2">Verified Stock Counts & Liquidity Status</p>
            </div>
            <div class="relative no-print">
                <i class="fas fa-magnifying-glass absolute left-5 top-1/2 -translate-y-1/2 text-slate-300 text-sm"></i>
                <input type="text" id="inventorySearch" placeholder="Trace SKU Identifier..."
                       class="pl-12 pr-6 py-4 bg-white border border-slate-200 rounded-2xl outline-none focus:ring-4 focus:ring-indigo-500/10 font-bold text-xs w-72 transition-all">
            </div>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-left" id="inventoryTable">
                <thead class="bg-slate-50 text-[10px] font-black uppercase text-slate-400 tracking-[0.25em] border-b border-slate-100">
                <tr>
                    <th class="p-10">Resource Identity</th>
                    <th class="p-10">Unit Valuation</th>
                    <th class="p-10 text-center">Node Availability</th>
                    <th class="p-10 text-right">Net Liquidity</th>
                </tr>
                </thead>
                <tbody class="divide-y divide-slate-50">
                <% if(items == null || items.isEmpty()) { %>
                <tr><td colspan="4" class="p-32 text-center text-slate-300 font-black italic uppercase tracking-[0.4em] text-[10px]">No local resource traces in this node memory</td></tr>
                <% } else {
                    for(String[] item : items) {
                        double unitPrice = Double.parseDouble(item[1]);
                        int qty = Integer.parseInt(item[2]);
                        double assetValue = Double.parseDouble(item[3]);

                        int threshold = 10;
                        boolean isLow = qty < threshold;
                        int percent = Math.min((qty * 100) / 50, 100); // 50 units ကို 100% သတ်မှတ်ခြင်း
                %>
                <tr class="hover:bg-indigo-50/40 transition-all duration-500 group">
                    <td class="p-10">
                        <div class="flex items-center gap-6">
                            <div class="w-16 h-16 bg-slate-50 rounded-[2rem] flex items-center justify-center text-2xl text-slate-400 group-hover:bg-indigo-600 group-hover:text-white transition-all duration-500 shadow-inner">
                                <i class="fas fa-box-open"></i>
                            </div>
                            <div>
                                <span class="font-black text-slate-800 block text-xl italic uppercase tracking-tighter leading-none mb-2"><%= item[0] %></span>
                                <div class="flex items-center gap-2">
                                    <span class="w-2 h-2 rounded-full <%= isLow ? "bg-rose-500 animate-pulse" : "bg-emerald-500" %>"></span>
                                    <span class="text-[9px] font-black uppercase tracking-widest italic <%= isLow ? "text-rose-500" : "text-slate-400" %>">
                                        <%= isLow ? "Critical Threshold" : "Operations Sync" %>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </td>
                    <td class="p-10">
                        <div class="flex flex-col">
                            <span class="text-base font-black text-slate-700 tracking-tighter italic"><%= String.format("%, .0f", unitPrice) %></span>
                            <span class="text-[9px] font-black text-slate-300 uppercase tracking-widest mt-1">MMK / UNIT</span>
                        </div>
                    </td>
                    <td class="p-10">
                        <div class="flex flex-col items-center gap-3">
                            <span class="text-3xl font-black italic tracking-tighter <%= isLow ? "text-rose-600" : "text-slate-900" %> leading-none"><%= qty %></span>
                            <div class="w-28 h-2 bg-slate-100 rounded-full overflow-hidden p-[2px] shadow-inner">
                                <div class="h-full rounded-full progress-bar <%= isLow ? "bg-rose-500" : "bg-indigo-600" %>"
                                     style="width: <%= percent %>%"></div>
                            </div>
                        </div>
                    </td>
                    <td class="p-10 text-right">
                        <div class="flex flex-col items-end">
                            <span class="font-black text-slate-900 text-2xl italic tracking-tighter leading-none mb-1">
                                <%= String.format("%, .0f", assetValue) %>
                            </span>
                            <span class="text-[9px] font-black text-emerald-500 uppercase tracking-widest">Aggregate MMK</span>
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

<script>
    // Real-time Search Logic
    document.getElementById('inventorySearch').addEventListener('keyup', function() {
        let filter = this.value.toUpperCase();
        let rows = document.querySelectorAll("#inventoryTable tbody tr");
        rows.forEach(row => {
            if (row.cells.length > 1) {
                let text = row.cells[0].textContent.toUpperCase();
                row.style.display = text.includes(filter) ? "" : "none";
            }
        });
    });
</script>
</body>
</html>