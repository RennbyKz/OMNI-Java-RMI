<%@ page import="java.rmi.Naming, common.InventoryService, java.util.*, java.net.URLEncoder" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // ၁။ Security & Session Check
    Object roleObj = session.getAttribute("role");
    if (roleObj == null || !"STOREKEEPER".equalsIgnoreCase(roleObj.toString())) {
        response.sendRedirect("../login.jsp");
        return;
    }

    int myBranch = Integer.parseInt(session.getAttribute("branch_id").toString());
    int userId = Integer.parseInt(session.getAttribute("user_id").toString());

    InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");

    boolean successFlag = false;
    String errorMsg = "";

    // ၂။ OUTBOUND LOGIC (POST Request)
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("register_outbound") != null) {
        try {
            int pid = Integer.parseInt(request.getParameter("product_id"));
            int outQty = Integer.parseInt(request.getParameter("quantity"));
            String pname = request.getParameter("product_name");

            // Middleware ရှိ removeStock method ကိုခေါ်ယူခြင်း
            String result = service.removeStock(pid, outQty, myBranch, userId, pname);

            if ("SUCCESS".equalsIgnoreCase(result)) {
                successFlag = true;
            } else {
                errorMsg = result;
            }
        } catch (Exception e) {
            errorMsg = "Critical Sync Failure: " + e.getMessage();
        }
    }

    // ၃။ ပစ္စည်းစာရင်းဆွဲယူခြင်း
    List<String[]> items = service.getAvailableInventory(myBranch);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Outbound Register | OMNI FLOW</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        body { background-color: #F8FAFC; color: #1E293B; }
        /* Sidebar နှင့် Header space အတွက် layout ညှိခြင်း */
        .main-content { margin-left: 280px; padding-top: 90px; transition: all 0.4s ease; }
        @media (max-width: 1024px) { .main-content { margin-left: 0; } }

        .form-container { background: white; border: 1px solid rgba(245, 158, 11, 0.1); }
        .input-focus:focus { border-color: #f59e0b; box-shadow: 0 0 0 4px rgba(245, 158, 11, 0.1); }

        .animate-reveal { animation: reveal 0.6s cubic-bezier(0.4, 0, 0.2, 1) forwards; opacity: 0; }
        @keyframes reveal { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
    </style>
</head>
<body class="font-sans antialiased selection:bg-amber-100 selection:text-amber-600">

<jsp:include page="/templates/sidebar_storekeeper.jsp" />

<main class="main-content min-h-screen p-6 lg:p-12 relative flex flex-col">
    <jsp:include page="/includes/header.jsp" />

    <%-- 1. Hero Title --%>
    <div class="mb-10 animate-reveal text-center xl:text-left">
        <h2 class="text-6xl font-black text-slate-900 tracking-tighter italic uppercase leading-none">
            Outbound <span class="text-amber-500">Register</span>
        </h2>
        <div class="flex items-center justify-center xl:justify-start gap-4 mt-4">
            <span class="w-12 h-1 bg-amber-500 rounded-full"></span>
            <p class="text-slate-400 text-[10px] font-black uppercase tracking-[0.4em] italic">Recording Local Asset Dispatch</p>
        </div>
    </div>

    <%-- 2. Dispatch Console --%>
    <div class="flex-1 flex items-center justify-center pb-20 animate-reveal" style="animation-delay: 0.1s;">
        <div class="w-full max-w-2xl form-container p-12 rounded-[4rem] shadow-sm relative overflow-hidden">
            <%-- Decorative Background Icon --%>
            <i class="fas fa-arrow-up-right-from-square absolute -right-6 -bottom-6 text-[12rem] text-slate-50 italic font-black pointer-events-none"></i>

            <form method="POST" class="space-y-10 relative z-10">
                <div class="space-y-4">
                    <label class="text-[10px] font-black text-slate-400 uppercase tracking-widest ml-4 block">1. Select Dispatch Asset</label>
                    <div class="relative">
                        <select name="product_id" id="prodSelectOut" required
                                class="w-full p-6 bg-slate-50 border-2 border-transparent rounded-3xl font-black text-slate-700 outline-none input-focus appearance-none cursor-pointer transition-all">
                            <option value="">-- Choose Dispatch Asset --</option>
                            <% for(String[] i : items) { %>
                            <option value="<%= i[0] %>" data-name="<%= i[1] %>">
                                <%= i[1] %> (Available: <%= i[2] %>)
                            </option>
                            <% } %>
                        </select>
                        <i class="fas fa-chevron-down absolute right-6 top-1/2 -translate-y-1/2 text-slate-300 pointer-events-none"></i>
                    </div>
                    <input type="hidden" name="product_name" id="prodNameOut">
                </div>

                <div class="space-y-4">
                    <label class="text-[10px] font-black text-slate-400 uppercase tracking-widest ml-4 block">2. Dispatch Volume (Units)</label>
                    <div class="relative">
                        <input type="number" name="quantity" required min="1" placeholder="00"
                               class="w-full p-10 bg-slate-50 border-2 border-transparent rounded-[3rem] font-black text-7xl text-amber-600 outline-none input-focus transition-all text-center tracking-tighter">
                        <span class="absolute right-10 top-1/2 -translate-y-1/2 font-black text-slate-200 text-xs uppercase tracking-widest">PCS</span>
                    </div>
                </div>

                <div class="pt-4">
                    <button type="submit" name="register_outbound"
                            class="w-full bg-slate-950 text-white p-8 rounded-[2.5rem] font-black uppercase tracking-[0.3em] hover:bg-amber-600 transition-all shadow-2xl active:scale-95 group flex items-center justify-center gap-4">
                        <i class="fas fa-file-export text-amber-400 group-hover:translate-x-1 transition-transform"></i>
                        <span>Authorize Dispatch</span>
                    </button>
                </div>
            </form>
        </div>
    </div>

    <jsp:include page="/includes/footer.jsp" />
</main>

<script>
    // Asset Name Mapping
    document.getElementById('prodSelectOut').addEventListener('change', function() {
        const selectedOption = this.options[this.selectedIndex];
        document.getElementById('prodNameOut').value = selectedOption.getAttribute('data-name');
    });

    <% if(successFlag) { %>
    Swal.fire({
        icon: 'success',
        title: '<span class="italic uppercase tracking-tighter">DISPATCH SYNCED</span>',
        text: 'Stock removal protocol executed successfully.',
        confirmButtonColor: '#f59e0b',
        background: '#ffffff',
        customClass: { popup: 'rounded-[3rem] p-10' }
    });
    <% } %>

    <% if(!errorMsg.isEmpty()) { %>
    Swal.fire({
        icon: 'error',
        title: '<span class="italic uppercase tracking-tighter">PROTOCOL HALTED</span>',
        text: '<%= errorMsg %>',
        confirmButtonColor: '#ef4444',
        background: '#ffffff',
        customClass: { popup: 'rounded-[3rem] p-10' }
    });
    <% } %>
</script>
</body>
</html>