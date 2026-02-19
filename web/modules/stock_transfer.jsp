<%@ page import="java.rmi.Naming, common.InventoryService, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session.getAttribute("user_id") == null || !session.getAttribute("role").equals("Admin")) {
        response.sendRedirect("../login.jsp"); return;
    }
    request.setAttribute("active_page", "transfer");

    InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");

    if (request.getParameter("execute_transfer") != null) {
        try {
            int fromB = Integer.parseInt(request.getParameter("from_b"));
            int toB = Integer.parseInt(request.getParameter("to_b"));
            int pId = Integer.parseInt(request.getParameter("p_id"));
            int qty = Integer.parseInt(request.getParameter("qty"));
            // User ID session logic check
            Object uidObj = session.getAttribute("user_id");
            int userId = (uidObj instanceof Integer) ? (int) uidObj : Integer.parseInt(uidObj.toString());

            boolean success = service.transferStock(fromB, toB, pId, qty, userId);
            if(success) {
                response.sendRedirect("stock_transfer.jsp?msg=success");
            } else {
                response.sendRedirect("stock_transfer.jsp?msg=error&details=Insufficient%20Stock%20at%20Source");
            }
        } catch (Exception e) {
            String errorMsg = java.net.URLEncoder.encode(e.getMessage(), "UTF-8");
            response.sendRedirect("stock_transfer.jsp?msg=error&details=" + errorMsg);
        }
        return;
    }

    List<String[]> branches = service.getBranches();
    List<String[]> products = service.getInventory();
    List<String[]> history = service.getTransferHistory();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Logistics Transfer Hub | OMNI CORE</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        body { background-color: #F6F4F0; scroll-behavior: smooth; }
        .main-content { margin-left: 290px; transition: all 0.4s ease; }
        @media (max-width: 1024px) { .main-content { margin-left: 0; } }

        .glass-card { background: rgba(255, 255, 255, 0.7); backdrop-filter: blur(12px); border: 1px solid rgba(77, 161, 169, 0.15); }
        .input-focus:focus { ring: 2px; ring-color: #79D7BE; border-color: #79D7BE; }

        .history-timeline::before {
            content: ''; position: absolute; left: 15px; top: 0; bottom: 0; width: 2px;
            background: linear-gradient(to bottom, #79D7BE, transparent);
        }
    </style>
</head>
<body class="font-sans text-[#2E5077] antialiased">

<jsp:include page="/templates/sidebar_admin.jsp" />

<main class="main-content min-h-screen p-6 lg:p-10 relative">
    <jsp:include page="/includes/header.jsp" />

    <div class="max-w-6xl mx-auto mt-10">
        <%-- Header Section --%>
        <div class="mb-10 px-4">

            <div class="flex items-center gap-3 mt-3">
                <span class="w-10 h-1 bg-[#79D7BE] rounded-full"></span>
                <p class="text-[#4DA1A9] text-[10px] font-bold uppercase tracking-[0.3em]">Inter-Branch Asset Transfer</p>
            </div>
        </div>

        <div class="grid grid-cols-1 xl:grid-cols-3 gap-8 px-4">
            <%-- Transfer Form Area --%>
            <div class="xl:col-span-2">
                <div class="bg-white rounded-[3rem] shadow-xl shadow-slate-200/50 p-10 border border-[#4DA1A9]/10">
                    <form action="stock_transfer.jsp" method="POST" id="transferForm" class="space-y-8">
                        <div>
                            <label class="text-[9px] font-black text-[#4DA1A9] uppercase tracking-widest mb-3 block ml-2">Select Asset Node</label>
                            <div class="relative">
                                <i class="fas fa-box-open absolute left-5 top-1/2 -translate-y-1/2 text-[#79D7BE]"></i>
                                <select name="p_id" id="productSelect" onchange="autoMapSource()" required
                                        class="w-full pl-12 pr-6 py-5 bg-[#F6F4F0] border-none rounded-2xl font-bold text-[#2E5077] outline-none shadow-inner appearance-none cursor-pointer">
                                    <option value="">Identify Asset to Dispatch</option>
                                    <% for(String[] p : products) { %>
                                    <option value="<%= p[0] %>" data-branch="<%= p[5] %>" data-qty="<%= p[2] %>">
                                        <%= p[1] %> (<%= p[2] %> units @ <%= p[4] %>)
                                    </option>
                                    <% } %>
                                </select>
                            </div>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                            <div>
                                <label class="text-[9px] font-black text-rose-400 uppercase tracking-widest mb-3 block ml-2 italic">Source Hub (Verified)</label>
                                <select name="from_b" id="sourceBranch" required
                                        class="w-full p-5 bg-rose-50/30 border-2 border-rose-100 rounded-2xl font-black text-rose-500 outline-none pointer-events-none italic">
                                    <% for(String[] b : branches) { %>
                                    <option value="<%= b[0] %>"><%= b[1] %></option>
                                    <% } %>
                                </select>
                            </div>

                            <div>
                                <label class="text-[9px] font-black text-[#79D7BE] uppercase tracking-widest mb-3 block ml-2 italic">Destination Target</label>
                                <div class="relative">
                                    <select name="to_b" id="targetBranch" required
                                            class="w-full p-5 bg-[#79D7BE]/5 border-2 border-[#79D7BE]/20 rounded-2xl font-black text-[#2E5077] outline-none cursor-pointer">
                                        <option value="">   Select Destination</option>
                                        <% for(String[] b : branches) { %>
                                        <option value="<%= b[0] %>"><%= b[1] %></option>
                                        <% } %>
                                    </select>
                                </div>
                            </div>
                        </div>

                        <div>
                            <label class="text-[9px] font-black text-[#4DA1A9] uppercase tracking-widest mb-3 block ml-2">Movement Magnitude (Qty)</label>
                            <div class="relative">
                                <input type="number" name="qty" id="transferQty" min="1" required
                                       class="w-full p-8 bg-[#F6F4F0] text-[#2E5077] text-6xl font-black rounded-[2rem] border-none outline-none shadow-inner text-center" placeholder="00">
                                <span class="absolute right-8 top-1/2 -translate-y-1/2 text-[#4DA1A9] font-black text-xs uppercase tracking-widest">Units</span>
                            </div>
                        </div>

                        <button type="submit" name="execute_transfer" class="w-full bg-[#2E5077] text-white p-7 rounded-[2rem] font-black uppercase tracking-[0.3em] hover:bg-[#4DA1A9] transition-all shadow-xl flex items-center justify-center gap-4 group">
                            <i class="fas fa-shipping-fast group-hover:translate-x-4 transition-transform text-[#79D7BE]"></i>
                            Initiate Transfer Node
                        </button>
                    </form>
                </div>
            </div>

            <%-- Sidebar: Stats & History --%>
            <div class="space-y-8">
                <div class="bg-[#2E5077] text-white p-8 rounded-[2.5rem] shadow-xl relative overflow-hidden">
                    <i class="fas fa-shield-halved absolute -right-4 -bottom-4 text-7xl text-white/5"></i>
                    <h4 class="text-[9px] font-black uppercase tracking-[0.2em] mb-6 text-[#79D7BE]">Security Protocol</h4>
                    <ul class="space-y-4 text-[11px] font-bold text-slate-300">
                        <li class="flex gap-3 items-start"><i class="fas fa-check-double text-[#79D7BE] mt-1"></i> Automated source node validation enabled.</li>
                        <li class="flex gap-3 items-start"><i class="fas fa-lock text-[#79D7BE] mt-1"></i> Encrypted RMI transactional integrity.</li>
                        <li class="flex gap-3 items-start"><i class="fas fa-triangle-exclamation text-rose-400 mt-1"></i> Stock levels verified before dispatch.</li>
                    </ul>
                </div>

                <div class="glass-card p-8 rounded-[2.5rem] shadow-sm relative overflow-hidden">
                    <h4 class="text-[9px] font-black uppercase tracking-[0.2em] mb-6 text-[#4DA1A9]">Node Activity Log</h4>
                    <div class="history-timeline relative space-y-6">
                        <% if(history != null && !history.isEmpty()) {
                            for(String[] h : history) { %>
                        <div class="relative pl-8">
                            <div class="absolute left-0 top-1.5 w-4 h-4 rounded-full bg-white border-4 border-[#79D7BE]"></div>
                            <p class="text-[10px] font-black text-[#2E5077] uppercase italic leading-none mb-1.5"><%= h[0] %></p>
                            <span class="text-[8px] font-bold text-[#4DA1A9] uppercase tracking-wider block"><%= h[1] %></span>
                        </div>
                        <%   }
                        } else { %>
                        <p class="text-[10px] font-bold text-slate-300 italic">No recent node movements.</p>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="/includes/footer.jsp" />
</main>



<script>
    const params = new URLSearchParams(window.location.search);
    if(params.get('msg') === 'success') {
        Swal.fire({
            icon: 'success',
            title: '<span class="uppercase italic">Node Synced</span>',
            text: 'Asset redistribution protocol completed.',
            confirmButtonColor: '#2E5077',
            background: '#F6F4F0',
            customClass: { popup: 'rounded-[2rem]' }
        });
        window.history.replaceState({}, document.title, window.location.pathname);
    } else if(params.get('msg') === 'error') {
        Swal.fire({
            icon: 'error',
            title: '<span class="uppercase italic">Protocol Error</span>',
            text: params.get('details'),
            confirmButtonColor: '#2E5077',
            background: '#F6F4F0',
            customClass: { popup: 'rounded-[2rem]' }
        });
        window.history.replaceState({}, document.title, window.location.pathname);
    }

    function autoMapSource() {
        const productSelect = document.getElementById('productSelect');
        const sourceBranch = document.getElementById('sourceBranch');
        const targetBranch = document.getElementById('targetBranch');
        const selectedOption = productSelect.options[productSelect.selectedIndex];

        const branchId = selectedOption.getAttribute('data-branch');
        const availableQty = selectedOption.getAttribute('data-qty');

        if(branchId) {
            sourceBranch.value = branchId;
            document.getElementById('transferQty').max = availableQty;
            document.getElementById('transferQty').placeholder = "Max: " + availableQty;

            Array.from(targetBranch.options).forEach(option => {
                option.disabled = (option.value === branchId);
            });
        }
    }
</script>
</body>
</html>