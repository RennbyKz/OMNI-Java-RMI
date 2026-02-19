<%@ page import="java.rmi.Naming, common.InventoryService, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session.getAttribute("user_id") == null || !"Admin".equals(session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp");
        return;
    }

    Map<String, Object> stats = new HashMap<>();
    List<String[]> recentSync = new ArrayList<>();
    boolean isServerOnline = false;

    try {
        InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");
        stats = service.getDashboardStats();
        recentSync = service.getRecentInventorySync();
        isServerOnline = true;
    } catch (Exception e) {
        isServerOnline = false;
    }

    request.setAttribute("active_page", "dashboard");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>OMNI CORE | Command Center</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <style>
        body { background-color: #F6F4F0; scroll-behavior: smooth; }

        /* Sidebar Space for Desktop */
        .main-content { margin-left: 290px; transition: all 0.4s ease; }
        @media (max-width: 1024px) { .main-content { margin-left: 0; } }

        /* Card Hover Effects */
        .stat-card {
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            border: 1px solid rgba(77, 161, 169, 0.1);
        }
        .stat-card:hover {
            transform: translateY(-8px) scale(1.01);
            box-shadow: 0 25px 50px -12px rgba(46, 80, 119, 0.15);
            border-color: #79D7BE;
        }

        /* Glassmorphism for Tables */
        .glass-table {
            background: rgba(255, 255, 255, 0.8);
            backdrop-filter: blur(10px);
        }

        /* Print Settings */
        @media print {
            .no-print { display: none !important; }
            .main-content { margin-left: 0 !important; padding: 0 !important; }
        }

        /* Custom Animation */
        @keyframes slow-spin {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }
        .animate-slow-spin { animation: slow-spin 8s linear infinite; }
    </style>
</head>
<body class="font-sans antialiased text-[#2E5077]">

<jsp:include page="/templates/sidebar_admin.jsp" />

<main class="main-content min-h-screen p-6 lg:p-10 pt-4">
    <jsp:include page="/includes/header.jsp" />

    <div class="mt-8">

        <div class="mb-10 flex flex-col md:flex-row justify-between items-start md:items-center gap-6 no-print">
            <div class="animate-in">
            </div>
            <button onclick="window.print()" class="bg-[#2E5077] text-white px-8 py-4 rounded-2xl font-bold shadow-lg hover:bg-[#4DA1A9] transition-all tracking-widest uppercase text-[10px] flex items-center gap-3 group">
                <i class="fas fa-file-invoice group-hover:rotate-12 transition-transform"></i> System Export
            </button>
        </div>

        <div class="grid grid-cols-2 lg:grid-cols-4 gap-5 mb-10 no-print">
            <a href="manage_requests.jsp" class="p-6 bg-white rounded-[2rem] border border-slate-100 flex items-center gap-4 hover:border-[#79D7BE] hover:bg-[#F6F4F0]/50 transition group">
                <div class="w-12 h-12 bg-[#F6F4F0] text-[#2E5077] rounded-xl flex items-center justify-center group-hover:bg-[#2E5077] group-hover:text-[#79D7BE] transition duration-500 shadow-sm">
                    <i class="fas fa-clipboard-check"></i>
                </div>
                <span class="text-[9px] font-black uppercase tracking-widest text-slate-500">Approvals</span>
            </a>
            <a href="manage_users.jsp" class="p-6 bg-white rounded-[2rem] border border-slate-100 flex items-center gap-4 hover:border-[#79D7BE] hover:bg-[#F6F4F0]/50 transition group">
                <div class="w-12 h-12 bg-[#F6F4F0] text-[#2E5077] rounded-xl flex items-center justify-center group-hover:bg-[#2E5077] group-hover:text-[#79D7BE] transition duration-500 shadow-sm">
                    <i class="fas fa-user-shield"></i>
                </div>
                <span class="text-[9px] font-black uppercase tracking-widest text-slate-500">User Hub</span>
            </a>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-10">
            <div class="stat-card relative overflow-hidden rounded-[2.5rem] p-8 bg-[#2E5077] text-white shadow-xl">
                <i class="fa fa-vault absolute -right-4 -bottom-4 text-8xl opacity-10"></i>
                <p class="text-[9px] font-bold uppercase tracking-[0.2em] text-[#79D7BE] mb-4">Total Assets Value</p>
                <h3 class="text-3xl font-black italic tracking-tighter"><%= stats.getOrDefault("totalValuation", "0") %> <span class="text-[10px] not-italic text-[#4DA1A9]">MMK</span></h3>
                <p class="text-[8px] text-slate-400 font-bold mt-4 uppercase tracking-widest">Global Node Valuation</p>
            </div>

            <div class="stat-card relative overflow-hidden rounded-[2.5rem] p-8 bg-white shadow-sm">
                <i class="fa fa-network-wired absolute -right-4 -bottom-4 text-8xl text-[#F6F4F0]"></i>
                <p class="text-[9px] font-bold uppercase tracking-[0.2em] text-slate-400 mb-4">Branch Health</p>
                <h3 class="text-4xl font-black text-[#2E5077] italic leading-none"><%= stats.getOrDefault("activeBranches", "0") %></h3>
                <div class="flex items-center gap-2 mt-4">
                    <span class="w-1.5 h-1.5 bg-[#79D7BE] rounded-full animate-pulse"></span>
                    <span class="text-[8px] text-[#4DA1A9] font-bold uppercase tracking-widest">Online Nodes</span>
                </div>
            </div>

            <div class="stat-card relative overflow-hidden rounded-[2.5rem] p-8 bg-white shadow-sm border-l-4 border-rose-400">
                <i class="fa fa-triangle-exclamation absolute -right-4 -bottom-4 text-8xl text-rose-50 opacity-60"></i>
                <p class="text-[9px] font-bold uppercase tracking-[0.2em] text-slate-400 mb-4">Stock Alerts</p>
                <h3 class="text-4xl font-black text-rose-500 italic leading-none"><%= stats.getOrDefault("lowStock", "0") %></h3>
                <p class="text-[8px] text-rose-300 font-bold mt-4 uppercase tracking-widest italic">Action Required</p>
            </div>

            <div class="stat-card relative overflow-hidden rounded-[2.5rem] p-8 bg-white shadow-sm">
                <i class="fa fa-server absolute -right-4 -bottom-4 text-8xl <%= isServerOnline ? "text-[#79D7BE]" : "text-rose-100" %> opacity-20"></i>
                <p class="text-[9px] font-bold uppercase tracking-[0.2em] text-slate-400 mb-4">Node Connection</p>
                <h3 class="text-2xl font-black <%= isServerOnline ? "text-[#4DA1A9]" : "text-rose-500" %> italic uppercase leading-none">
                    <%= isServerOnline ? "Established" : "Disconnected" %>
                </h3>
                <div class="flex items-center gap-2 mt-4 bg-[#F6F4F0] w-max px-3 py-1 rounded-full border border-[#4DA1A9]/10">
                    <div class="w-1.5 h-1.5 rounded-full <%= isServerOnline ? "bg-[#79D7BE] animate-pulse" : "bg-rose-500" %>"></div>
                    <span class="text-[8px] text-[#2E5077] font-bold uppercase tracking-widest">Encrypted RMI Sync</span>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-[3rem] shadow-xl shadow-slate-200/50 overflow-hidden border border-slate-100 mb-10">
            <div class="p-8 border-b border-[#F6F4F0] flex justify-between items-center">
                <div>
                    <h3 class="text-xl font-black text-[#2E5077] italic uppercase tracking-tighter">Recent Sync logs</h3>
                    <p class="text-[9px] font-bold text-[#4DA1A9] uppercase tracking-[0.2em] mt-1">Node Synchronization Stream</p>
                </div>
                <div class="w-10 h-10 bg-[#F6F4F0] rounded-xl flex items-center justify-center">
                    <i class="fas fa-rotate text-[#79D7BE] animate-slow-spin"></i>
                </div>
            </div>

            <div class="overflow-x-auto">
                <table class="w-full text-left">
                    <thead class="bg-[#F6F4F0] text-[#4DA1A9] text-[10px] uppercase font-black tracking-widest">
                    <tr>
                        <th class="px-10 py-6">Node Identifier</th>
                        <th class="px-10 py-6 text-center">Batch Quantity</th>
                        <th class="px-10 py-6 text-right">Node Valuation</th>
                    </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-50">
                    <% if (recentSync != null && !recentSync.isEmpty()) {
                        for (String[] p : recentSync) { %>
                    <tr class="hover:bg-[#F6F4F0]/50 transition-colors duration-300 group">
                        <td class="px-10 py-6">
                            <span class="font-bold text-[#2E5077] block text-base uppercase tracking-tight group-hover:text-[#4DA1A9] transition-colors"><%= p[0] %></span>
                            <div class="flex items-center gap-2 mt-1">
                                <i class="fas fa-fingerprint text-[8px] text-slate-300"></i>
                                <span class="text-[8px] text-slate-400 font-bold uppercase tracking-widest italic">Identity Verified Node</span>
                            </div>
                        </td>
                        <td class="px-10 py-6 text-center">
                            <span class="font-black text-[#2E5077] text-2xl italic tracking-tighter"><%= p[1] %></span>
                        </td>
                        <td class="px-10 py-6 text-right font-black text-[#4DA1A9] text-xl italic tracking-tighter">
                            <%= p[2] %> <span class="text-[9px] text-slate-300 ml-1">MMK</span>
                        </td>
                    </tr>
                    <% } } else { %>
                    <tr>
                        <td colspan="3" class="p-20 text-center">
                            <i class="fas fa-database text-slate-100 text-6xl mb-4"></i>
                            <p class="font-bold text-slate-300 italic uppercase tracking-widest text-xs">No active synchronization detected</p>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <jsp:include page="/includes/footer.jsp" />
</main>

<script>
    // Success Toast Notification
    document.addEventListener('DOMContentLoaded', function() {
        const urlParams = new URLSearchParams(window.location.search);
        const message = urlParams.get('msg');

        if (message === 'login_success') {
            const Toast = Swal.mixin({
                toast: true,
                position: 'top-end',
                showConfirmButton: false,
                timer: 3000,
                timerProgressBar: true,
                background: '#2E5077',
                color: '#F6F4F0'
            });

            Toast.fire({
                icon: 'success',
                title: 'Node Authorization: Connection Secure'
            });

            window.history.replaceState({}, document.title, window.location.pathname);
        }
    });
</script>

</body>
</html>