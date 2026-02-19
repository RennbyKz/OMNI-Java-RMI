<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // လက်ရှိ File Name ကို ရယူပြီး Active Link သတ်မှတ်ရန်
    String uri = request.getRequestURI();
    String currentPage = uri.substring(uri.lastIndexOf("/") + 1);
%>

<style>
    /* Aside Container ပြင်ဆင်ချက် - Header နှင့် Overlap မဖြစ်စေရန် pt-20 ထည့်သွင်းထားသည် */
    .aside-container {
        width: 280px; height: 100vh; position: fixed;
        left: 0; top: 0; background: #0F172A; /* Slate-900 */
        padding: 85px 14px 24px 14px; /* pt-20 ခန့် နေရာချန်ထားခြင်းဖြစ်သည် */
        display: flex; flex-direction: column;
        box-shadow: 15px 0 50px -10px rgba(0, 0, 0, 0.3);
        z-index: 40; /* Header ၏ z-50 အောက်တွင် ထားရှိသည် */
        transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        border-right: 1px solid rgba(255, 255, 255, 0.05);
    }

    /* Background Animation Icons */
    .flow-icon { position: absolute; color: rgba(99, 102, 241, 0.03); animation: floatY 18s linear infinite; pointer-events: none; }
    .flow-icon.truck { font-size: 5rem; left: -10px; top: 25%; }
    .flow-icon.box { font-size: 4rem; right: -5px; bottom: 20%; animation-delay: 4s; }

    @keyframes floatY { 0%, 100% { transform: translateY(0) rotate(0deg); } 50% { transform: translateY(-20px) rotate(5deg); } }

    /* Navigation Styling */
    .nav-item {
        display: flex; align-items: center; gap: 12px; padding: 0.75rem 1rem;
        margin-bottom: 4px; color: rgba(246, 244, 240, 0.5);
        text-decoration: none !important; border-radius: 1.2rem;
        transition: all 0.3s ease; position: relative; z-index: 2;
    }

    .nav-item.active {
        background: rgba(99, 102, 241, 0.1); color: #818CF8; font-weight: 800;
        border-right: 4px solid #818CF8; border-radius: 1.2rem 0.4rem 0.4rem 1.2rem;
    }

    .nav-item:hover:not(.active) { background: rgba(255, 255, 255, 0.03); transform: translateX(5px); color: #F6F4F0; }

    .icon-square {
        width: 36px; height: 36px; border-radius: 10px;
        display: flex; align-items: center; justify-content: center;
        background: rgba(255, 255, 255, 0.05); transition: all 0.3s ease;
    }

    .nav-item.active .icon-square { background: #818CF8; color: #0F172A !important; }

    .scrollbar-hide::-webkit-scrollbar { display: none; }

    @media (max-width: 1024px) {
        #sidebar {
            left: -100%; /* Mobile မှာ ဘယ်ဘက်အပြင်ကို ပို့ထားမယ် */
            transition: all 0.5s cubic-bezier(0.4, 0, 0.2, 1);
        }
        #sidebar.show {
            left: 0; /* JavaScript က .show ထည့်လိုက်ရင် ပြန်ပေါ်လာမယ် */
        }
    }
</style>

<aside id="sidebar" class="aside-container">
    <i class="fa fa-truck-fast flow-icon truck"></i>
    <i class="fa fa-box-open flow-icon box"></i>

    <%-- Brand Section --%>
    <div class="brand-section flex items-center gap-4 mb-10 px-4 relative z-10">
        <div class="w-10 h-10 bg-indigo-500 rounded-xl flex items-center justify-center shadow-lg group-hover:rotate-12 transition-all">
            <i class="fas fa-shipping-fast text-white text-lg"></i>
        </div>
        <div class="flex flex-col">
            <h3 class="font-black text-sm tracking-tighter text-white uppercase italic leading-none">OMNI <span class="text-indigo-400">LOGI</span></h3>
            <span class="text-[6px] font-bold text-indigo-300/50 uppercase tracking-[0.4em] mt-1 italic">Logistics Node</span>
        </div>
    </div>

    <%-- Navigation Menu --%>
    <nav class="flex-1 space-y-0.5 px-1 overflow-y-auto scrollbar-hide">
        <p class="text-[8px] font-black text-slate-600 uppercase tracking-[0.4em] mb-4 ml-4">Terminal Core</p>

        <a href="storekeeper_dashboard.jsp" class="nav-item <%= currentPage.equals("storekeeper_dashboard.jsp") ? "active" : "" %>">
            <div class="icon-square"><i class="fa fa-th-large text-xs"></i></div>
            <span class="text-[9px] uppercase font-bold tracking-widest">Live Console</span>
        </a>

        <a href="stock_in.jsp" class="nav-item <%= currentPage.equals("stock_in.jsp") ? "active" : "" %>">
            <div class="icon-square"><i class="fa fa-file-import text-xs" style="color:#6EE7B7"></i></div>
            <span class="text-[9px] uppercase font-bold tracking-widest">Inbound</span>
        </a>

        <a href="stock_out.jsp" class="nav-item <%= currentPage.equals("stock_out.jsp") ? "active" : "" %>">
            <div class="icon-square"><i class="fa fa-file-export text-xs" style="color:#FCA5A5"></i></div>
            <span class="text-[9px] uppercase font-bold tracking-widest">Outbound</span>
        </a>

        <a href="my_inventory.jsp" class="nav-item <%= currentPage.equals("my_inventory.jsp") ? "active" : "" %>">
            <div class="icon-square"><i class="fa fa-boxes-stacked text-xs" style="color:#93C5FD"></i></div>
            <span class="text-[9px] uppercase font-bold tracking-widest">Inventory Monitor</span>
        </a>

        <div class="h-[1px] bg-white/5 my-6 mx-4"></div>

        <p class="text-[8px] font-black text-slate-600 uppercase tracking-[0.4em] mb-4 ml-4">Notifications</p>

        <a href="alerts.jsp" class="nav-item <%= currentPage.equals("alerts.jsp") ? "active" : "" %>">
            <div class="icon-square relative">
                <i class="fa fa-bell text-xs"></i>
                <span class="absolute top-2 right-2 w-1.5 h-1.5 bg-red-500 rounded-full animate-pulse border border-slate-900"></span>
            </div>
            <span class="text-[9px] uppercase font-bold tracking-widest">Safety Alerts</span>
        </a>
    </nav>

    <%-- Profile & Logout Area --%>
    <div class="aside-footer mt-4 p-4 bg-white/5 rounded-[1.8rem] flex flex-col gap-4 border border-white/5">
        <div class="flex items-center gap-3">
            <div class="relative">
                <img src="https://ui-avatars.com/api/?name=<%= session.getAttribute("username") %>&background=6366F1&color=fff&bold=true"
                     class="w-8 h-8 rounded-xl border border-white/10">
                <span class="absolute -bottom-1 -right-1 w-2.5 h-2.5 bg-emerald-500 border-2 border-[#0F172A] rounded-full"></span>
            </div>
            <div class="flex flex-col overflow-hidden">
                <span class="text-[9px] font-black text-white uppercase truncate w-24">
                   <%= session.getAttribute("username") != null ? session.getAttribute("username") : "Operator" %>
                </span>
                <span class="text-[6px] text-indigo-400 font-bold uppercase tracking-tighter italic">Storekeeper Node</span>
            </div>
        </div>
        <a href="../logout.jsp" class="flex items-center justify-center gap-2 w-full bg-rose-500/10 hover:bg-rose-500 text-rose-500 hover:text-white py-3 rounded-xl font-black text-[8px] uppercase tracking-widest transition-all duration-300 group">
            <i class="fa fa-power-off group-hover:rotate-90 transition-transform"></i> Terminate Node
        </a>
    </div>
</aside>