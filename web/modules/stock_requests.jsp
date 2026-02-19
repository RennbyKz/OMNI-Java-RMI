<%@ page import="java.rmi.Naming, common.InventoryService, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session.getAttribute("user_id") == null || !"Manager".equals(session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp"); return;
    }
    request.setAttribute("active_page", "stock_requests.jsp");

    int branchId = (int) session.getAttribute("branch_id");
    String search = request.getParameter("search");
    String statusFilter = request.getParameter("status_filter");

    InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");

    // Logic Handlers
    String delId = request.getParameter("delete_id");
    if (delId != null && !delId.trim().isEmpty()) {
        try {
            if(service.deleteStockRequest(Integer.parseInt(delId), branchId)) {
                response.sendRedirect("stock_requests.jsp?msg=deleted"); return;
            }
        } catch (Exception e) { }
    }

    if (request.getParameter("wipe_all") != null) {
        service.wipeBranchHistory(branchId);
        response.sendRedirect("stock_requests.jsp?msg=wiped"); return;
    }

    List<String[]> requests = service.getStockRequests(branchId, search, statusFilter);
    List<String[]> suppliers = service.getSuppliers();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Procurement Hub | OMNI FLOW</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        body { background-color: #F8FAFC; color: #1E293B; }
        .main-content { margin-left: 320px; transition: all 0.4s ease; }
        @media (max-width: 1024px) { .main-content { margin-left: 0; } }

        /* Modern Glass Cards */
        .glass-card { background: white; border: 1px solid rgba(99, 102, 241, 0.1); transition: all 0.4s ease; }
        .glass-card:hover { border-color: #6366f1; transform: translateY(-5px); box-shadow: 0 30px 60px -15px rgba(99, 102, 241, 0.1); }

        .form-input { background: #F1F5F9; border: 2px solid transparent; transition: all 0.3s; }
        .form-input:focus { background: white; border-color: #6366f1; outline: none; box-shadow: 0 0 15px rgba(99, 102, 241, 0.1); }

        .animate-pop { animation: popIn 0.6s cubic-bezier(0.26, 1.36, 0.4, 1) forwards; opacity: 0; }
        @keyframes popIn { from { opacity: 0; transform: scale(0.95); } to { opacity: 1; transform: scale(1); } }
    </style>
</head>
<body class="font-sans antialiased">

<jsp:include page="/templates/sidebar_manager.jsp" />

<main class="main-content min-h-screen p-6 lg:p-12">
    <div class="no-print"><jsp:include page="/includes/header.jsp" /></div>

    <div class="mb-12 flex justify-between items-end animate-pop">
        <div class="space-y-2">
            <h2 class="text-6xl font-black text-slate-900 tracking-tighter italic uppercase leading-none">
                Acquisition <span class="text-indigo-600">Hub</span>
            </h2>
            <p class="text-[10px] font-bold text-slate-400 uppercase tracking-[0.5em] ml-2">Protocol: Strategic Replenishment</p>
        </div>
        <button onclick="confirmWipe()" class="no-print text-rose-500 font-black text-[9px] uppercase tracking-widest hover:bg-rose-50 px-6 py-3 rounded-xl transition-all">
            <i class="fas fa-trash-can mr-2"></i> Redact All Logs
        </button>
    </div>

    <div class="grid grid-cols-1 xl:grid-cols-12 gap-10">

        <%-- Left Column: Integrated Request Console --%>
        <div class="xl:col-span-4 no-print animate-pop" style="animation-delay: 0.1s;">
            <div class="glass-card p-10 rounded-[3.5rem] sticky top-10">
                <div class="flex items-center gap-4 mb-10">
                    <div class="w-12 h-12 bg-indigo-600 text-white rounded-2xl flex items-center justify-center shadow-lg shadow-indigo-200">
                        <i class="fas fa-plus"></i>
                    </div>
                    <h3 class="text-2xl font-black uppercase italic tracking-tighter">New Request</h3>
                </div>

                <form action="../ProcessRequestServlet" method="POST" class="space-y-6">
                    <div class="space-y-2">
                        <label class="text-[9px] font-black uppercase tracking-widest text-slate-400 ml-2">1. Select Partner</label>
                        <select name="supplier_id" id="supplierSelect" required class="w-full p-5 form-input rounded-2xl font-bold text-xs appearance-none">
                            <option value="">-- Choose Supplier --</option>
                            <% for(String[] s : suppliers) { %>
                            <option value="<%= s[0] %>"><%= s[1] %></option>
                            <% } %>
                        </select>
                    </div>

                    <div class="space-y-2">
                        <label class="text-[9px] font-black uppercase tracking-widest text-slate-400 ml-2">2. Resource Identity</label>
                        <select name="product_name" id="productSelect" required class="w-full p-5 form-input rounded-2xl font-bold text-xs appearance-none">
                            <option value="">-- Select Partner First --</option>
                        </select>
                    </div>

                    <div class="space-y-2">
                        <label class="text-[9px] font-black uppercase tracking-widest text-slate-400 ml-2">3. Quantity (Units)</label>
                        <input type="number" name="quantity" required min="1" placeholder="Enter Batch Volume" class="w-full p-5 form-input rounded-2xl font-black text-sm">
                    </div>

                    <%-- ⭐ Note/Remark Area --%>
                    <div class="space-y-2">
                        <label class="text-[9px] font-black uppercase tracking-widest text-slate-400 ml-2">4. Operational Note</label>
                        <textarea name="remark" placeholder="Describe the reason for replenishment..." rows="3" class="w-full p-5 form-input rounded-2xl font-bold text-xs resize-none"></textarea>
                    </div>

                    <button type="submit" class="w-full bg-slate-900 text-white p-6 rounded-[2.2rem] font-black uppercase tracking-widest text-[10px] shadow-2xl hover:bg-indigo-600 transition-all active:scale-95">
                        Transmit Protocol
                    </button>
                </form>
            </div>
        </div>

        <%-- Right Column: Dynamic Ledger --%>
        <div class="xl:col-span-8 space-y-8 animate-pop" style="animation-delay: 0.2s;">

            <%-- Filter Bar --%>
            <div class="bg-white p-4 rounded-[2.2rem] shadow-sm border border-slate-100 flex items-center gap-4 no-print">
                <form action="" method="GET" class="flex flex-1 gap-3">
                    <div class="flex-1 relative">
                        <i class="fas fa-search absolute left-5 top-1/2 -translate-y-1/2 text-slate-300"></i>
                        <input type="text" name="search" value="<%= (search != null) ? search : "" %>" placeholder="Quick Trace ID..." class="w-full pl-12 pr-6 py-4 bg-slate-50 border-none rounded-2xl font-bold text-[10px] outline-none focus:ring-2 focus:ring-indigo-100">
                    </div>
                    <select name="status_filter" class="px-6 bg-slate-50 border-none rounded-2xl font-black text-[9px] uppercase text-slate-500">
                        <option value="">Global Status</option>
                        <option value="PENDING" <%= "PENDING".equals(statusFilter) ? "selected" : "" %>>Pending</option>
                        <option value="SHIPPED" <%= "SHIPPED".equals(statusFilter) ? "selected" : "" %>>Shipped</option>
                        <option value="RECEIVED" <%= "RECEIVED".equals(statusFilter) ? "selected" : "" %>>Received</option>
                    </select>
                    <button type="submit" class="bg-indigo-600 text-white px-8 py-4 rounded-2xl font-black uppercase text-[10px] tracking-widest hover:bg-slate-900 transition-all">Sync</button>
                </form>
            </div>

            <%-- Data Ledger Table --%>
            <div class="glass-card rounded-[4rem] overflow-hidden">
                <table class="w-full text-left">
                    <thead class="bg-slate-50 text-[10px] font-black uppercase text-slate-400 tracking-widest border-b">
                    <tr>
                        <th class="p-10">Handshake</th>
                        <th class="p-10">Resource Details</th>
                        <th class="p-10 text-center">Batch</th>
                        <th class="p-10 text-right">Status</th>
                    </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-50">
                    <% if(requests.isEmpty()) { %>
                    <tr><td colspan="4" class="p-32 text-center text-slate-300 font-black italic uppercase tracking-[0.4em] text-[10px]">No acquisition traces detected.</td></tr>
                    <% } else {
                        for(String[] r : requests) { %>
                    <tr class="hover:bg-indigo-50/30 transition-all group">
                        <td class="p-10">
                            <span class="font-bold text-slate-700 text-xs block mb-1"><%= r[4].split(" ")[0] %></span>
                            <span class="text-[9px] text-indigo-500 font-black italic uppercase"><%= r[4].split(" ")[1] %></span>
                        </td>
                        <td class="p-10">
                            <span class="font-black text-slate-800 block text-lg italic uppercase tracking-tighter leading-none mb-2"><%= r[1] %></span>
                            <div class="flex flex-col gap-1.5">
                                <span class="text-[9px] font-bold text-slate-400 uppercase tracking-widest flex items-center gap-2">
                                    <i class="fas fa-link text-[8px]"></i> Partner: <%= r[5] %>
                                </span>
                                <%-- ⭐ Show Note if exists --%>
                                <% if(r.length > 7 && r[7] != null && !r[7].isEmpty()) { %>
                                <span class="text-[10px] text-indigo-400 italic font-medium">Note: "<%= r[7] %>"</span>
                                <% } %>
                            </div>
                        </td>
                        <td class="p-10 text-center font-black text-4xl text-slate-900 italic tracking-tighter"><%= r[2] %></td>
                        <td class="p-10 text-right">
                            <div class="flex flex-col items-end gap-3">
                                <span class="px-6 py-2.5 rounded-full font-black uppercase text-[9px] tracking-[0.2em] border
                                    <%= r[3].equals("PENDING") ? "bg-amber-50 text-amber-500 border-amber-100" :
                                       (r[3].equals("SHIPPED") ? "bg-indigo-50 text-indigo-600 border-indigo-100" : "bg-emerald-50 text-emerald-600 border-emerald-100") %>">
                                    <%= r[3] %>
                                </span>
                                <button onclick="confirmDelete(<%= r[0] %>, '<%= r[1].replace("'", "\\'") %>')" class="text-rose-300 hover:text-rose-600 transition-all">
                                    <i class="fas fa-trash-can text-sm"></i>
                                </button>
                            </div>
                        </td>
                    </tr>
                    <% } } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <jsp:include page="/includes/footer.jsp" />
</main>

<script>
    // Dynamic Fetch Logic
    document.getElementById('supplierSelect').addEventListener('change', function() {
        const sid = this.value;
        const ps = document.getElementById('productSelect');
        if (!sid) { ps.innerHTML = '<option value="">-- Select Partner First --</option>'; return; }
        ps.innerHTML = '<option value="">-- Loading... --</option>';
        fetch('get_supplier_products.jsp?supplier_id=' + sid)
            .then(r => r.json())
            .then(data => {
                ps.innerHTML = '<option value="">-- Choose Asset --</option>';
                data.forEach(p => {
                    let o = document.createElement('option');
                    o.value = p.product_name; o.textContent = p.product_name;
                    ps.appendChild(o);
                });
            });
    });

    function confirmDelete(id, name) {
        Swal.fire({
            title: '<span class="uppercase italic">Purge Log?</span>',
            text: `Authorize removal of trace for ${name}?`,
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#2E5077',
            confirmButtonText: 'CONFIRM DELETE',
            background: '#F8FAFC',
            customClass: { popup: 'rounded-[3rem] p-10' }
        }).then((res) => { if (res.isConfirmed) window.location.href = "stock_requests.jsp?delete_id=" + id; });
    }

    function confirmWipe() {
        Swal.fire({
            title: '<span class="uppercase italic">Node Wipe?</span>',
            text: "Redact all local procurement traces permanently!",
            icon: 'error',
            showCancelButton: true,
            confirmButtonColor: '#ef4444',
            confirmButtonText: 'EXECUTE WIPE',
            background: '#F8FAFC',
            customClass: { popup: 'rounded-[3rem] p-10' }
        }).then((res) => { if (res.isConfirmed) window.location.href = `stock_requests.jsp?wipe_all=true`; });
    }
</script>
</body>
</html>