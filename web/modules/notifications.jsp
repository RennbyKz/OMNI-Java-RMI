<%@ page import="java.rmi.Naming, common.InventoryService, java.util.*, java.text.SimpleDateFormat" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // ၁။ Security & Session Check
    Object roleObj = session.getAttribute("role");
    if (roleObj == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String role = roleObj.toString().toUpperCase();
    Object branchObj = session.getAttribute("branch_id");
    Object supplierObj = session.getAttribute("supplier_id");

    InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");

    // ၂။ Role အလိုက် Notification များ ရယူခြင်း
    List<Map<String, String>> notifications = new ArrayList<>();
    try {
        if (role.equals("ADMIN") || role.equals("AUDITOR")) {
            notifications = service.getNotificationsForAdmin();
        } else if (role.equals("MANAGER") || role.equals("STOREKEEPER")) {
            if (branchObj != null) {
                notifications = service.getNotificationsForBranch(Integer.parseInt(branchObj.toString()));
            }
        } else if (role.equals("SUPPLIER")) {
            if (supplierObj != null) {
                notifications = service.getNotificationsForSupplier(Integer.parseInt(supplierObj.toString()));
            }
        }
    } catch (Exception e) { e.printStackTrace(); }

    // Role အလိုက် Theme Color သတ်မှတ်ခြင်း
    String themeColor = role.equals("SUPPLIER") ? "emerald" : (role.equals("ADMIN") ? "indigo" : "blue");
    String themeHex = role.equals("SUPPLIER") ? "#10b981" : (role.equals("ADMIN") ? "#6366f1" : "#3b82f6");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Live Notifications | OMNI FLOW</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        body { background-color: #F8FAFC; color: #1E293B; }
        /* Header & Sidebar Space Alignment */
        .main-content { margin-left: 280px; padding-top: 90px; transition: all 0.4s ease; }
        @media (max-width: 1024px) { .main-content { margin-left: 0; } }

        .executive-card { background: white; border: 1px solid rgba(226, 232, 240, 0.8); transition: all 0.3s ease; }
        .executive-card:hover { transform: translateY(-3px); box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.05); }

        .animate-reveal { animation: reveal 0.6s cubic-bezier(0.4, 0, 0.2, 1) forwards; opacity: 0; }
        @keyframes reveal { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
    </style>
</head>
<body class="font-sans antialiased selection:bg-<%= themeColor %>-100 selection:text-<%= themeColor %>-600">

<%-- Dynamic Sidebar Include --%>
<jsp:include page='<%= "/templates/sidebar_" + role.toLowerCase() + ".jsp" %>' />

<main class="main-content min-h-screen p-6 lg:p-12 relative">
    <jsp:include page="/includes/header.jsp" />

    <div class="max-w-6xl mx-auto">
        <%-- 1. Hero Header --%>
        <div class="mb-14 flex flex-col md:flex-row justify-between items-start md:items-end gap-8 animate-reveal">
            <div class="space-y-3">
                <h2 class="text-6xl font-black text-slate-900 tracking-tighter leading-none italic uppercase">
                    Live <span class="text-<%= themeColor %>-600">Alerts</span>
                </h2>
                <div class="flex items-center gap-4">
                    <span class="w-12 h-1 bg-<%= themeColor %>-500 rounded-full"></span>
                    <p class="text-slate-400 text-[10px] font-black uppercase tracking-[0.5em] italic">
                        <%= role %> Node Handshake: Online
                    </p>
                </div>
            </div>

            <div class="bg-white px-10 py-5 rounded-[2.5rem] shadow-sm border border-slate-100 flex items-center gap-5">
                <div class="w-12 h-12 bg-<%= themeColor %>-50 rounded-2xl flex items-center justify-center text-<%= themeColor %>-500">
                    <i class="fas fa-tower-broadcast animate-pulse"></i>
                </div>
                <div>
                    <span class="text-[8px] font-black text-slate-400 uppercase tracking-widest block mb-1">Queue Status</span>
                    <span class="text-3xl font-black text-slate-900 italic tracking-tighter leading-none"><%= notifications.size() %> Signals</span>
                </div>
            </div>
        </div>

        <%-- 2. Notifications Feed --%>
        <div class="space-y-6">
            <% if (notifications.isEmpty()) { %>
            <div class="bg-white p-32 rounded-[4rem] text-center border-2 border-dashed border-slate-100 animate-reveal">
                <div class="w-24 h-24 bg-slate-50 rounded-full flex items-center justify-center mx-auto mb-8">
                    <i class="fas fa-satellite text-slate-200 text-4xl"></i>
                </div>
                <p class="text-slate-300 font-black italic uppercase tracking-[0.5em] text-[10px]">No active transmissions detected in channel</p>
            </div>
            <% } else {
                for (int i = 0; i < notifications.size(); i++) {
                    Map<String, String> n = notifications.get(i);
                    String type = n.get("type");
                    boolean isSystem = "system".equalsIgnoreCase(type);
                    boolean isOrder = "Order".equalsIgnoreCase(type);

                    // Logic based coloring
                    String cardAccent = isSystem ? "#3b82f6" : (isOrder ? "#10b981" : "#f43f5e");
                    String iconBg = isSystem ? "bg-blue-50 text-blue-500" : (isOrder ? "bg-emerald-50 text-emerald-500" : "bg-rose-50 text-rose-500");
                    String badgeStyle = isSystem ? "bg-blue-100 text-blue-600" : (isOrder ? "bg-emerald-100 text-emerald-600" : "bg-rose-100 text-rose-600");
            %>
            <div class="executive-card p-10 rounded-[3.5rem] flex flex-col md:flex-row items-center gap-10 animate-reveal"
                 style="animation-delay: <%= i * 0.1 %>s; border-left: 12px solid <%= cardAccent %>;">

                <div class="w-20 h-20 flex-shrink-0 flex items-center justify-center rounded-[2rem] shadow-inner <%= iconBg %> transition-transform hover:rotate-12 duration-500">
                    <i class="fas <%= isSystem ? "fa-bolt-lightning" : (isOrder ? "fa-box-open" : "fa-shield-halved") %> text-2xl"></i>
                </div>

                <div class="flex-1 text-center md:text-left space-y-3">
                    <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
                        <h4 class="text-2xl font-black text-slate-800 uppercase italic tracking-tighter leading-none">
                            <%= n.get("title") %>
                        </h4>
                        <span class="text-[9px] font-black px-5 py-2 rounded-full uppercase tracking-widest <%= badgeStyle %> border border-current opacity-70">
                             PROTOCOL: <%= n.get("sub") %>
                        </span>
                    </div>

                    <div class="flex flex-wrap items-center justify-center md:justify-start gap-6">
                        <p class="text-slate-400 text-[10px] font-bold uppercase tracking-widest flex items-center gap-2">
                            <i class="far fa-clock text-<%= themeColor %>-400"></i>
                            TIMESTAMP: <%= n.get("date") %>
                        </p>
                        <span class="w-1.5 h-1.5 bg-slate-200 rounded-full hidden md:block"></span>
                        <p class="text-[9px] font-black text-slate-300 uppercase tracking-[0.3em] italic">Sequence Verified</p>
                    </div>
                </div>

                <div class="no-print w-full md:w-auto">
                    <a href="<%= isOrder ? (role.equals("SUPPLIER") ? "supplier_orders.jsp" : "manage_orders.jsp") : (isSystem ? "audit_logs.jsp" : "my_inventory.jsp") %>"
                       class="w-full md:w-16 h-16 rounded-[1.8rem] bg-slate-900 text-white flex items-center justify-center hover:bg-<%= themeColor %>-600 transition-all shadow-xl active:scale-90 group">
                        <i class="fas fa-arrow-right-long group-hover:translate-x-1 transition-transform"></i>
                    </a>
                </div>
            </div>
            <% } } %>
        </div>
    </div>

    <jsp:include page="/includes/footer.jsp" />
</main>



</body>
</html>