<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  String uri = request.getRequestURI();
  String currentPage = uri.substring(uri.lastIndexOf("/") + 1);
  String username = (session.getAttribute("username") != null) ? (String) session.getAttribute("username") : "Partner Node";
%>

<style>
  /* Floating Indicator အတွက် Style */
  .nav-indicator-emerald {
    position: absolute;
    left: 0;
    width: 4px;
    height: 0%;
    background: #10b981; /* Emerald-500 */
    box-shadow: 0 0 15px #10b981;
    transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    border-radius: 0 10px 10px 0;
  }
  .group:hover .nav-indicator-emerald { height: 40%; top: 30%; }
  .active-link .nav-indicator-emerald { height: 60%; top: 20%; }

  .sidebar-glass-dark {
    background: rgba(2, 6, 23, 0.98);
    backdrop-filter: blur(12px);
  }
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

<aside id="sidebar" class="w-80 sidebar-glass-dark min-h-screen p-8 flex flex-col border-r border-emerald-950/30 shadow-[25px_0_80px_rgba(0,0,0,0.7)] z-[100] fixed left-0 top-0 overflow-y-auto no-print">
  <%-- Logo Section --%>
  <div class="mb-16 px-4 relative">
    <div class="flex items-center gap-5 group cursor-pointer" onclick="location.href='supplier_dashboard.jsp'">
      <div class="relative">
        <div class="absolute -inset-2 bg-gradient-to-tr from-emerald-500 to-teal-600 rounded-2xl blur-md opacity-20 group-hover:opacity-50 transition duration-500"></div>
        <div class="relative w-12 h-12 bg-[#020617] border border-emerald-500/30 rounded-2xl flex items-center justify-center shadow-2xl transition-all duration-500 group-hover:rotate-12">
          <i class="fas fa-leaf text-transparent bg-clip-text bg-gradient-to-tr from-emerald-400 to-teal-500 text-xl"></i>
        </div>
      </div>
      <div>
        <h1 class="text-white font-black italic tracking-tighter text-2xl leading-none uppercase">SUPPLY<span class="text-emerald-500">NODE</span></h1>
        <p class="text-emerald-400/50 text-[7px] font-black uppercase tracking-[0.6em] mt-1 italic">Partner Interface</p>
      </div>
    </div>
  </div>

  <%-- Navigation Hub --%>
  <nav class="flex-1 space-y-3">
    <p class="text-[8px] font-black text-slate-700 uppercase tracking-[0.5em] mb-8 ml-4 mt-4">Fulfillment Core</p>

    <%-- 1. Global Overview --%>
    <div class="relative group <%= (currentPage.equals("supplier_dashboard.jsp")) ? "active-link" : "" %>">
      <div class="nav-indicator-emerald"></div>
      <a href="supplier_dashboard.jsp"
         class="flex items-center gap-5 px-8 py-4 rounded-2xl transition-all duration-500
             <%= (currentPage.equals("supplier_dashboard.jsp")) ? "text-white bg-emerald-500/10" : "text-slate-500 hover:text-emerald-300" %>">
        <i class="fas fa-chart-line text-sm transition-transform group-hover:scale-110"></i>
        <span class="font-black text-[9px] uppercase tracking-[0.25em]">Dashboard</span>
      </a>
    </div>

    <%-- 2. Supply Requests --%>
    <div class="relative group <%= (currentPage.equals("supplier_orders.jsp")) ? "active-link" : "" %>">
      <div class="nav-indicator-emerald"></div>
      <a href="supplier_orders.jsp"
         class="flex items-center gap-5 px-8 py-4 rounded-2xl transition-all duration-500
             <%= (currentPage.equals("supplier_orders.jsp")) ? "text-white bg-emerald-500/10" : "text-slate-500 hover:text-emerald-300" %>">
        <i class="fas fa-truck-ramp-box text-sm transition-transform group-hover:scale-110"></i>
        <span class="font-black text-[9px] uppercase tracking-[0.25em]">Incoming Orders</span>
      </a>
    </div>

    <%-- 3. Stock Monitor --%>
    <div class="relative group <%= (currentPage.equals("supplier_stock.jsp")) ? "active-link" : "" %>">
      <div class="nav-indicator-emerald"></div>
      <a href="supplier_stock.jsp"
         class="flex items-center gap-5 px-8 py-4 rounded-2xl transition-all duration-500
             <%= (currentPage.equals("supplier_stock.jsp")) ? "text-white bg-emerald-500/10" : "text-slate-500 hover:text-emerald-300" %>">
        <i class="fas fa-boxes-stacked text-sm transition-transform group-hover:scale-110"></i>
        <span class="font-black text-[9px] uppercase tracking-[0.25em]">Inventory Desk</span>
      </a>
    </div>

    <div class="h-[1px] bg-emerald-900/20 my-10 mx-6"></div>

  </nav>

  <%-- Partner Profile & Logout --%>
  <div class="mt-auto px-2">
    <div class="bg-gradient-to-b from-emerald-950/20 to-transparent rounded-[2.5rem] p-6 border border-white/5 relative overflow-hidden group">
      <div class="absolute -right-10 -bottom-10 w-32 h-32 bg-emerald-500 blur-[80px] opacity-10 group-hover:opacity-20 transition-opacity"></div>

      <div class="flex items-center gap-4 mb-8">
        <div class="relative">
          <div class="w-11 h-11 rounded-full bg-emerald-500/20 border border-emerald-500/40 flex items-center justify-center text-emerald-400">
            <i class="fas fa-handshake text-lg"></i>
          </div>
          <div class="absolute -bottom-1 -right-1 w-3.5 h-3.5 bg-emerald-500 border-2 border-[#020617] rounded-full shadow-[0_0_10px_#10b981]"></div>
        </div>
        <div class="overflow-hidden">
          <p class="text-white font-black text-[11px] truncate uppercase tracking-tighter italic"><%= username %></p>
          <p class="text-emerald-500 text-[7px] font-black uppercase tracking-[0.3em] mt-0.5 italic">Verified Partner</p>
        </div>
      </div>

      <a href="../logout.jsp" class="flex items-center justify-center gap-3 w-full bg-rose-500/10 hover:bg-rose-500 text-rose-500 hover:text-white py-4 rounded-2xl font-black text-[8px] uppercase tracking-[0.4em] transition-all duration-500 group/logout">
        <i class="fas fa-power-off text-[10px] group-hover/logout:rotate-90 transition-transform"></i>
        <span>Disconnect Node</span>
      </a>
    </div>
  </div>
</aside>