<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  String uri = request.getRequestURI();
  String currentPage = uri.substring(uri.lastIndexOf("/") + 1);
  String dispName = (session.getAttribute("username") != null) ? session.getAttribute("username").toString() : "Manager";
%>

<style>
  /* ဆန်းသစ်တဲ့ Navigation Indicator */
  .nav-indicator {
    position: absolute;
    left: 0;
    width: 4px;
    height: 0%;
    background: #6366f1;
    box-shadow: 0 0 15px #6366f1;
    transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    border-radius: 0 10px 10px 0;
  }
  .group:hover .nav-indicator { height: 40%; top: 30%; }
  .active-link .nav-indicator { height: 60%; top: 20%; }

  .sidebar-glass {
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

<aside id="sidebar" class="w-80 sidebar-glass min-h-screen p-8 flex flex-col border-r border-indigo-950/40 shadow-[25px_0_80px_rgba(0,0,0,0.7)] z-[100] fixed left-0 top-0 overflow-y-auto no-print">

  <%-- Logo Section --%>
  <div class="mb-14 px-4 relative">
    <div class="flex items-center gap-5 group cursor-pointer" onclick="location.href='manager_dashboard.jsp'">
      <div class="relative">
        <div class="absolute -inset-2 bg-gradient-to-tr from-indigo-500 to-purple-600 rounded-2xl blur-md opacity-30 group-hover:opacity-60 transition duration-500"></div>
        <div class="relative w-12 h-12 bg-[#020617] border border-indigo-500/30 rounded-2xl flex items-center justify-center shadow-2xl transition-all duration-500 group-hover:rotate-12">
          <i class="fas fa-chess-king text-transparent bg-clip-text bg-gradient-to-tr from-indigo-400 to-purple-500 text-xl"></i>
        </div>
      </div>
      <div>
        <h1 class="text-white font-black italic tracking-tighter text-2xl leading-none uppercase">OM<span class="text-indigo-500">NI</span></h1>
        <p class="text-indigo-400/50 text-[7px] font-black uppercase tracking-[0.6em] mt-1 italic">Intelligence</p>
      </div>
    </div>
  </div>

  <%-- Navigation Hub --%>
  <nav class="flex-1 space-y-2">
    <p class="text-[8px] font-black text-slate-700 uppercase tracking-[0.5em] mb-6 ml-4 mt-4">Main Protocol</p>

    <%-- 1. Dashboard --%>
    <div class="relative group <%= (currentPage.equals("manager_dashboard.jsp")) ? "active-link" : "" %>">
      <div class="nav-indicator"></div>
      <a href="manager_dashboard.jsp"
         class="flex items-center gap-5 px-8 py-4 rounded-2xl transition-all duration-500
             <%= (currentPage.equals("manager_dashboard.jsp")) ? "text-white bg-indigo-500/10" : "text-slate-500 hover:text-indigo-300" %>">
        <i class="fas fa-layer-group text-sm"></i>
        <span class="font-black text-[9px] uppercase tracking-[0.3em]">Dashboard</span>
      </a>
    </div>

    <%-- 2. Procurement --%>
    <div class="relative group <%= (currentPage.equals("stock_requests.jsp")) ? "active-link" : "" %>">
      <div class="nav-indicator"></div>
      <a href="stock_requests.jsp"
         class="flex items-center gap-5 px-8 py-4 rounded-2xl transition-all duration-500
             <%= (currentPage.equals("stock_requests.jsp")) ? "text-white bg-indigo-500/10" : "text-slate-500 hover:text-indigo-300" %>">
        <i class="fas fa-paper-plane text-sm"></i>
        <span class="font-black text-[9px] uppercase tracking-[0.3em]">Procurement</span>
      </a>
    </div>

    <%-- 3. Local Inventory --%>
    <div class="relative group <%= (currentPage.equals("manager_inventory.jsp")) ? "active-link" : "" %>">
      <div class="nav-indicator"></div>
      <a href="manager_inventory.jsp"
         class="flex items-center gap-5 px-8 py-4 rounded-2xl transition-all duration-500
             <%= (currentPage.equals("manager_inventory.jsp")) ? "text-white bg-indigo-500/10" : "text-slate-500 hover:text-indigo-300" %>">
        <i class="fas fa-cubes text-sm"></i>
        <span class="font-black text-[9px] uppercase tracking-[0.3em]">Inventory</span>
      </a>
    </div>

    <div class="h-[1px] bg-indigo-900/20 my-8 mx-6"></div>

    <p class="text-[8px] font-black text-slate-700 uppercase tracking-[0.5em] mb-6 ml-4">Resources</p>

    <%-- 4. Personnel (ဒါလေးပြန်ထည့်ပေးထားပါတယ်) --%>
    <div class="relative group <%= (currentPage.equals("branch_staff.jsp")) ? "active-link" : "" %>">
      <div class="nav-indicator"></div>
      <a href="branch_staff.jsp"
         class="flex items-center gap-5 px-8 py-4 rounded-2xl transition-all duration-500
             <%= (currentPage.equals("branch_staff.jsp")) ? "text-white bg-indigo-500/10" : "text-slate-500 hover:text-indigo-300" %>">
        <i class="fas fa-id-badge text-sm"></i>
        <span class="font-black text-[9px] uppercase tracking-[0.3em]">Personnel</span>
      </a>
    </div>

    <%-- 5. Audit Trails --%>
    <div class="relative group <%= (currentPage.equals("transfer_logs.jsp")) ? "active-link" : "" %>">
      <div class="nav-indicator"></div>
      <a href="transfer_logs.jsp"
         class="flex items-center gap-5 px-8 py-4 rounded-2xl transition-all duration-500
             <%= (currentPage.equals("transfer_logs.jsp")) ? "text-white bg-indigo-500/10" : "text-slate-500 hover:text-indigo-300" %>">
        <i class="fas fa-terminal text-sm"></i>
        <span class="font-black text-[9px] uppercase tracking-[0.3em]">Audit Trails</span>
      </a>
    </div>
  </nav>

  <%-- Profile & Logout --%>
  <div class="mt-auto px-2">
    <div class="bg-gradient-to-b from-indigo-950/20 to-transparent rounded-[2.5rem] p-6 border border-white/5 relative overflow-hidden group">
      <div class="flex items-center gap-4 mb-6">
        <div class="relative">
          <div class="w-11 h-11 rounded-full bg-indigo-500/20 border border-indigo-500/40 flex items-center justify-center text-indigo-400">
            <i class="fas fa-user-tie text-lg"></i>
          </div>
          <div class="absolute -bottom-1 -right-1 w-3.5 h-3.5 bg-emerald-500 border-2 border-[#020617] rounded-full"></div>
        </div>
        <div class="overflow-hidden">
          <p class="text-white font-black text-[11px] truncate uppercase tracking-tighter italic"><%= dispName %></p>
          <p class="text-indigo-500 text-[7px] font-black uppercase tracking-[0.2em] mt-0.5">Verified Manager</p>
        </div>
      </div>

      <a href="../logout.jsp" class="flex items-center justify-center gap-3 w-full bg-[#ef4444]/10 hover:bg-[#ef4444] text-[#ef4444] hover:text-white py-4 rounded-2xl font-black text-[8px] uppercase tracking-[0.4em] transition-all duration-500 group/logout">
        <i class="fas fa-power-off text-[10px] group-hover/logout:rotate-90 transition-transform"></i>
        <span>Exit Node</span>
      </a>
    </div>
  </div>
</aside>