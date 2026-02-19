<%@ page import="java.rmi.Naming, common.InventoryService, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session.getAttribute("user_id") == null || !session.getAttribute("role").equals("Admin")) {
        response.sendRedirect("../login.jsp");
        return;
    }
    request.setAttribute("active_page", "procurement");

    InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");
    String catFilter = request.getParameter("category") != null ? request.getParameter("category") : "ALL";

    List<String[]> reportData = service.getProcurementReport(catFilter);
    List<String> categories = service.getCategories();

    long grandTotal = 0;
    if (reportData != null) {
        for(String[] row : reportData) {
            try {
                double val = Double.parseDouble(row[5]);
                grandTotal += (long) val;
            } catch (Exception e) { continue; }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Procurement Analytics | OMNI CORE</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body { background-color: #F6F4F0; scroll-behavior: smooth; }
        .main-content { margin-left: 290px; transition: all 0.4s ease; }
        @media (max-width: 1024px) { .main-content { margin-left: 0; } }

        .glass-card { background: rgba(255, 255, 255, 0.7); backdrop-filter: blur(12px); border: 1px solid rgba(77, 161, 169, 0.15); }
        .stat-card-blue { background-color: #2E5077; color: white; transition: transform 0.3s ease; }
        .stat-card-blue:hover { transform: translateY(-5px); }

        .category-pill { transition: all 0.3s ease; }
        .category-pill.active { background-color: #79D7BE; color: #2E5077; box-shadow: 0 10px 15px -3px rgba(121, 215, 190, 0.3); }

        .custom-scrollbar::-webkit-scrollbar { height: 6px; }
        .custom-scrollbar::-webkit-scrollbar-thumb { background: #4DA1A9; border-radius: 10px; }

        @media print {
            .no-print { display: none !important; }
            .main-content { margin: 0 !important; padding: 0 !important; width: 100%; }
            .report-card { border: 1px solid #ddd; box-shadow: none; border-radius: 0; }
        }
    </style>
</head>
<body class="font-sans text-[#2E5077] antialiased">

<jsp:include page="/templates/sidebar_admin.jsp" />

<main class="main-content min-h-screen p-6 lg:p-10 relative">
    <jsp:include page="/includes/header.jsp" />

    <%-- Page Header --%>
    <div class="flex flex-col md:flex-row justify-between items-start md:items-end my-10 gap-6 no-print px-4">
        <div>
           <div class="flex items-center gap-3 mt-3">
                <span class="w-12 h-1 bg-[#79D7BE] rounded-full"></span>
                <p class="text-[#4DA1A9] text-[10px] font-bold uppercase tracking-[0.3em]">Capital Valuation & Hub</p>
            </div>
        </div>
        <button onclick="window.print()" class="bg-[#2E5077] text-white px-8 py-4 rounded-2xl font-bold shadow-xl hover:bg-[#4DA1A9] transition-all text-[10px] uppercase tracking-widest flex items-center gap-3">
            <i class="fas fa-file-invoice text-[#79D7BE]"></i> Export Intelligence Report
        </button>
    </div>

    <%-- Summary Widgets --%>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10 no-print px-4">
        <div class="stat-card-blue p-8 rounded-[2.5rem] shadow-xl relative overflow-hidden">
            <i class="fas fa-vault absolute -right-4 -bottom-4 text-7xl opacity-10"></i>
            <span class="text-[9px] font-black text-[#79D7BE] uppercase tracking-widest">Net Capital Investment</span>
            <h4 class="text-3xl font-black mt-2 italic tracking-tighter">
                <%= String.format("%, d", grandTotal) %> <span class="text-xs font-bold text-[#4DA1A9] not-italic">MMK</span>
            </h4>
        </div>
        <div class="glass-card p-8 rounded-[2.5rem] shadow-sm flex flex-col justify-center border-l-4 border-[#79D7BE]">
            <span class="text-[9px] font-black text-slate-400 uppercase tracking-widest">Live Asset Nodes</span>
            <h4 class="text-4xl font-black text-[#2E5077] mt-2 italic tracking-tighter">
                <%= (reportData != null) ? reportData.size() : 0 %> <span class="text-xs font-bold text-slate-300 not-italic">ENTITIES</span>
            </h4>
        </div>
        <div class="glass-card p-8 rounded-[2.5rem] shadow-sm flex flex-col justify-center border-l-4 border-[#4DA1A9]">
            <span class="text-[9px] font-black text-slate-400 uppercase tracking-widest">Domain Coverage</span>
            <h4 class="text-4xl font-black text-[#4DA1A9] mt-2 italic tracking-tighter">
                <%= (categories != null) ? categories.size() : 0 %> <span class="text-xs font-bold text-slate-300 not-italic">SECTORS</span>
            </h4>
        </div>
    </div>

    <%-- Category & Search Filter Bar --%>
    <div class="mb-8 px-4 no-print">
        <div class="glass-card p-6 rounded-[2.5rem] shadow-sm flex flex-wrap gap-4 items-center">
            <form action="procurement.jsp" method="GET" id="filterForm" class="flex flex-wrap gap-4 flex-1">

                <div class="relative flex-1 min-w-[280px]">
                    <label class="block text-[9px] font-black text-[#4DA1A9] uppercase tracking-widest mb-2 ml-2">Filter by Sector</label>
                    <div class="relative">
                        <i class="fas fa-layer-group absolute left-5 top-1/2 -translate-y-1/2 text-[#4DA1A9]"></i>
                        <select name="category" onchange="document.getElementById('filterForm').submit()"
                                class="w-full pl-12 pr-10 py-4 bg-[#F6F4F0] border-none rounded-2xl outline-none focus:ring-2 focus:ring-[#79D7BE] font-bold text-sm text-[#2E5077] appearance-none cursor-pointer shadow-inner">
                            <option value="ALL" <%= catFilter.equals("ALL") ? "selected" : "" %>>All Domains (Comprehensive)</option>
                            <% if(categories != null) { for(String cat : categories) { %>
                            <option value="<%= cat %>" <%= catFilter.equals(cat) ? "selected" : "" %>><%= cat %></option>
                            <% } } %>
                        </select>
                        <i class="fas fa-chevron-down absolute right-5 top-1/2 -translate-y-1/2 text-[#4DA1A9] pointer-events-none"></i>
                    </div>
                </div>

                <div class="hidden xl:flex flex-col justify-center border-l border-[#4DA1A9]/20 pl-6 ml-2">
                    <span class="text-[8px] font-black text-slate-400 uppercase tracking-widest leading-none mb-1">Active Status</span>
                    <div class="flex items-center gap-2">
                        <span class="w-1.5 h-1.5 bg-[#79D7BE] rounded-full animate-pulse"></span>
                        <span class="text-[10px] font-bold text-[#2E5077] uppercase italic"><%= catFilter %> SEGMENT SYNCED</span>
                    </div>
                </div>

            </form>
        </div>
    </div>

    <%-- Data Table Section --%>
    <div class="bg-white rounded-[3rem] shadow-xl shadow-slate-200/50 overflow-hidden border border-[#4DA1A9]/10 mx-4 report-card">
        <table class="w-full text-left">
            <thead>
            <tr class="bg-[#F6F4F0] border-b border-[#4DA1A9]/10">
                <th class="px-10 py-6 text-[9px] font-black uppercase text-[#4DA1A9] tracking-widest">Supplier Identity</th>
                <th class="px-10 py-6 text-[9px] font-black uppercase text-[#4DA1A9] tracking-widest">Asset Parameters</th>
                <th class="px-10 py-6 text-[9px] font-black uppercase text-[#4DA1A9] tracking-widest text-center">Batch Qty</th>
                <th class="px-10 py-6 text-[9px] font-black uppercase text-[#4DA1A9] tracking-widest">Deployment Node</th>
                <th class="px-10 py-6 text-[9px] font-black uppercase text-[#4DA1A9] tracking-widest text-right">Net Valuation</th>
            </tr>
            </thead>
            <tbody class="divide-y divide-[#F6F4F0]">
            <% if (reportData != null) {
                for(String[] row : reportData) {
                    int qty = Integer.parseInt(row[2]);
                    int threshold = (row[8] != null) ? Integer.parseInt(row[8]) : 5;
                    boolean isLow = qty <= threshold;
            %>
            <tr class="hover:bg-[#F6F4F0]/50 transition-all group">
                <td class="px-10 py-8">
                    <span class="font-black text-[#2E5077] uppercase block tracking-tighter leading-none"><%= row[6] %></span>
                    <span class="text-[8px] text-[#79D7BE] font-bold uppercase tracking-widest mt-2 block italic">Verified Vendor Node</span>
                </td>
                <td class="px-10 py-8">
                    <span class="font-bold text-[#2E5077] block text-base uppercase italic leading-tight group-hover:text-[#4DA1A9] transition-colors"><%= row[1] %></span>
                    <div class="flex items-center gap-3 mt-2">
                        <span class="text-[8px] bg-[#F6F4F0] px-2 py-0.5 rounded-md font-bold text-slate-400 uppercase tracking-widest border border-[#4DA1A9]/10"><%= row[4] %></span>
                        <span class="text-[8px] text-slate-300 font-bold uppercase italic tracking-tighter">Unit: <%= String.format("%, .0f", Double.parseDouble(row[3])) %></span>
                    </div>
                </td>
                <td class="px-10 py-8 text-center">
                    <span class="font-black <%= isLow ? "text-rose-500 animate-pulse" : "text-[#2E5077]" %> text-3xl italic tracking-tighter"><%= qty %></span>
                    <span class="block text-[8px] font-bold uppercase mt-1 <%= isLow ? "text-rose-300" : "text-slate-300" %>">
                        <%= isLow ? "CRITICAL ALERT" : "STABLE STOCK" %>
                    </span>
                </td>
                <td class="px-10 py-8">
                    <div class="flex items-center gap-2">
                        <i class="fas fa-location-crosshairs text-[#79D7BE] text-[10px]"></i>
                        <span class="font-bold text-slate-500 text-[11px] uppercase italic tracking-tight"><%= row[7] %></span>
                    </div>
                </td>
                <td class="px-10 py-8 text-right">
                    <span class="font-black text-[#2E5077] text-2xl italic tracking-tighter block">
                        <%= String.format("%, .0f", Double.parseDouble(row[5])) %>
                    </span>
                    <span class="text-[8px] text-slate-300 font-bold uppercase tracking-[0.2em] mt-1 block">MMK Consistently</span>
                </td>
            </tr>
            <% } } %>
            </tbody>
            <tfoot class="bg-[#2E5077] text-white">
            <tr>
                <td colspan="4" class="px-10 py-10 text-right font-black uppercase tracking-[0.3em] italic text-xs text-white/50">Total Assets Under Management</td>
                <td class="px-10 py-10 text-right">
                    <span class="text-[#79D7BE] font-black text-4xl italic tracking-tighter block leading-none">
                        <%= String.format("%, d", grandTotal) %>
                    </span>
                    <span class="text-[9px] font-black uppercase tracking-[0.4em] text-[#4DA1A9] mt-2 block leading-none">MMK Treasury Valuation</span>
                </td>
            </tr>
            </tfoot>
        </table>
    </div>

    <div class="mt-8 text-center no-print pb-10">
        <p class="text-slate-400 text-[9px] font-bold uppercase tracking-[0.4em] italic opacity-60">
            * OMNI CORE ERP INTERNAL ANALYTICS | REPORT GENERATED ON NODE <%= java.time.LocalDateTime.now() %>
        </p>
    </div>

    <jsp:include page="/includes/footer.jsp" />
</main>
</body>
</html>