<%@ page import="java.rmi.Naming, common.InventoryService, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // ၁။ Security & Session Check
    Object roleObj = session.getAttribute("role");
    if (roleObj == null || !"STOREKEEPER".equalsIgnoreCase(roleObj.toString())) {
        response.sendRedirect("../login.jsp");
        return;
    }

    int myBranch = Integer.parseInt(session.getAttribute("branch_id").toString());
    InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");

    // ၂။ Critical Items ဆွဲယူခြင်း
    List<String[]> criticalItems = service.getLowStockAlerts(myBranch, 100);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Safety Protocol | OMNI FLOW</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <style>
        body { background-color: #F8FAFC; color: #1E293B; }
        /* Layout Space ညှိခြင်း */
        .main-content { margin-left: 280px; padding-top: 90px; transition: all 0.4s ease; }
        @media (max-width: 1024px) { .main-content { margin-left: 0; } }

        .executive-card { background: white; border: 1px solid rgba(244, 63, 94, 0.1); transition: all 0.3s ease; }
        .executive-card:hover { border-color: #f43f5e; box-shadow: 0 25px 50px -12px rgba(244, 63, 94, 0.15); }

        .animate-reveal { animation: reveal 0.7s cubic-bezier(0.4, 0, 0.2, 1) forwards; opacity: 0; }
        @keyframes reveal { from { opacity: 0; transform: translateY(25px); } to { opacity: 1; transform: translateY(0); } }

        @media print { .no-print { display: none !important; } .main-content { margin-left: 0 !important; padding-top: 20px !important; } }
    </style>
</head>
<body class="font-sans antialiased selection:bg-rose-100 selection:text-rose-600">

<jsp:include page="/templates/sidebar_storekeeper.jsp" />

<main class="main-content min-h-screen p-6 lg:p-12 relative flex flex-col">
    <div class="no-print"><jsp:include page="/includes/header.jsp" /></div>

    <%-- 1. Hero Header Section --%>
    <div class="mb-14 flex flex-col xl:flex-row justify-between items-start xl:items-end gap-8 animate-reveal no-print">
        <div class="space-y-3">
            <h2 class="text-6xl font-black text-slate-900 tracking-tighter leading-none italic uppercase">
                Safety <span class="text-rose-600">Protocol</span>
            </h2>
            <div class="flex items-center gap-4">
                <span class="w-12 h-1 bg-rose-600 rounded-full"></span>
                <p class="text-slate-400 text-[10px] font-black uppercase tracking-[0.5em] italic leading-none">
                    Node Vulnerability Surveillance
                </p>
            </div>
        </div>

        <div class="flex gap-4">
            <div class="bg-white px-8 py-5 rounded-[2.5rem] shadow-sm border border-slate-100 flex items-center gap-5">
                <span class="relative flex h-4 w-4">
                  <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-rose-400 opacity-75"></span>
                  <span class="relative inline-flex rounded-full h-4 w-4 bg-rose-600"></span>
                </span>
                <span class="text-[10px] font-black text-slate-400 uppercase tracking-widest italic">Live Scanning</span>
            </div>
            <button onclick="window.print()" class="bg-slate-900 text-white px-8 py-5 rounded-[2.5rem] font-black text-[10px] uppercase tracking-widest hover:bg-rose-600 transition shadow-xl active:scale-95 flex items-center gap-3">
                <i class="fas fa-file-pdf text-rose-400"></i> Export Breach Log
            </button>
        </div>
    </div>

    <%-- 2. Status Analysis Hub --%>
    <div class="grid grid-cols-1 xl:grid-cols-4 gap-8 mb-12 animate-reveal" style="animation-delay: 0.1s;">
        <div class="bg-slate-950 p-10 rounded-[3.5rem] shadow-2xl relative overflow-hidden group border border-rose-900/20">
            <div class="relative z-10">
                <span class="text-[9px] font-black text-rose-500 uppercase tracking-[0.4em] italic block mb-3">Breach Frequency</span>
                <p class="text-6xl font-black text-white italic tracking-tighter leading-none"><%= criticalItems.size() %></p>
                <div class="mt-6 px-4 py-1 bg-rose-600 text-white rounded-full inline-block text-[8px] font-black uppercase tracking-widest animate-pulse">
                    Action Critical
                </div>
            </div>
            <i class="fas fa-biohazard absolute -right-6 -bottom-6 text-[10rem] text-white/5 -rotate-12 group-hover:rotate-0 transition-transform duration-700"></i>
        </div>

        <div class="xl:col-span-3 bg-white p-10 rounded-[3.5rem] shadow-sm border border-slate-100 flex flex-col md:flex-row items-center gap-10">
            <div class="w-24 h-24 <%= !criticalItems.isEmpty() ? "bg-rose-50 text-rose-500 shadow-rose-100" : "bg-emerald-50 text-emerald-500 shadow-emerald-100" %> rounded-[2.5rem] flex items-center justify-center text-4xl shadow-inner transition-all duration-700">
                <i class="fas <%= !criticalItems.isEmpty() ? "fa-shield-virus" : "fa-shield-check" %>"></i>
            </div>
            <div>
                <h4 class="text-slate-900 font-black text-3xl italic uppercase tracking-tighter leading-none mb-3">
                    System Integrity: <%= !criticalItems.isEmpty() ? "<span class='text-rose-600'>Compromised</span>" : "<span class='text-emerald-500'>Optimized</span>" %>
                </h4>
                <p class="text-[11px] text-slate-400 font-bold uppercase tracking-[0.2em] leading-relaxed italic">
                    Node is currently evaluating local repository metadata. <br>
                    <span class="text-indigo-500">Sync Target: Minimum Safety Threshold (RMI Node Protocol)</span>
                </p>
            </div>
        </div>
    </div>

    <%-- 3. Inventory Breach Ledger --%>
    <div class="executive-card rounded-[4rem] overflow-hidden animate-reveal shadow-sm" style="animation-delay: 0.2s;">
        <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse">
                <thead class="bg-slate-50 text-[10px] font-black uppercase text-slate-400 tracking-[0.25em] border-b border-slate-100">
                <tr>
                    <th class="p-10">Source Asset Node</th>
                    <th class="p-10 text-center">Batch Vol</th>
                    <th class="p-10 text-center">Safety Limit</th>
                    <th class="p-10 text-right">Synchronization</th>
                </tr>
                </thead>
                <tbody class="divide-y divide-slate-50">
                <% if(criticalItems.isEmpty()) { %>
                <tr>
                    <td colspan="4" class="p-40 text-center">
                        <div class="flex flex-col items-center opacity-20">
                            <i class="fas fa-check-double text-6xl mb-6"></i>
                            <p class="font-black italic uppercase tracking-[0.5em] text-[10px]">Registry is operational and balanced</p>
                        </div>
                    </td>
                </tr>
                <% } else {
                    for(String[] item : criticalItems) {
                        int qty = Integer.parseInt(item[2]);
                        int limit = item.length > 3 ? Integer.parseInt(item[3]) : 0;
                %>
                <tr class="hover:bg-rose-50/40 transition-all duration-500 group">
                    <td class="p-10">
                        <div class="flex items-center gap-8">
                            <div class="w-16 h-16 bg-rose-50 text-rose-500 rounded-[2rem] flex items-center justify-center text-xl shadow-inner group-hover:bg-rose-600 group-hover:text-white transition-all duration-500">
                                <i class="fas fa-radiation"></i>
                            </div>
                            <div>
                                <span class="font-black text-slate-800 block text-2xl italic uppercase tracking-tighter leading-none mb-2 group-hover:text-rose-600 transition-colors"><%= item[1] %></span>
                                <span class="text-[9px] font-black text-rose-400 uppercase tracking-widest italic opacity-60">Handshake ID: #VIOL-0<%= item[0] %></span>
                            </div>
                        </div>
                    </td>
                    <td class="p-10 text-center">
                        <span class="text-5xl font-black text-rose-600 italic tracking-tighter leading-none"><%= qty %></span>
                        <span class="text-[8px] font-black text-slate-300 block uppercase mt-2 tracking-widest italic">Node Remainder</span>
                    </td>
                    <td class="p-10 text-center">
                        <div class="inline-block px-6 py-2 bg-slate-50 rounded-2xl border border-slate-100">
                            <span class="font-black text-slate-400 italic text-2xl tracking-tighter"><%= limit %></span>
                            <span class="text-[8px] font-black text-slate-300 block uppercase tracking-tighter mt-1 italic">Protocol Limit</span>
                        </div>
                    </td>
                    <td class="p-10 text-right">
                        <a href="my_inventory.jsp" class="bg-slate-950 text-white px-10 py-6 rounded-[2.5rem] text-[10px] font-black uppercase tracking-[0.3em] hover:bg-rose-600 transition-all shadow-2xl active:scale-95 group-hover:-translate-x-4 flex items-center justify-end gap-3 inline-flex">
                            Resolve Breach <i class="fas fa-arrow-right-long opacity-50"></i>
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