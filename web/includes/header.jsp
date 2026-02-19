<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.LocalDate" %>
<%
  // Page Detection
  String uri = request.getRequestURI();
  String currentPage = uri.substring(uri.lastIndexOf("/") + 1);
  boolean isIndexPage = currentPage.equals("index.jsp") || currentPage.equals("login.jsp");

  LocalDate today = LocalDate.now();
  DateTimeFormatter formatter = DateTimeFormatter.ofPattern("EEE, dd MMM yyyy");
%>

<header class="sticky top-0 z-50 w-full no-print pt-0 px-6">
  <div class="flex justify-between items-center bg-white/80 backdrop-blur-2xl rounded-[2.5rem] px-8 py-5 shadow-[0_10px_40px_-15px_rgba(46,80,119,0.1)] border border-[#4DA1A9]/20">

    <button onclick="toggleSidebar()" class="lg:hidden p-4 rounded-2xl bg-[#F6F4F0] text-[#2E5077] hover:bg-[#79D7BE]/20 transition active:scale-90">
      <i class="fa fa-bars"></i>
    </button>

    <div class="flex items-center gap-8">
      <div class="hidden sm:flex items-center gap-4 border-r border-[#F6F4F0] pr-8">
        <div class="flex items-center gap-3.5">
          <div class="relative group cursor-pointer">
            <div class="w-14 h-14 rounded-2xl flex items-center justify-center shadow-lg
                        group-hover:rotate-[-6deg] transition-all duration-500 relative z-10
                        ring-4 ring-[#79D7BE]/20 group-hover:ring-[#79D7BE]/40">

              <img src="<%= request.getContextPath() %>/omni_logo.png" alt="Logo">
            </div>
            <div class="absolute -inset-1 bg-[#4DA1A9] rounded-2xl blur opacity-20 group-hover:opacity-40 transition duration-500"></div>
          </div>

          <div class="flex flex-col">
            <div class="flex items-center gap-2">
              <h1 class="text-xl font-black text-[#2E5077] tracking-tighter uppercase italic leading-none">
                OMNI <span class="text-[#4DA1A9]">INVENTORY</span>
              </h1>
            </div>
            <span class="text-[8px] font-bold text-[#79D7BE] uppercase tracking-[0.4em] mt-1 leading-none">Supply Chain Terminal</span>
          </div>
        </div>
      </div>

      <div class="hidden md:flex items-center gap-6">
        <div class="flex items-center gap-3 bg-[#F6F4F0] px-5 py-2.5 rounded-2xl border border-[#4DA1A9]/10">
          <span class="w-2 h-2 bg-[#79D7BE] rounded-full animate-pulse shadow-[0_0_8px_#79D7BE]"></span>
          <p id="headerClock" class="text-[12px] font-black uppercase tracking-widest text-[#2E5077] font-mono"></p>
        </div>
        <div class="flex items-center gap-2 text-[#4DA1A9]">
          <i class="far fa-calendar-check text-[10px]"></i>
          <p class="text-[10px] font-black uppercase tracking-widest leading-none">
            <%= today.format(formatter) %>
          </p>
        </div>
      </div>
    </div>

    <% if (!isIndexPage) { %>
    <div class="flex items-center gap-3">
      <a href="notifications.jsp" class="relative group">
        <div class="w-11 h-11 bg-[#F6F4F0] rounded-2xl flex items-center justify-center text-[#2E5077] group-hover:bg-[#79D7BE] group-hover:text-white transition-all duration-300">
          <i class="fas fa-bell text-sm"></i>
        </div>
        <span class="absolute top-2 right-2 w-2.5 h-2.5 bg-red-500 rounded-full border-2 border-white animate-bounce"></span>
      </a>
      <a href="settings.jsp" class="group relative">
        <div class="w-11 h-11 bg-[#F6F4F0] rounded-2xl flex items-center justify-center text-[#2E5077] group-hover:bg-[#4DA1A9] group-hover:text-white transition-all duration-300">
          <i class="fas fa-cog text-sm group-hover:rotate-90 transition-transform duration-500"></i>
        </div>
        <%-- Tooltip on Hover --%>
        <span class="absolute -bottom-10 left-1/2 -translate-x-1/2 bg-[#2E5077] text-white text-[8px] font-black uppercase tracking-widest px-2 py-1 rounded opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none">
            Preferences
        </span>
      </a>

      <div class="flex items-center gap-4 pl-4 border-l border-[#F6F4F0] ml-2">
        <div class="hidden lg:block text-right">
          <p class="text-[10px] font-black text-[#2E5077] uppercase leading-none mb-1 tracking-tight">
            <%= session.getAttribute("username") != null ? session.getAttribute("username") : "Operator" %>
          </p>
          <span class="text-[7px] font-black text-white bg-[#4DA1A9] px-2 py-0.5 rounded-md uppercase tracking-widest italic">
            <%= session.getAttribute("role") != null ? session.getAttribute("role") : "Access Node" %>
          </span>
        </div>

        <div class="relative group cursor-pointer">
          <img src="https://ui-avatars.com/api/?name=<%= session.getAttribute("username") %>&background=2E5077&color=79D7BE&bold=true"
               class="w-11 h-11 rounded-2xl shadow-md border-2 border-white group-hover:scale-105 transition-transform duration-300">
          <div class="absolute -bottom-1 -right-1 w-3.5 h-3.5 bg-[#79D7BE] border-2 border-white rounded-full shadow-sm"></div>
        </div>

        <a href="../logout.jsp" class="w-10 h-10 flex items-center justify-center text-slate-300 hover:text-red-500 hover:bg-red-50 rounded-xl transition-all duration-300" title="Logout">
          <i class="fas fa-sign-out-alt text-sm"></i>
        </a>
      </div>
    </div>
    <% } %>
  </div>
</header>

<script>
  function toggleSidebar() {
    const sidebar = document.getElementById('sidebar');
    sidebar.classList.toggle('show');
  }

  document.addEventListener('mousedown', function(event) {
    const sidebar = document.getElementById('sidebar');
    const toggleBtn = document.querySelector('[onclick="toggleSidebar()"]');

    if (sidebar.classList.contains('show') &&
            !sidebar.contains(event.target) &&
            !toggleBtn.contains(event.target)) {
      sidebar.classList.remove('show');
    }
  });

  function updateHeaderClock() {
    const clockElement = document.getElementById('headerClock');
    if(clockElement) {
      clockElement.innerText = new Date().toLocaleTimeString('en-US', {
        hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true
      });
    }
  }
  setInterval(updateHeaderClock, 1000);
  updateHeaderClock();
</script>