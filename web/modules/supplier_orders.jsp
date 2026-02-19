<%@ page import="java.rmi.Naming, common.InventoryService, java.util.*, java.text.SimpleDateFormat" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // ၁။ Security Check
    Object roleObj = session.getAttribute("role");
    if (roleObj == null || !"Supplier".equalsIgnoreCase(roleObj.toString())) {
        response.sendRedirect("../login.jsp");
        return;
    }

    int mySupplierId = (int) session.getAttribute("supplier_id");
    InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");

    // ၂။ Logic Handlers (Delete & Update)
    String delId = request.getParameter("delete_id");
    if (delId != null && !delId.isEmpty()) {
        service.deleteStockRequest(Integer.parseInt(delId), -1);
        response.sendRedirect("supplier_orders.jsp?msg=deleted"); return;
    }

    String updateId = request.getParameter("update_id");
    String newStatus = request.getParameter("status");
    if (updateId != null && newStatus != null) {
        service.updateStockRequestStatus(Integer.parseInt(updateId), newStatus);
        response.sendRedirect("supplier_orders.jsp?msg=updated"); return;
    }

    // ၃။ Data Fetching
    List<String[]> orders = service.getStockRequestsBySupplier(mySupplierId, "ALL");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Fulfillment Ledger | SupplyNode</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        body { background-color: #F8FAFC; color: #1E293B; }
        .main-content { margin-left: 320px; transition: all 0.4s ease; }
        @media (max-width: 1024px) { .main-content { margin-left: 0; } }

        .executive-card { background: white; border: 1px solid rgba(16, 185, 129, 0.1); transition: all 0.3s ease; }
        .executive-card:hover { border-color: #10b981; box-shadow: 0 25px 50px -12px rgba(16, 185, 129, 0.12); }

        .animate-reveal { animation: reveal 0.7s cubic-bezier(0.4, 0, 0.2, 1) forwards; opacity: 0; }
        @keyframes reveal { from { opacity: 0; transform: translateY(25px); } to { opacity: 1; transform: translateY(0); } }

        @media print {
            .no-print { display: none !important; }
            .main-content { margin-left: 0 !important; padding: 0 !important; }
            .executive-card { border: 1px solid #eee !important; box-shadow: none !important; border-radius: 0 !important; }
            .print-only { display: block !important; }
        }
    </style>
</head>
<body class="font-sans antialiased">

<div class="no-print">
    <jsp:include page="/templates/supplier_sidebar.jsp" />
</div>

<main class="main-content min-h-screen p-6 lg:p-12 relative">
    <div class="no-print">
        <jsp:include page="/includes/header.jsp" />
    </div>

    <%-- Print Header --%>
    <div class="hidden print-only mb-10 border-b-4 border-emerald-500 pb-6">
        <h1 class="text-4xl font-black italic uppercase tracking-tighter">Supply<span class="text-emerald-500">Node</span> Ledger</h1>
        <p class="text-[10px] font-bold text-slate-500 uppercase tracking-[0.5em] mt-2">Verified Fulfillment Statement | Generated: <%= new java.util.Date() %></p>
    </div>

    <%-- 1. Hero Header Section --%>
    <div class="mb-14 flex flex-col xl:flex-row justify-between items-start xl:items-end gap-8 animate-reveal no-print">
        <div class="space-y-3">
            <h2 class="text-6xl font-black text-slate-900 tracking-tighter leading-none italic uppercase">
                Fulfillment <span class="text-emerald-500">Ledger</span>
            </h2>
            <div class="flex items-center gap-4">
                <span class="w-12 h-1 bg-emerald-500 rounded-full"></span>
                <p class="text-slate-400 text-[10px] font-black uppercase tracking-[0.5em] italic leading-none">
                    Strategic Supply Chain Record Desk
                </p>
            </div>
        </div>

        <div class="flex gap-4">
            <button onclick="window.print()" class="bg-white border border-slate-200 text-slate-900 px-8 py-5 rounded-[2.5rem] font-black shadow-sm hover:border-emerald-500 transition-all tracking-widest uppercase text-[10px] flex items-center gap-3">
                <i class="fas fa-file-pdf text-rose-500"></i> Export Statement
            </button>
        </div>
    </div>

    <%-- 2. Data Table Card --%>
    <div class="executive-card rounded-[4rem] overflow-hidden animate-reveal shadow-sm" style="animation-delay: 0.2s;">
        <div class="p-10 border-b border-slate-50 flex justify-between items-center bg-slate-50/40 no-print">
            <div>
                <h3 class="text-2xl font-black italic uppercase text-slate-800 tracking-tighter leading-none">Fulfillment Registry</h3>
                <p class="text-[9px] font-black text-slate-400 uppercase tracking-widest mt-2">End-to-end transaction tracking for partner nodes</p>
            </div>
            <div class="w-12 h-12 rounded-2xl bg-white border border-slate-100 flex items-center justify-center text-emerald-500 shadow-sm">
                <i class="fas fa-list-check text-sm"></i>
            </div>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-left">
                <thead class="bg-slate-50 text-[10px] font-black uppercase text-slate-400 tracking-[0.25em] border-b border-slate-100">
                <tr>
                    <th class="p-10">Timestamp</th>
                    <th class="p-10">Asset & Origin</th>
                    <th class="p-10 text-center">Batch Vol</th>
                    <th class="p-10 text-center">Protocol Status</th>
                    <th class="p-10 text-right no-print">Decision Hub</th>
                </tr>
                </thead>
                <tbody class="divide-y divide-slate-50">
                <% if(orders == null || orders.isEmpty()) { %>
                <tr>
                    <td colspan="5" class="p-32 text-center">
                        <div class="flex flex-col items-center opacity-20">
                            <i class="fas fa-inbox text-6xl mb-4"></i>
                            <p class="font-black italic uppercase tracking-[0.4em] text-[10px]">No transaction traces found</p>
                        </div>
                    </td>
                </tr>
                <% } else {
                    for(String[] o : orders) { %>
                <tr class="hover:bg-emerald-50/40 transition-all duration-500 group">
                    <td class="p-10">
                        <div class="flex flex-col">
                            <span class="font-black text-slate-800 text-sm block leading-none mb-1"><%= o[4].split(" ")[0] %></span>
                            <span class="text-[9px] text-emerald-500 font-black italic uppercase tracking-widest leading-none"><%= (o[4].contains(" ") ? o[4].split(" ")[1] : "") %></span>
                        </div>
                    </td>
                    <td class="p-10">
                        <div class="flex items-center gap-5">
                            <div class="w-12 h-12 bg-slate-100 rounded-2xl flex items-center justify-center text-slate-400 group-hover:bg-slate-900 group-hover:text-white transition-all duration-500">
                                <i class="fas fa-box-open"></i>
                            </div>
                            <div>
                                <span class="font-black text-slate-800 block text-xl italic uppercase tracking-tighter leading-none mb-2"><%= o[1] %></span>
                                <span class="text-[9px] font-bold text-slate-400 uppercase tracking-widest bg-slate-50 px-3 py-1 rounded-lg">Dest: Branch Node <%= o[4] %></span>
                            </div>
                        </div>
                    </td>
                    <td class="p-10 text-center">
                        <span class="text-3xl font-black text-slate-900 italic tracking-tighter"><%= o[2] %></span>
                        <span class="block text-[7px] font-black text-slate-300 uppercase mt-1 tracking-widest italic">Units</span>
                    </td>
                    <td class="p-10 text-center">
                        <span class="px-6 py-2.5 rounded-full font-black uppercase text-[9px] tracking-[0.2em] border
                            <%= "PENDING".equals(o[3]) ? "bg-amber-50 text-amber-500 border-amber-100" :
                               ("SHIPPED".equals(o[3]) ? "bg-emerald-50 text-emerald-600 border-emerald-100" : "bg-indigo-50 text-indigo-600 border-indigo-100") %>">
                            <%= o[3] %>
                        </span>
                    </td>
                    <td class="p-10 text-right space-x-2 no-print">
                        <div class="flex justify-end gap-3">
                            <% if("PENDING".equals(o[3])) { %>
                            <a href="supplier_orders.jsp?update_id=<%= o[0] %>&status=SHIPPED"
                               class="w-12 h-12 bg-slate-900 text-emerald-400 rounded-xl flex items-center justify-center hover:bg-emerald-500 hover:text-white transition-all shadow-xl shadow-slate-200 active:scale-90"
                               title="Dispatch Order">
                                <i class="fas fa-truck-fast"></i>
                            </a>
                            <% } %>

                            <button onclick="confirmDelete(<%= o[0] %>, '<%= o[1].replace("'", "\\'") %>')"
                                    class="w-12 h-12 bg-rose-50 text-rose-300 rounded-xl flex items-center justify-center hover:bg-rose-500 hover:text-white transition-all shadow-sm active:scale-90"
                                    title="Archive Record">
                                <i class="fas fa-trash-can"></i>
                            </button>
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
    function confirmDelete(id, name) {
        Swal.fire({
            title: '<span class="uppercase italic">Purge Log?</span>',
            text: `Authorize removal of trace for ${name}?`,
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#ef4444',
            confirmButtonText: 'DELETE TRACE',
            background: '#F8FAFC',
            customClass: { popup: 'rounded-[3rem] p-10' }
        }).then((result) => {
            if (result.isConfirmed) window.location.href = `supplier_orders.jsp?delete_id=${id}`;
        });
    }

    const params = new URLSearchParams(window.location.search);
    if(params.get('msg') === 'deleted') {
        Swal.fire({ icon: 'success', title: 'LOG REDACTED', text: 'Trace removed from node history.', confirmButtonColor: '#1E293B', customClass: { popup: 'rounded-[3rem]' } });
        window.history.replaceState({}, document.title, window.location.pathname);
    } else if(params.get('msg') === 'updated') {
        Swal.fire({ icon: 'success', title: 'NODE DISPATCHED', text: 'Fulfillment protocol updated.', confirmButtonColor: '#10b981', customClass: { popup: 'rounded-[3rem]' } });
        window.history.replaceState({}, document.title, window.location.pathname);
    }
</script>
</body>
</html>