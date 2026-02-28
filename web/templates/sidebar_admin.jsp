<?xml version="1.0" encoding="UTF-8" ?>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String activePage = (String) request.getAttribute("active_page");
    if (activePage == null) activePage = "dashboard";
%>

<style>
    /* မြန်မာစာအတွက် Font ထည့်သွင်းခြင်း */
    @import url('https://fonts.googleapis.com/css2?family=Pyidaungsu:wght@400;700&display=swap');

    .aside-container {
        width: 290px; height: calc(100vh - 40px); position: fixed;
        left: 20px; top: 20px; background: #2E5077; border-radius: 2.5rem;
        padding: 24px 14px; display: flex; flex-direction: column;
        box-shadow: 0 25px 50px -12px rgba(46, 80, 119, 0.4); z-index: 1000;
        transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        border: 1px solid rgba(255, 255, 255, 0.1);
        font-family: 'Pyidaungsu', sans-serif;
    }

    .flow-icon { position: absolute; color: rgba(121, 215, 190, 0.04); animation: floatY 18s linear infinite; pointer-events: none; }
    .flow-icon.truck { font-size: 5rem; left: -10px; top: 15%; }
    .flow-icon.box { font-size: 4rem; right: -5px; bottom: 15%; animation-delay: 4s; }

    @keyframes floatY { 0%, 100% { transform: translateY(0) rotate(0deg); } 50% { transform: translateY(-20px) rotate(5deg); } }

    .nav-item {
        display: flex; align-items: center; gap: 14px; padding: 0.75rem 1rem;
        margin-bottom: 4px; color: rgba(246, 244, 240, 0.7);
        text-decoration: none !important; border-radius: 1.4rem;
        transition: all 0.3s ease; position: relative; z-index: 2;
    }

    .nav-item.active {
        background: #79D7BE; color: #2E5077; font-weight: 800;
        box-shadow: 0 10px 20px -5px rgba(121, 215, 190, 0.3);
    }

    .nav-item:hover:not(.active) { background: rgba(77, 161, 169, 0.15); transform: translateX(8px); color: #F6F4F0; }

    .icon-square {
        width: 38px; height: 38px; border-radius: 12px;
        display: flex; align-items: center; justify-content: center;
        background: rgba(255, 255, 255, 0.08); transition: all 0.3s ease;
    }

    .nav-item.active .icon-square { background: #2E5077; color: #79D7BE !important; }
    .nav-item.active i { color: #79D7BE !important; }

    .scrollbar-hide::-webkit-scrollbar { display: none; }
    @media (max-width: 1024px) { .aside-container { left: -340px; } .aside-container.show { left: 20px; } }
</style>

<aside id="sidebar" class="aside-container" >
    <i class="fa fa-truck-fast flow-icon truck"></i>
    <i class="fa fa-box-open flow-icon box"></i>

    <div class="brand-section flex flex-col items-center mb-8 relative z-10">
        <div class="relative group mb-3">
            <div class="w-14 h-14 bg-[#79D7BE] rounded-2xl flex items-center justify-center shadow-lg group-hover:rotate-6 transition-transform duration-500">
                <i class="fas fa-user-shield text-[#2E5077] text-2xl"></i>
            </div>
            <div class="absolute -inset-1 bg-[#4DA1A9] rounded-2xl blur opacity-20"></div>
        </div>
        <h3 class="font-black text-lg tracking-tighter text-white uppercase italic">Omni <span class="text-[#79D7BE]">Inventory</span></h3>
        <span class="text-[8px] font-bold text-[#4DA1A9] uppercase tracking-[0.4em] mt-1">ကုန်ပစ္စည်းစီမံခန့်ခွဲမှုစနစ်</span>
    </div>

    <nav class="flex-1 space-y-0.5 px-1 overflow-y-auto scrollbar-hide">

        <a href="admin_dashboard.jsp" class="nav-item <%= activePage.equals("dashboard") ? "active" : "" %>">
            <div class="icon-square"><i class="fa fa-th-large" style="color:#79D7BE"></i></div>
            <span class="text-[11px] font-bold tracking-wide">ပင်မစာမျက်နှာ</span>
        </a>

        <a href="inventory.jsp" class="nav-item <%= activePage.equals("inventory") ? "active" : "" %>">
            <div class="icon-square"><i class="fa fa-boxes-stacked" style="color:#FDE68A"></i></div>
            <span class="text-[11px] font-bold tracking-wide">လက်ကျန်စာရင်း</span>
        </a>

        <a href="branch_control.jsp" class="nav-item <%= activePage.equals("branches") ? "active" : "" %>">
            <div class="icon-square"><i class="fa fa-network-wired" style="color:#BFDBFE"></i></div>
            <span class="text-[11px] font-bold tracking-wide">ဌာနခွဲများ</span>
        </a>

        <a href="suppliers.jsp" class="nav-item <%= activePage.equals("suppliers") ? "active" : "" %>">
            <div class="icon-square"><i class="fa fa-truck-ramp-box" style="color:#A5B4FC"></i></div>
            <span class="text-[11px] font-bold tracking-wide">ကုန်သွင်းသူများ</span>
        </a>

        <a href="procurement.jsp" class="nav-item <%= activePage.equals("procurement") ? "active" : "" %>">
            <div class="icon-square"><i class="fa fa-truck-loading" style="color:#F9A8D4"></i></div>
            <span class="text-[11px] font-bold tracking-wide">ဝယ်ယူမှုမှတ်တမ်း</span>
        </a>

        <a href="manage_requests.jsp" class="nav-item <%= activePage.equals("manage_requests") ? "active" : "" %>">
            <div class="icon-square"><i class="fa fa-clipboard-check" style="color:#6EE7B7"></i></div>
            <span class="text-[11px] font-bold tracking-wide">တောင်းဆိုမှုများ</span>
        </a>

        <a href="stock_transfer.jsp" class="nav-item <%= activePage.equals("transfer") ? "active" : "" %>">
            <div class="icon-square"><i class="fa fa-right-left" style="color:#93C5FD"></i></div>
            <span class="text-[11px] font-bold tracking-wide">ပစ္စည်းလွှဲပြောင်းရန်</span>
        </a>

        <a href="order_stock.jsp" class="nav-item <%= activePage.equals("orders") ? "active" : "" %>">
            <div class="icon-square"><i class="fa fa-cart-plus" style="color:#FDBA74"></i></div>
            <span class="text-[11px] font-bold tracking-wide">အမှာစာများ</span>
        </a>

        <a href="shipment_tracking.jsp" class="nav-item <%= activePage.equals("shipments") ? "active" : "" %>">
            <div class="icon-square"><i class="fa fa-shipping-fast" style="color:#79D7BE"></i></div>
            <span class="text-[11px] font-bold tracking-wide">လမ်းကြောင်းစစ်ဆေးရန်</span>
        </a>

        <a href="manage_users.jsp" class="nav-item <%= activePage.equals("manage_users") ? "active" : "" %>">
            <div class="icon-square"><i class="fa fa-user-shield" style="color:#FBCFE8"></i></div>
            <span class="text-[11px] font-bold tracking-wide">အသုံးပြုသူအဆင့်များ</span>
        </a>

        <a href="audit_logs.jsp" class="nav-item <%= activePage.equals("audit_logs") ? "active" : "" %>">
            <div class="icon-square"><i class="fa fa-clipboard-list" style="color:#86EFAC"></i></div>
            <span class="text-[11px] font-bold tracking-wide">စနစ်မှတ်တမ်းများ</span>
        </a>
    </nav>

    <div class="aside-footer mt-4 p-3 bg-white/5 rounded-[1.8rem] flex items-center justify-between border border-white/5 backdrop-blur-md">
        <div class="flex items-center gap-2.5">
            <div class="relative">
                <img src="https://ui-avatars.com/api/?name=<%= session.getAttribute("user_id") %>&background=79D7BE&color=2E5077&bold=true"
                     class="w-8 h-8 rounded-xl border border-white/20">
                <span class="absolute -bottom-1 -right-1 w-2.5 h-2.5 bg-emerald-500 border-2 border-[#2E5077] rounded-full"></span>
            </div>
            <div class="flex flex-col">
                <span class="text-[10px] font-bold text-[#F6F4F0] leading-none truncate w-20">
                   <%= session.getAttribute("username") != null ? session.getAttribute("username") : "အက်ဒမင်" %>
                </span>
                <span class="text-[7px] text-[#79D7BE] font-bold uppercase tracking-widest mt-1">အထူးအသုံးပြုသူ</span>
            </div>
        </div>
        <a href="../logout.jsp" class="w-7 h-7 rounded-lg bg-red-500/10 flex items-center justify-center text-red-400 hover:bg-red-500 hover:text-white transition-all shadow-sm">
            <i class="fa fa-power-off text-[9px]"></i>
        </a>
    </div>
</aside>