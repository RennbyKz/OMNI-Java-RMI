<%@ page import="java.rmi.Naming, common.InventoryService, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // ၁။ လုံခြုံရေး စစ်ဆေးခြင်း (Admin မဟုတ်လျှင် Login သို့ ပြန်ပို့မည်)
    if (session.getAttribute("user_id") == null || !"Admin".equals(session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp");
        return;
    }

    Map<String, Object> stats = new HashMap<>();
    List<String[]> recentSync = new ArrayList<>();
    boolean isServerOnline = false;

    try {
        // ၂။ RMI စနစ်ဖြင့် ဗဟို Server မှ ဒေတာဆွဲယူခြင်း
        InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");
        stats = service.getDashboardStats();
        recentSync = service.getRecentInventorySync();
        isServerOnline = true;
    } catch (Exception e) {
        isServerOnline = false;
    }

    // Sidebar မှာ Dashboard ကို Active ဖြစ်နေစေရန်
    request.setAttribute("active_page", "dashboard");
%>
<!DOCTYPE html>
<html lang="my">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ပင်မထိန်းချုပ်ရေးဗဟို | OMNI CORE</title>

    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <style>
        @import url('https://fonts.googleapis.com/css2?family=Pyidaungsu:wght@400;700&display=swap');

        body {
            font-family: 'Pyidaungsu', sans-serif;
            background-color: #F6F4F0;
            scroll-behavior: smooth;
        }

        /* Sidebar နေရာလွတ် ချန်ထားခြင်း */
        .main-content {
            margin-left: 290px;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        }

        @media (max-width: 1024px) {
            .main-content { margin-left: 0; }
        }

        /* ကတ်များ၏ Hover Effect */
        .stat-card {
            transition: all 0.4s ease;
            border: 1px solid rgba(77, 161, 169, 0.1);
        }
        .stat-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 25px 50px -12px rgba(46, 80, 119, 0.15);
            border-color: #79D7BE;
        }

        .animate-slow-spin { animation: spin 8s linear infinite; }
        @keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }

        @media print {
            .no-print { display: none !important; }
            .main-content { margin-left: 0 !important; padding: 0 !important; }
        }
    </style>
</head>
<body class="antialiased text-[#2E5077]">

<%-- Sidebar Include --%>
<jsp:include page="/templates/sidebar_admin.jsp" />

<main class="main-content min-h-screen p-6 lg:p-10 pt-4">
    <%-- Header Include --%>
    <jsp:include page="/includes/header.jsp" />

    <div class="mt-8">

        <div class="mb-10 flex flex-col md:flex-row justify-between items-start md:items-center gap-6 no-print">
            <div>
                <h2 class="text-3xl font-black tracking-tighter uppercase italic leading-none text-[#2E5077]">
                    ပင်မ <span class="text-[#4DA1A9]">ထိန်းချုပ်ရေးဗဟို</span>
                </h2>
                <p class="text-[10px] font-bold text-[#79D7BE] uppercase tracking-[0.4em] mt-2">Executive Overview</p>
            </div>
            <button onclick="window.print()" class="bg-[#2E5077] text-white px-8 py-4 rounded-2xl font-bold shadow-lg hover:bg-[#4DA1A9] transition-all tracking-widest uppercase text-[10px] flex items-center gap-3 group">
                <i class="fas fa-file-invoice group-hover:rotate-12 transition-transform"></i> အစီရင်ခံစာ ထုတ်ယူရန်
            </button>
        </div>

        <div class="grid grid-cols-2 lg:grid-cols-4 gap-5 mb-10 no-print">
            <a href="manage_requests.jsp" class="p-6 bg-white rounded-[2rem] border border-slate-100 flex items-center gap-4 hover:border-[#79D7BE] hover:bg-[#F6F4F0]/50 transition group">
                <div class="w-12 h-12 bg-[#F6F4F0] text-[#2E5077] rounded-xl flex items-center justify-center group-hover:bg-[#2E5077] group-hover:text-[#79D7BE] transition duration-500 shadow-sm">
                    <i class="fas fa-clipboard-check"></i>
                </div>
                <span class="text-[11px] font-bold uppercase tracking-wider text-slate-500">ခွင့်ပြုချက်များ</span>
            </a>
            <a href="manage_users.jsp" class="p-6 bg-white rounded-[2rem] border border-slate-100 flex items-center gap-4 hover:border-[#79D7BE] hover:bg-[#F6F4F0]/50 transition group">
                <div class="w-12 h-12 bg-[#F6F4F0] text-[#2E5077] rounded-xl flex items-center justify-center group-hover:bg-[#2E5077] group-hover:text-[#79D7BE] transition duration-500 shadow-sm">
                    <i class="fas fa-user-shield"></i>
                </div>
                <span class="text-[11px] font-bold uppercase tracking-wider text-slate-500">အသုံးပြုသူများ</span>
            </a>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-10">
            <div class="stat-card relative overflow-hidden rounded-[2.5rem] p-8 bg-[#2E5077] text-white shadow-xl">
                <i class="fa fa-vault absolute -right-4 -bottom-4 text-8xl opacity-10"></i>
                <p class="text-[10px] font-bold uppercase tracking-[0.2em] text-[#79D7BE] mb-4">စုစုပေါင်း ပစ္စည်းတန်ဖိုး</p>
                <h3 class="text-3xl font-black italic tracking-tighter"><%= stats.getOrDefault("totalValuation", "0") %> <span class="text-[10px] not-italic text-[#4DA1A9]">ကျပ်</span></h3>
                <p class="text-[8px] text-slate-400 font-bold mt-4 uppercase tracking-widest">စနစ်အတွင်းရှိ ပစ္စည်းစုစုပေါင်း တန်ဖိုး</p>
            </div>

            <div class="stat-card relative overflow-hidden rounded-[2.5rem] p-8 bg-white shadow-sm border border-slate-100">
                <i class="fa fa-network-wired absolute -right-4 -bottom-4 text-8xl text-[#F6F4F0]"></i>
                <p class="text-[10px] font-bold uppercase tracking-[0.2em] text-slate-400 mb-4">ဌာနခွဲများ အခြေအနေ</p>
                <h3 class="text-4xl font-black text-[#2E5077] italic leading-none"><%= stats.getOrDefault("activeBranches", "0") %></h3>
                <div class="flex items-center gap-2 mt-4">
                    <span class="w-1.5 h-1.5 bg-[#79D7BE] rounded-full animate-pulse"></span>
                    <span class="text-[8px] text-[#4DA1A9] font-bold uppercase tracking-widest">ချိတ်ဆက်ထားသည့် ဆိုင်ခွဲများ</span>
                </div>
            </div>

            <div class="stat-card relative overflow-hidden rounded-[2.5rem] p-8 bg-white shadow-sm border-l-4 border-rose-400">
                <i class="fa fa-triangle-exclamation absolute -right-4 -bottom-4 text-8xl text-rose-50 opacity-60"></i>
                <p class="text-[10px] font-bold uppercase tracking-[0.2em] text-slate-400 mb-4">လက်ကျန် အချက်ပေးချက်</p>
                <h3 class="text-4xl font-black text-rose-500 italic leading-none"><%= stats.getOrDefault("lowStock", "0") %></h3>
                <p class="text-[8px] text-rose-400 font-bold mt-4 uppercase tracking-widest italic">ချက်ချင်း ဖြည့်တင်းရန် လိုအပ်သည်</p>
            </div>

            <div class="stat-card relative overflow-hidden rounded-[2.5rem] p-8 bg-white shadow-sm">
                <i class="fa fa-server absolute -right-4 -bottom-4 text-8xl <%= isServerOnline ? "text-[#79D7BE]" : "text-rose-100" %> opacity-20"></i>
                <p class="text-[10px] font-bold uppercase tracking-[0.2em] text-slate-400 mb-4">ဗဟိုစနစ် ချိတ်ဆက်မှု</p>
                <h3 class="text-2xl font-black <%= isServerOnline ? "text-[#4DA1A9]" : "text-rose-500" %> italic uppercase leading-none">
                    <%= isServerOnline ? "ချိတ်ဆက်မှု အဆင်ပြေသည်" : "ချိတ်ဆက်မှု ပြတ်တောက်နေသည်" %>
                </h3>
                <div class="flex items-center gap-2 mt-4 bg-[#F6F4F0] w-max px-3 py-1 rounded-full border border-[#4DA1A9]/10">
                    <div class="w-1.5 h-1.5 rounded-full <%= isServerOnline ? "bg-[#79D7BE] animate-pulse" : "bg-rose-500" %>"></div>
                    <span class="text-[8px] text-[#2E5077] font-bold uppercase tracking-widest">လုံခြုံရေးစနစ်ဖြင့် ချိတ်ဆက်ထားသည်</span>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-[3rem] shadow-xl shadow-slate-200/50 overflow-hidden border border-slate-100 mb-10">
            <div class="p-8 border-b border-[#F6F4F0] flex justify-between items-center">
                <div>
                    <h3 class="text-xl font-black text-[#2E5077] italic uppercase tracking-tighter">နောက်ဆုံး လုပ်ဆောင်မှု မှတ်တမ်းများ</h3>
                    <p class="text-[10px] font-bold text-[#4DA1A9] uppercase tracking-[0.2em] mt-1">ဌာနခွဲများအလိုက် ဒေတာ နောက်ဆုံးဝင်ရောက်မှု</p>
                </div>
                <div class="w-10 h-10 bg-[#F6F4F0] rounded-xl flex items-center justify-center">
                    <i class="fas fa-rotate text-[#79D7BE] animate-slow-spin"></i>
                </div>
            </div>

            <div class="overflow-x-auto">
                <table class="w-full text-left">
                    <thead class="bg-[#F6F4F0] text-[#4DA1A9] text-[10px] uppercase font-black tracking-widest">
                    <tr>
                        <th class="px-10 py-6">ဌာနခွဲ/ပစ္စည်း အမည်</th>
                        <th class="px-10 py-6 text-center">အရေအတွက်</th>
                        <th class="px-10 py-6 text-right">စုစုပေါင်းတန်ဖိုး</th>
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
                                <span class="text-[8px] text-slate-400 font-bold uppercase tracking-widest italic">စနစ်မှ အတည်ပြုပြီး</span>
                            </div>
                        </td>
                        <td class="px-10 py-6 text-center">
                            <span class="font-black text-[#2E5077] text-2xl italic tracking-tighter"><%= p[1] %></span>
                        </td>
                        <td class="px-10 py-6 text-right font-black text-[#4DA1A9] text-xl italic tracking-tighter">
                            <%= p[2] %> <span class="text-[9px] text-slate-300 ml-1">ကျပ်</span>
                        </td>
                    </tr>
                    <% } } else { %>
                    <tr>
                        <td colspan="3" class="p-20 text-center">
                            <i class="fas fa-database text-slate-100 text-6xl mb-4"></i>
                            <p class="font-bold text-slate-300 italic uppercase tracking-widest text-xs">လက်ရှိတွင် မည်သည့် လုပ်ဆောင်ချက်မှ မရှိသေးပါ</p>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <%-- Footer Include --%>
    <jsp:include page="/includes/footer.jsp" />
</main>

<script>
    // ဝင်ရောက်မှု အောင်မြင်သည့်အခါ ပြသသည့် Toast Notification
    document.addEventListener('DOMContentLoaded', function() {
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.get('msg') === 'login_success') {
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
                title: 'စနစ်ချိတ်ဆက်မှု အောင်မြင်ပါသည်'
            });
            window.history.replaceState({}, document.title, window.location.pathname);
        }
    });
</script>

</body>
</html>