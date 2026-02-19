<%@ page import="java.rmi.Naming, common.InventoryService, java.util.*, java.io.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session.getAttribute("user_id") == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    request.setAttribute("active_page", "orders");

    InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");

    // CSV Export Logic remains same
    if (request.getParameter("export") != null) {
        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=Pending_Orders_" + new java.util.Date().getTime() + ".csv");
        List<String[]> orders = service.getPendingOrders();
        PrintWriter writer = response.getWriter();
        writer.println("Order ID, Product Name, Quantity, Branch, Status, Date");
        if (orders != null) {
            for(String[] row : orders) {
                writer.println(row[0] + "," + row[1] + "," + row[2] + "," + row[3] + "," + row[4] + "," + row[5]);
            }
        }
        writer.flush(); writer.close(); return;
    }

    if (request.getParameter("place_order") != null) {
        try {
            int pId = Integer.parseInt(request.getParameter("product_id"));
            int qty = Integer.parseInt(request.getParameter("quantity"));
            int bId = Integer.parseInt(request.getParameter("branch_id"));
            if(service.placeOrder(pId, qty, bId)) {
                response.sendRedirect("order_stock.jsp?msg=success");
                return;
            }
        } catch (Exception e) { e.printStackTrace(); }
    }

    List<String[]> products = service.getInventory();
    List<String[]> branches = service.getBranches();
    List<String[]> recentOrders = service.getPendingOrders();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Stock Procurement | OMNI CORE</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        body { background-color: #F6F4F0; scroll-behavior: smooth; }
        .main-content { margin-left: 290px; transition: all 0.4s ease; }
        @media (max-width: 1024px) { .main-content { margin-left: 0; } }

        .glass-card { background: rgba(255, 255, 255, 0.7); backdrop-filter: blur(12px); border: 1px solid rgba(77, 161, 169, 0.15); }
        .order-input:focus { border-color: #79D7BE; ring: 2px; ring-color: #79D7BE/20; }
        .custom-scrollbar::-webkit-scrollbar { width: 5px; }
        .custom-scrollbar::-webkit-scrollbar-thumb { background: #4DA1A9; border-radius: 10px; }
    </style>
</head>
<body class="font-sans text-[#2E5077] antialiased">

<jsp:include page="/templates/sidebar_admin.jsp" />

<main class="main-content min-h-screen p-6 lg:p-10 relative">
    <jsp:include page="/includes/header.jsp" />

    <div class="max-w-6xl mx-auto mt-10">
        <%-- Header Section --%>
        <div class="mb-10 flex flex-col md:flex-row justify-between items-start md:items-end gap-6 px-4">
            <div>
                <div class="flex items-center gap-3 mt-3">
                    <span class="w-10 h-1 bg-[#79D7BE] rounded-full"></span>
                    <p class="text-[#4DA1A9] text-[10px] font-bold uppercase tracking-[0.3em]">External Supplier Transmission</p>
                </div>
            </div>
            <a href="?export=1" class="bg-white text-[#2E5077] px-6 py-4 rounded-2xl font-bold uppercase text-[10px] tracking-widest shadow-sm border border-[#4DA1A9]/20 hover:bg-[#F6F4F0] transition flex items-center gap-3">
                <i class="fas fa-file-csv text-[#79D7BE]"></i> Export CSV Log
            </a>
        </div>

        <div class="grid grid-cols-1 xl:grid-cols-3 gap-8 px-4">
            <%-- Procurement Form --%>
            <div class="xl:col-span-2">
                <div class="bg-white rounded-[3rem] shadow-xl shadow-slate-200/50 p-10 border border-[#4DA1A9]/10">
                    <form action="order_stock.jsp" method="POST" class="space-y-8">
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                            <div>
                                <label class="block text-[9px] font-black text-[#4DA1A9] uppercase tracking-widest mb-3 ml-2">Select Asset Node</label>
                                <div class="relative">
                                    <i class="fas fa-microchip absolute left-5 top-1/2 -translate-y-1/2 text-[#79D7BE]"></i>
                                    <select name="product_id" id="p_select" required
                                            class="w-full pl-12 pr-6 py-5 bg-[#F6F4F0] border-none rounded-2xl font-bold text-[#2E5077] outline-none shadow-inner appearance-none cursor-pointer">
                                        <option value="">Select Asset</option>
                                        <% if(products != null) { for(String[] p : products) { %>
                                        <option value="<%= p[0] %>" data-price="<%= p[3] %>"><%= p[1] %></option>
                                        <% } } %>
                                    </select>
                                </div>
                            </div>
                            <div>
                                <label class="block text-[9px] font-black text-[#4DA1A9] uppercase tracking-widest mb-3 ml-2">Purchase Quantity</label>
                                <input type="number" name="quantity" min="1" required
                                       class="w-full p-5 bg-[#F6F4F0] border-none rounded-2xl outline-none font-black text-[#2E5077] text-2xl shadow-inner text-center" placeholder="0">
                            </div>
                        </div>

                        <div>
                            <label class="block text-[9px] font-black text-[#4DA1A9] uppercase tracking-widest mb-3 ml-2">Destination Fulfillment Hub</label>
                            <div class="relative">
                                <i class="fas fa-warehouse absolute left-5 top-1/2 -translate-y-1/2 text-[#79D7BE]"></i>
                                <select name="branch_id" required
                                        class="w-full pl-12 pr-6 py-5 bg-[#F6F4F0] border-none rounded-2xl font-bold text-[#2E5077] outline-none shadow-inner appearance-none cursor-pointer">
                                    <% if(branches != null) { for(String[] b : branches) { %>
                                    <option value="<%= b[0] %>"><%= b[1] %></option>
                                    <% } } %>
                                </select>
                            </div>
                        </div>

                        <button type="submit" name="place_order" class="w-full bg-[#2E5077] text-white p-7 rounded-[2rem] font-black uppercase tracking-[0.3em] shadow-xl hover:bg-[#4DA1A9] transition-all flex items-center justify-center gap-4 group">
                            <i class="fas fa-paper-plane group-hover:translate-x-3 transition-transform text-[#79D7BE]"></i>
                            Transmit Purchase Order
                        </button>
                    </form>
                </div>
            </div>

            <%-- Real-time Insights --%>
            <div class="space-y-8">
                <div id="priceCard" class="bg-[#2E5077] text-white p-8 rounded-[2.5rem] shadow-xl relative overflow-hidden hidden transition-all duration-500">
                    <i class="fas fa-tag absolute -right-4 -bottom-4 text-7xl text-white/5"></i>
                    <span class="text-[9px] font-black uppercase tracking-widest text-[#79D7BE]">Consolidated Unit Price</span>
                    <h4 class="text-3xl font-black mt-2 italic tracking-tighter"><span id="unitPrice">0</span> <span class="text-[10px] font-bold text-[#4DA1A9] not-italic">MMK</span></h4>
                </div>

                <div class="glass-card p-8 rounded-[2.5rem] shadow-sm max-h-[450px] overflow-hidden flex flex-col">
                    <h4 class="text-[9px] font-black uppercase tracking-[0.2em] mb-6 flex items-center gap-2">
                        <span class="w-2 h-2 rounded-full bg-[#79D7BE] animate-pulse"></span> Transmission Stream
                    </h4>
                    <div class="space-y-5 overflow-y-auto custom-scrollbar pr-2">
                        <% if(recentOrders != null && !recentOrders.isEmpty()) {
                            for(String[] ro : recentOrders) { %>
                        <div class="flex justify-between items-center border-b border-[#4DA1A9]/10 pb-4 last:border-0">
                            <div>
                                <p class="text-[10px] font-black text-[#2E5077] uppercase italic leading-none mb-1.5"><%= ro[1] %></p>
                                <p class="text-[8px] font-bold text-slate-400 uppercase tracking-wider"><%= ro[2] %> Units • <%= ro[3] %></p>
                            </div>
                            <span class="bg-[#79D7BE]/10 text-[#79D7BE] px-2.5 py-1 rounded-lg text-[7px] font-black uppercase border border-[#79D7BE]/20"><%= ro[4] %></span>
                        </div>
                        <% } } else { %>
                        <p class="text-[10px] font-bold text-slate-300 italic">No recent transmissions.</p>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="/includes/footer.jsp" />
</main>



<script>
    // Asset change listener
    document.getElementById('p_select').addEventListener('change', function() {
        const price = this.options[this.selectedIndex].getAttribute('data-price');
        const card = document.getElementById('priceCard');
        const priceDisplay = document.getElementById('unitPrice');
        if(price) {
            card.classList.remove('hidden');
            priceDisplay.innerText = new Intl.NumberFormat().format(price);
        } else {
            card.classList.add('hidden');
        }
    });

    // Alert Logic
    const params = new URLSearchParams(window.location.search);
    if(params.get('msg') === 'success') {
        Swal.fire({
            icon: 'success',
            title: '<span class="uppercase italic">Order Transmitted</span>',
            text: 'Strategic procurement protocol initiated successfully.',
            confirmButtonColor: '#2E5077',
            background: '#F6F4F0',
            customClass: { popup: 'rounded-[2rem]' }
        });
        window.history.replaceState({}, document.title, window.location.pathname);
    }
</script>
</body>
</html>