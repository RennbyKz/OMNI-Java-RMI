<%@ page import="java.rmi.Naming, common.InventoryService, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session.getAttribute("user_id") == null || !"Admin".equals(session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp"); return;
    }
    request.setAttribute("active_page", "shipments");

    InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");

    // ၂။ ⭐ Action Handlers (Error Handling Fixed)
    String delId = request.getParameter("delete_id");
    if (delId != null && !delId.trim().isEmpty()) {
        try {
            service.deleteShipmentHistory(Integer.parseInt(delId.trim()));
            response.sendRedirect("shipment_tracking.jsp?msg=deleted"); return;
        } catch (Exception e) { e.printStackTrace(); }
    }

    if (request.getParameter("confirm_receive") != null) {
        String ridStr = request.getParameter("request_id");
        String qtyStr = request.getParameter("actual_qty");
        if (ridStr != null && !ridStr.isEmpty() && qtyStr != null && !qtyStr.isEmpty()) {
            service.receiveShipment(Integer.parseInt(ridStr), Integer.parseInt(qtyStr));
            response.sendRedirect("shipment_tracking.jsp?msg=success"); return;
        }
    }

    String filter = request.getParameter("filter") != null ? request.getParameter("filter") : "ALL";
    List<String[]> shipments = service.getShipments(filter);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Logistics Intelligence | OMNI CORE</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <style>
        body { background-color: #F6F4F0; }
        .main-content { margin-left: 290px; transition: all 0.4s ease; }
        @media (max-width: 1024px) { .main-content { margin-left: 0; } }

        /* Premium Card Design */
        .glass-card {
            background: white;
            border: 2px solid #E2E8F0;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            border-radius: 3rem;
        }
        .glass-card:hover {
            transform: translateY(-12px);
            box-shadow: 0 40px 60px -15px rgba(46, 80, 119, 0.1);
            border-color: #79D7BE;
        }
        .shipped-status { border-top: 8px solid #fbbf24; }
        .received-status { border-top: 8px solid #79D7BE; }

        .btn-navy { background: #2E5077; color: white; transition: 0.3s; }
        .btn-navy:hover { background: #4DA1A9; }
    </style>
</head>
<body class="text-[#2E5077] antialiased">

<jsp:include page="/templates/sidebar_admin.jsp" />

<main class="main-content min-h-screen p-6 lg:p-10 pt-4">
    <jsp:include page="/includes/header.jsp" />

    <div class="mt-10 max-w-[1600px] mx-auto">

        <div class="mb-12 flex flex-col lg:flex-row justify-between items-start lg:items-end gap-6 px-4">
            <div>
                <div class="flex items-center gap-3 mt-4">
                    <span class="h-1.5 w-16 bg-[#79D7BE] rounded-full"></span>
                    <p class="text-[#4DA1A9] text-[10px] font-bold uppercase tracking-[0.5em]">Shipment Tracking</p>
                </div>
            </div>

            <div class="flex flex-wrap items-center gap-4">
                <div class="bg-white/60 p-1.5 rounded-[2rem] border border-[#4DA1A9]/20 flex gap-1 shadow-inner">
                    <a href="?filter=ALL" class="px-6 py-3 rounded-full text-[10px] font-black uppercase tracking-widest transition <%= filter.equals("ALL") ? "bg-[#2E5077] text-white shadow-lg" : "text-[#4DA1A9]" %>">All</a>
                    <a href="?filter=SHIPPED" class="px-6 py-3 rounded-full text-[10px] font-black uppercase tracking-widest transition <%= filter.equals("SHIPPED") ? "bg-amber-500 text-white shadow-lg" : "text-[#4DA1A9]" %>">In-Transit</a>
                    <a href="?filter=RECEIVED" class="px-6 py-3 rounded-full text-[10px] font-black uppercase tracking-widest transition <%= filter.equals("RECEIVED") ? "bg-[#79D7BE] text-[#2E5077] shadow-lg" : "text-[#4DA1A9]" %>">Archives</a>
                </div>
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 2xl:grid-cols-4 gap-8 px-4 pb-20">
            <% if (shipments != null) { for(String[] s : shipments) {
                boolean isShipped = "SHIPPED".equals(s[3]);
            %>
            <div class="glass-card p-8 <%= isShipped ? "shipped-status" : "received-status" %>">

                <div class="flex justify-between items-start mb-6">
                    <span class="px-3 py-1 rounded-full bg-slate-50 text-slate-400 text-[9px] font-black border border-slate-100 uppercase">
                        NODE-ID: <%= s[0] %>
                    </span>
                    <% if(!isShipped) { %>
                    <button onclick="confirmDelete(<%= s[0] %>)" class="w-8 h-8 rounded-lg bg-rose-50 text-rose-400 hover:bg-rose-500 hover:text-white transition flex items-center justify-center">
                        <i class="fa-solid fa-trash-can"></i>
                    </button>
                    <% } %>
                </div>

                <div class="mb-8">
                    <h3 class="text-xl font-black uppercase italic tracking-tighter truncate mb-1"><%= s[1] %></h3>
                    <p class="text-[9px] font-bold text-indigo-400 uppercase tracking-widest flex items-center gap-2">
                        <i class="fa-solid fa-link"></i> <%= s[4] %>
                    </p>
                </div>

                <div class="grid grid-cols-2 gap-3 mb-8">
                    <div class="bg-slate-50 p-4 rounded-2xl text-center border border-slate-100">
                        <span class="block text-[8px] font-black text-slate-400 uppercase mb-1">Quantity</span>
                        <span class="text-2xl font-black italic"><%= s[2] %></span>
                    </div>
                    <div class="bg-slate-50 p-4 rounded-2xl text-center border border-slate-100">
                        <span class="block text-[8px] font-black text-slate-400 uppercase mb-1">Target Hub</span>
                        <span class="text-[10px] font-black uppercase truncate block"><%= s[5] %></span>
                    </div>
                </div>

                <% if(isShipped) { %>
                <button onclick="openReceiveModal(<%= s[0] %>, '<%= s[1] %>', <%= s[2] %>)"
                        class="btn-navy w-full py-4 rounded-[1.5rem] font-black uppercase text-[10px] flex items-center justify-center gap-2 shadow-lg">
                    <i class="fa-solid fa-truck-fast"></i> Confirm Receipt
                </button>
                <% } else { %>
                <div class="pt-6 border-t border-dashed border-slate-100">
                    <div class="flex items-center justify-between text-[10px] font-black uppercase italic text-[#79D7BE]">
                        <span><i class="fa-solid fa-circle-check mr-1"></i> Verified</span>
                        <span class="text-slate-300"><%= s[6] %></span>
                    </div>
                    <p class="mt-3 p-3 bg-slate-50 rounded-xl text-[9px] font-bold text-slate-400 italic">"<%= s[7] %>"</p>
                </div>
                <% } %>
            </div>
            <% } } %>
        </div>
    </div>
</main>

<div id="receiveModal" class="hidden fixed inset-0 bg-[#2E5077]/60 backdrop-blur-xl z-[9999] flex items-center justify-center p-6">
    <div class="bg-white rounded-[3.5rem] w-full max-w-md shadow-2xl overflow-hidden">
        <div class="bg-[#2E5077] p-10 text-white text-center">
            <h3 class="text-2xl font-black uppercase italic tracking-tighter">Goods Handshake</h3>
            <p class="text-[#79D7BE] text-[10px] font-bold uppercase tracking-[0.3em] mt-2">Inventory Sync Protocol</p>
        </div>
        <form action="shipment_tracking.jsp" method="POST" class="p-10 space-y-8">
            <input type="hidden" name="request_id" id="modal_request_id">
            <div>
                <label class="block text-center text-[10px] font-black text-[#4DA1A9] uppercase mb-4 tracking-widest">Verify Units Received</label>
                <input type="number" name="actual_qty" id="modal_actual_qty" required
                       class="w-full bg-slate-50 border-none rounded-[2rem] p-8 text-center text-5xl font-black text-[#2E5077] shadow-inner outline-none">
            </div>
            <button type="submit" name="confirm_receive" class="btn-navy w-full py-5 rounded-[2rem] font-black uppercase text-[11px] shadow-xl">Complete Deployment</button>
            <button type="button" onclick="closeModal()" class="w-full text-slate-400 font-black uppercase text-[10px] py-2">Abort</button>
        </form>
    </div>
</div>

<script>
    function openReceiveModal(id, name, qty) {
        document.getElementById('modal_request_id').value = id;
        document.getElementById('modal_actual_qty').value = qty;
        document.getElementById('receiveModal').classList.remove('hidden');
    }
    function closeModal() { document.getElementById('receiveModal').classList.add('hidden'); }

    function confirmDelete(id) {
        if(!id) return;
        Swal.fire({
            title: 'REMOVE LOG?',
            text: "This record will be redacted from history.",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#2E5077',
            confirmButtonText: 'CONFIRM DELETE',
            background: '#F6F4F0',
            customClass: { popup: 'rounded-[2rem]' }
        }).then((result) => {
            if (result.isConfirmed) { window.location.href = "shipment_tracking.jsp?delete_id=" + id; }
        })
    }
</script>
</body>
</html>