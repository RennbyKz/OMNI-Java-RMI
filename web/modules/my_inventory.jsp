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

    boolean successFlag = false;
    String errorMsg = "";

    // ၂။ STOCK UPDATE LOGIC (POST Request)
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("update_stock") != null) {
        try {
            int pid = Integer.parseInt(request.getParameter("product_id"));
            int newQty = Integer.parseInt(request.getParameter("quantity"));
            String pname = request.getParameter("product_name");
            int userId = Integer.parseInt(session.getAttribute("user_id").toString());

            boolean updated = service.updateProductQuantity(pid, newQty, myBranch, userId, pname);
            if (updated) successFlag = true;
            else errorMsg = "Authorization Denied by Node";

        } catch (Exception e) {
            errorMsg = "Sync Failed: " + e.getMessage();
        }
    }

    // ၃။ Data Fetching
    List<String[]> items = service.getInventoryByBranch(myBranch);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Stock Repository | OMNI FLOW</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        body { background-color: #F8FAFC; color: #1E293B; }
        /* Sidebar နှင့် Header space အတွက် layout ညှိခြင်း */
        .main-content { margin-left: 280px; padding-top: 90px; transition: all 0.4s ease; }
        @media (max-width: 1024px) { .main-content { margin-left: 0; } }

        .executive-card { background: white; border: 1px solid rgba(99, 102, 241, 0.1); transition: all 0.3s ease; }
        .executive-card:hover { border-color: #6366f1; box-shadow: 0 25px 50px -12px rgba(99, 102, 241, 0.1); }

        .animate-reveal { animation: reveal 0.6s cubic-bezier(0.4, 0, 0.2, 1) forwards; opacity: 0; }
        @keyframes reveal { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }

        @media print { .no-print { display: none !important; } .main-content { margin-left: 0 !important; padding-top: 20px !important; } }
    </style>
</head>
<body class="font-sans antialiased selection:bg-indigo-100 selection:text-indigo-600">

<jsp:include page="/templates/sidebar_storekeeper.jsp" />

<main class="main-content min-h-screen p-6 lg:p-12 relative flex flex-col">
    <div class="no-print"><jsp:include page="/includes/header.jsp" /></div>

    <%-- 1. Hero Header Section --%>
    <div class="mb-14 flex flex-col xl:flex-row justify-between items-start xl:items-end gap-8 animate-reveal no-print">
        <div class="space-y-3">
            <h2 class="text-6xl font-black text-slate-900 tracking-tighter leading-none italic uppercase">
                Stock <span class="text-indigo-600">Repository</span>
            </h2>
            <div class="flex items-center gap-4">
                <span class="w-12 h-1 bg-indigo-500 rounded-full"></span>
                <p class="text-slate-400 text-[10px] font-black uppercase tracking-[0.4em] italic leading-none">
                    Local Asset Management Node
                </p>
            </div>
        </div>

        <div class="flex gap-4">
            <div class="relative">
                <i class="fas fa-magnifying-glass absolute left-5 top-1/2 -translate-y-1/2 text-slate-300 text-sm"></i>
                <input type="text" id="stockSearch" placeholder="Trace SKU Identifier..."
                       class="pl-12 pr-6 py-4 bg-white border border-slate-200 rounded-2xl outline-none focus:ring-4 focus:ring-indigo-500/10 font-bold text-xs w-72 transition-all">
            </div>
            <button onclick="window.print()" class="bg-slate-900 text-white px-8 py-5 rounded-[2.5rem] font-black text-[10px] uppercase tracking-widest hover:bg-indigo-600 transition shadow-xl active:scale-95 flex items-center gap-3">
                <i class="fas fa-print text-indigo-400"></i> Export Audit
            </button>
        </div>
    </div>

    <%-- 2. Inventory Ledger Table --%>
    <div class="executive-card rounded-[4rem] overflow-hidden animate-reveal shadow-sm" style="animation-delay: 0.1s;">
        <div class="p-10 border-b border-slate-50 flex justify-between items-center bg-slate-50/40 no-print">
            <div>
                <h3 class="text-2xl font-black italic uppercase text-slate-800 tracking-tighter leading-none">Asset Intelligence Ledger</h3>
                <p class="text-[9px] font-black text-slate-400 uppercase tracking-widest mt-2">Verified Node Handshakes & Volume Checks</p>
            </div>
            <div class="w-12 h-12 rounded-2xl bg-white border border-slate-100 flex items-center justify-center text-indigo-500 shadow-sm">
                <i class="fas fa-layer-group text-sm"></i>
            </div>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse" id="stockTable">
                <thead class="bg-slate-50 text-[10px] font-black uppercase text-slate-400 tracking-[0.2em] border-b border-slate-100">
                <tr>
                    <th class="p-10">Resource Categorization</th>
                    <th class="p-10 text-center">Batch Volume</th>
                    <th class="p-10 text-right no-print">Node Handshake</th>
                </tr>
                </thead>
                <tbody class="divide-y divide-slate-50">
                <% for(String[] item : items) {
                    int qty = Integer.parseInt(item[2]);
                    int threshold = (item.length > 5) ? Integer.parseInt(item[5]) : 10;
                    boolean isLow = qty < threshold;
                %>
                <tr class="hover:bg-indigo-50/40 transition-all duration-500 group">
                    <td class="p-10">
                        <div class="flex items-center gap-6">
                            <div class="w-16 h-16 bg-slate-50 text-slate-400 rounded-[2rem] flex items-center justify-center text-2xl group-hover:bg-indigo-600 group-hover:text-white transition-all duration-500 shadow-inner">
                                <i class="fas fa-box-archive"></i>
                            </div>
                            <div>
                                <span class="font-black text-slate-800 block text-xl italic uppercase tracking-tighter leading-none mb-2"><%= item[1] %></span>
                                <div class="flex items-center gap-2">
                                    <span class="w-2 h-2 rounded-full <%= isLow ? "bg-rose-500 animate-pulse shadow-[0_0_10px_#f43f5e]" : "bg-emerald-500" %>"></span>
                                    <span class="text-[9px] font-black uppercase tracking-widest italic <%= isLow ? "text-rose-500" : "text-slate-400" %>">
                                        <%= isLow ? "Breach: Below Critical Threshold" : "Operations: Optimal Volume" %>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </td>
                    <td class="p-10 text-center">
                        <span class="text-4xl font-black italic tracking-tighter <%= isLow ? "text-rose-600" : "text-slate-900" %>"><%= qty %></span>
                        <span class="text-[8px] font-black text-slate-300 block uppercase tracking-widest mt-2 italic">Confirmed Units on Hand</span>
                    </td>
                    <td class="p-10 text-right no-print">
                        <button onclick="openUpdateModal(<%= item[0] %>, '<%= item[1].replace("'", "\\'") %>', <%= qty %>)"
                                class="bg-slate-950 text-white px-10 py-5 rounded-[2rem] text-[10px] font-black uppercase tracking-widest hover:bg-indigo-600 transition-all shadow-xl active:scale-95">
                            Adjust Assets
                        </button>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <jsp:include page="/includes/footer.jsp" />
</main>

<%-- 3. Adjustment Modal (Focal Point Design) --%>
<div id="updateModal" class="hidden fixed inset-0 bg-slate-950/90 backdrop-blur-xl z-[5000] flex items-center justify-center p-6 no-print">
    <div class="bg-white rounded-[4rem] w-full max-w-lg p-12 shadow-2xl animate-reveal border border-indigo-100 overflow-hidden relative">
        <i class="fas fa-sliders absolute -right-6 -bottom-6 text-[12rem] text-slate-50 italic font-black pointer-events-none"></i>

        <div class="text-center mb-10 relative z-10">
            <div class="w-24 h-24 bg-indigo-50 text-indigo-500 rounded-[2.5rem] flex items-center justify-center mx-auto mb-6 shadow-inner">
                <i class="fas fa-gears text-4xl"></i>
            </div>
            <h3 class="text-3xl font-black uppercase italic tracking-tighter text-slate-900">Volume Adjustment</h3>
            <p id="modalProductName" class="text-indigo-600 text-[10px] font-black uppercase tracking-[0.2em] mt-3 bg-indigo-50 px-6 py-2 rounded-full inline-block italic"></p>
        </div>

        <form method="POST" class="relative z-10">
            <input type="hidden" name="product_id" id="modal_pid">
            <input type="hidden" name="product_name" id="modal_pname">
            <div class="mb-12">
                <label class="text-[10px] font-black text-slate-400 uppercase tracking-[0.4em] block mb-4 text-center italic">New Verification Quantity</label>
                <input type="number" name="quantity" id="modal_qty" required
                       class="w-full p-10 bg-slate-50 border-none rounded-[3rem] font-black text-7xl text-indigo-600 focus:ring-4 focus:ring-indigo-500/10 transition outline-none shadow-inner text-center tracking-tighter">
            </div>
            <div class="flex flex-col gap-4">
                <button type="submit" name="update_stock" class="w-full bg-slate-950 text-white py-8 rounded-[2.5rem] font-black uppercase tracking-[0.3em] text-[10px] hover:bg-emerald-500 transition-all shadow-2xl active:scale-95">
                    Authorize Node Sync
                </button>
                <button type="button" onclick="closeModal()" class="w-full py-2 text-slate-400 font-bold uppercase text-[9px] tracking-widest hover:text-rose-500 transition-colors">Abort Adjustments</button>
            </div>
        </form>
    </div>
</div>

<script>
    // Asset Search Trace
    document.getElementById('stockSearch').addEventListener('keyup', function() {
        let val = this.value.toUpperCase();
        let rows = document.querySelector("#stockTable tbody").rows;
        for (let row of rows) {
            let text = row.cells[0].textContent.toUpperCase();
            row.style.display = text.includes(val) ? "" : "none";
        }
    });

    // Modal Control Logic
    function openUpdateModal(id, name, qty) {
        document.getElementById('modal_pid').value = id;
        document.getElementById('modal_pname').value = name;
        document.getElementById('modal_qty').value = qty;
        document.getElementById('modalProductName').innerText = name;
        document.getElementById('updateModal').classList.remove('hidden');
    }
    function closeModal() { document.getElementById('updateModal').classList.add('hidden'); }

    // RMI Sync Notifications
    <% if(successFlag) { %>
    Swal.fire({
        icon: 'success',
        title: '<span class="italic uppercase tracking-tighter">NODE SYNCHRONIZED</span>',
        text: 'Inventory volume successfully authorized across node.',
        confirmButtonColor: '#10b981',
        customClass: { popup: 'rounded-[3rem] p-10' }
    });
    <% } %>
    <% if(!errorMsg.isEmpty()) { %>
    Swal.fire({
        icon: 'error',
        title: '<span class="italic uppercase tracking-tighter">SYNC HALTED</span>',
        text: '<%= errorMsg %>',
        confirmButtonColor: '#ef4444',
        customClass: { popup: 'rounded-[3rem] p-10' }
    });
    <% } %>
</script>
</body>
</html>