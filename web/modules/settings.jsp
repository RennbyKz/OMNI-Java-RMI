<%@ page import="java.rmi.Naming, common.InventoryService, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // ၁။ Security & Session Check
    Object roleObj = session.getAttribute("role");
    if (roleObj == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String role = roleObj.toString().toUpperCase();
    Object uidObj = session.getAttribute("user_id");
    int userId = (uidObj instanceof Integer) ? (int) uidObj : Integer.parseInt(uidObj.toString());

    String msg = "";
    try {
        InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");

        // ၂။ Password Update Logic
        if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("update_security") != null) {
            String currentPass = request.getParameter("current_password");
            String newPass = request.getParameter("new_password");

            boolean success = service.updatePassword(userId, currentPass, newPass, role);
            if (success) {
                msg = "Success: Node authentication synchronized.";
            } else {
                msg = "Error: Invalid legacy credential key.";
            }
        }
    } catch (Exception e) {
        msg = "Error: System synchronization failure.";
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Node Config | OMNI FLOW</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;800&display=swap');

        body { font-family: 'Plus Jakarta Sans', sans-serif; }
        .glass-card { background: rgba(255, 255, 255, 0.8); backdrop-filter: blur(12px); }
        .gradient-border {
            background: linear-gradient(white, white) padding-box,
            linear-gradient(to right, #3b82f6, #10b981) border-box;
            border: 2px solid transparent;
        }
        .shimmer {
            background: linear-gradient(90deg, rgba(255,255,255,0) 0%, rgba(255,255,255,0.1) 50%, rgba(255,255,255,0) 100%);
            background-size: 200% 100%;
            animation: shimmer 3s infinite;
        }
        @keyframes shimmer { 0% { background-position: -200% 0; } 100% { background-position: 200% 0; } }
        .animate-in { animation: slideUp 0.6s cubic-bezier(0.16, 1, 0.3, 1); }
        @keyframes slideUp { from { opacity: 0; transform: translateY(30px); } to { opacity: 1; transform: translateY(0); } }
    </style>
</head>
<body class="bg-[#F8FAFC] flex text-slate-900 antialiased overflow-x-hidden">

<jsp:include page='<%= "/templates/sidebar_" + role.toLowerCase() + ".jsp" %>' />

<main class="flex-1 p-6 md:p-12 ml-0 lg:ml-[320px] transition-all duration-500 min-h-screen">

    <jsp:include page="/includes/header.jsp" />

    <%-- Page Title Section --%>
    <div class="mb-16 flex flex-col md:flex-row md:items-end justify-between gap-6 animate-in">
        <div>
            <span class="text-blue-600 font-black text-[10px] uppercase tracking-[0.5em] mb-4 block">System Maintenance</span>
            <h2 class="text-6xl font-black text-slate-950 tracking-[ -0.05em] uppercase italic leading-none">
                Node <span class="text-blue-600">Settings</span>
            </h2>
        </div>
        <div className="bg-white px-6 py-4 rounded-3xl shadow-sm border border-slate-100 flex items-center gap-4">
            <div className="w-3 h-3 bg-emerald-500 rounded-full animate-pulse"></div>
            <span className="text-[10px] font-black uppercase tracking-widest text-slate-500">Node Status: Optimized</span>
        </div>
    </div>

    <div class="grid xl:grid-cols-5 gap-10 animate-in" style="animation-delay: 0.1s;">

        <%-- Security Node Update Form --%>
        <div class="xl:col-span-3 bg-white p-10 md:p-14 rounded-[4rem] shadow-[0_20px_50px_rgba(0,0,0,0.05)] border border-slate-100 relative overflow-hidden">
            <div class="flex items-center gap-6 mb-12">
                <div class="w-16 h-16 bg-blue-600 text-white rounded-3xl flex items-center justify-center shadow-2xl shadow-blue-200 rotate-3">
                    <i class="fas fa-key-skeleton text-2xl"></i>
                </div>
                <div>
                    <h3 class="text-3xl font-black uppercase italic tracking-tighter text-slate-900">Credential Sync</h3>
                    <p class="text-[10px] font-black text-slate-400 uppercase tracking-widest mt-1">Rotate Node Authentication Security Keys</p>
                </div>
            </div>

            <% if(!msg.isEmpty()) { %>
            <div class="p-6 mb-10 rounded-[2rem] font-bold text-xs flex items-center gap-4 border
                        <%= msg.contains("Success") ? "bg-emerald-50 text-emerald-700 border-emerald-100" : "bg-rose-50 text-rose-700 border-rose-100" %>">
                <div class="w-8 h-8 rounded-full flex items-center justify-center <%= msg.contains("Success") ? "bg-emerald-500" : "bg-rose-500" %> text-white shrink-0">
                    <i class="fas <%= msg.contains("Success") ? "fa-check" : "fa-exclamation" %>"></i>
                </div>
                <%= msg %>
            </div>
            <% } %>

            <form method="POST" class="grid md:grid-cols-2 gap-8">
                <div class="md:col-span-2">
                    <label class="text-[10px] font-black text-slate-500 uppercase tracking-widest block mb-4 ml-4">Legacy Access Key (Current)</label>
                    <div class="relative group">
                        <i class="fas fa-lock absolute left-6 top-1/2 -translate-y-1/2 text-slate-300 group-focus-within:text-blue-500 transition-colors"></i>
                        <input type="password" name="current_password" required placeholder="Required to verify identity"
                               class="w-full pl-14 pr-8 py-6 bg-slate-50 border-2 border-transparent rounded-[2rem] outline-none focus:border-blue-500/20 focus:bg-white focus:ring-4 focus:ring-blue-500/5 transition-all font-bold text-slate-700">
                    </div>
                </div>

                <div class="md:col-span-2">
                    <label class="text-[10px] font-black text-slate-500 uppercase tracking-widest block mb-4 ml-4">Authorized New Key</label>
                    <div class="relative group">
                        <i class="fas fa-shield-bolt absolute left-6 top-1/2 -translate-y-1/2 text-slate-300 group-focus-within:text-emerald-500 transition-colors"></i>
                        <input type="password" name="new_password" required placeholder="Min. 8 characters recommended"
                               class="w-full pl-14 pr-8 py-6 bg-slate-50 border-2 border-transparent rounded-[2rem] outline-none focus:border-emerald-500/20 focus:bg-white focus:ring-4 focus:ring-emerald-500/5 transition-all font-bold text-slate-700">
                    </div>
                </div>

                <div class="md:col-span-2 pt-4">
                    <button type="submit" name="update_security"
                            class="group relative w-full bg-slate-950 text-white py-8 rounded-[2.5rem] font-black uppercase tracking-[0.3em] text-[11px] overflow-hidden transition-all hover:bg-blue-600 active:scale-[0.98] shadow-2xl shadow-blue-100">
                        <span class="relative z-10">Synchronize Security Node</span>
                        <div class="absolute inset-0 shimmer opacity-0 group-hover:opacity-100 transition-opacity"></div>
                    </button>
                </div>
            </form>
        </div>

        <%-- Identity Visual Card --%>
        <div class="xl:col-span-2 bg-slate-950 p-12 rounded-[4rem] shadow-2xl text-white relative overflow-hidden flex flex-col border-t border-slate-800">
            <%-- Tech Pattern Background --%>
            <div class="absolute inset-0 opacity-10" style="background-image: radial-gradient(#3b82f6 1px, transparent 1px); background-size: 24px 24px;"></div>
            <div class="absolute -right-10 -bottom-10 text-[15rem] text-blue-500/10 italic font-black pointer-events-none select-none">NODE</div>

            <div class="relative z-10 flex flex-col h-full">
                <div class="flex justify-between items-start mb-16">
                    <div class="px-4 py-1.5 bg-blue-500/10 border border-blue-500/20 rounded-full">
                        <span class="text-[9px] font-black uppercase tracking-widest text-blue-400">Identity Core v2.0</span>
                    </div>
                    <i class="fas fa-fingerprint text-3xl text-blue-500/50"></i>
                </div>

                <div class="space-y-12 mb-16">
                    <div>
                        <p class="text-[9px] font-black text-slate-500 uppercase tracking-[0.3em] mb-3 italic">System Entity Alias</p>
                        <h4 class="text-5xl font-black tracking-tighter italic uppercase text-white">
                            @<%= session.getAttribute("username") %>
                        </h4>
                    </div>

                    <div class="grid grid-cols-2 gap-6">
                        <div class="p-6 bg-white/5 rounded-[2rem] border border-white/10">
                            <p class="text-[8px] font-black text-blue-400 uppercase tracking-widest mb-2">Clearance</p>
                            <p class="text-lg font-black uppercase italic"><%= role %></p>
                        </div>
                        <div class="p-6 bg-white/5 rounded-[2rem] border border-white/10">
                            <p class="text-[8px] font-black text-emerald-400 uppercase tracking-widest mb-2">Registry</p>
                            <p class="text-lg font-black uppercase italic">ID-<%= userId %></p>
                        </div>
                    </div>

                    <div>
                        <p class="text-[9px] font-black text-slate-500 uppercase tracking-[0.3em] mb-3 italic">Operational Hub</p>
                        <div class="flex items-center gap-3">
                            <div class="w-2 h-2 bg-blue-500 rounded-full shadow-[0_0_10px_#3b82f6]"></div>
                            <p class="text-xl font-bold text-slate-200">
                                <%
                                    if ("SUPPLIER".equals(role)) {
                                        out.print(session.getAttribute("supplier_name") != null ? session.getAttribute("supplier_name") : "Authorized Vendor");
                                    } else {
                                        out.print(session.getAttribute("branch_name") != null ? session.getAttribute("branch_name") : "Global Hub");
                                    }
                                %>
                            </p>
                        </div>
                    </div>
                </div>

                <div class="mt-auto pt-8 border-t border-white/5 flex items-center justify-between">
                    <div class="flex items-center gap-3">
                        <div class="flex h-2.5 w-2.5 relative">
                            <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                            <span class="relative inline-flex rounded-full h-2.5 w-2.5 bg-emerald-500"></span>
                        </div>
                        <span class="text-[9px] font-black uppercase tracking-[0.2em] text-emerald-500">Encryption Active</span>
                    </div>
                    <span class="text-[8px] font-medium text-slate-600">REF: <%= UUID.randomUUID().toString().substring(0,8).toUpperCase() %></span>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="/includes/footer.jsp" />
</main>

<script>
    // Smooth input interaction
    document.querySelectorAll('input').forEach(input => {
        input.addEventListener('focus', () => {
            input.parentElement.parentElement.classList.add('translate-x-2');
        });
        input.addEventListener('blur', () => {
            input.parentElement.parentElement.classList.remove('translate-x-2');
        });
    });
</script>

</body>
</html>