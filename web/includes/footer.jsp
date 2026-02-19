<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.time.Year" %>

<footer class="mt-12 pb-10 px-6 no-print">
  <div class="bg-[#2E5077] rounded-[2.5rem] px-10 py-8 border border-white/10 shadow-2xl flex flex-col md:flex-row justify-between items-center gap-8 text-white/90">

    <div class="flex items-center gap-5">
      <div class="w-12 h-12 bg-[#79D7BE] rounded-2xl flex items-center justify-center text-[#2E5077] shadow-lg shadow-black/20 rotate-3 transition-transform hover:rotate-0 duration-500 cursor-pointer">
        <i class="fas fa-truck-ramp-box text-xl"></i>
      </div>
      <div>
        <p class="text-xs font-black uppercase tracking-tighter italic">Omni Inventory</p>
        <p class="text-[9px] text-white/40 font-bold uppercase tracking-[0.2em] leading-none mt-1">
          &copy; <%= Year.now().getValue() %> Integrated Supply Chain Solution
        </p>
      </div>
    </div>

    <div class="flex items-center gap-12">
      <div class="flex flex-col items-center">
        <p class="text-[8px] font-black text-white/30 uppercase tracking-[0.3em] mb-2">Sync Status</p>
        <div class="flex items-center gap-2 bg-white/5 px-3 py-1 rounded-full border border-white/10">
          <span class="w-1.5 h-1.5 bg-[#79D7BE] rounded-full animate-pulse"></span>
          <span class="text-[9px] font-black text-[#79D7BE] uppercase tracking-widest">Live Syncing</span>
        </div>
      </div>

      <div class="hidden sm:flex flex-col items-end">
        <p class="text-[8px] font-black text-white/30 uppercase tracking-[0.3em] mb-2">Access Point</p>
        <div class="flex items-center gap-2">
          <i class="fas fa-location-crosshairs text-[#4DA1A9] text-[10px]"></i>
          <span class="text-[10px] font-black text-white uppercase italic tracking-tight">
                <%= session.getAttribute("branch") != null ? session.getAttribute("branch") : "Central Hub Terminal" %>
            </span>
        </div>
      </div>
    </div>

    <div class="hidden lg:block text-right">
      <p class="text-[8px] font-black text-white/30 uppercase tracking-[0.3em] mb-2">Environment</p>
      <p class="text-[10px] font-black text-[#79D7BE] uppercase italic">Production Mode</p>
    </div>

  </div>
</footer>