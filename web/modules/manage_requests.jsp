<%@ page import="java.rmi.Naming, common.InventoryService, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  if (session.getAttribute("user_id") == null || !"Admin".equals(session.getAttribute("role"))) {
    response.sendRedirect("../login.jsp");
    return;
  }
  request.setAttribute("active_page", "manage_requests");

  InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");

  // ⭐ ClassCastException Fix: Object.toString() ကို သုံး၍ ယူပါ
  Object userIdObj = session.getAttribute("user_id");
  String adminUsername = (userIdObj != null) ? userIdObj.toString() : "";

  // ⭐ Approve Handlers (ကျန်တာတွေက အရင်အတိုင်းပါပဲ)
  String approveIdParam = request.getParameter("approve_id");
  if (approveIdParam != null && !approveIdParam.trim().isEmpty()) {
    try {
      int rid = Integer.parseInt(approveIdParam);
      if(service.approveRequest(rid, adminUsername)) {
        response.sendRedirect("manage_requests.jsp?msg=approved"); return;
      }
    } catch (NumberFormatException e) { }
  }

  // ⭐ Reject Handlers
  if (request.getParameter("reject_request") != null) {
    String ridStr = request.getParameter("request_id");
    if (ridStr != null && !ridStr.trim().isEmpty()) {
      try {
        int rid = Integer.parseInt(ridStr);
        String remark = request.getParameter("remark");
        if(service.rejectRequest(rid, remark, adminUsername)) {
          response.sendRedirect("manage_requests.jsp?msg=rejected"); return;
        }
      } catch (NumberFormatException e) { }
    }
  }

  List<String[]> requests = service.getPendingRequests();
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Manage Requests | OMNI CORE</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
  <style>
    body { background-color: #F6F4F0; scroll-behavior: smooth; }
    .main-content { margin-left: 290px; transition: all 0.4s ease; }
    @media (max-width: 1024px) { .main-content { margin-left: 0; } }
    .glass-card { background: rgba(255, 255, 255, 0.7); backdrop-filter: blur(12px); border: 1px solid rgba(77, 161, 169, 0.15); }
    .btn-approve { background-color: #79D7BE; color: #2E5077; transition: all 0.3s ease; }
    .btn-approve:hover { background-color: #2E5077; color: #79D7BE; transform: translateY(-2px); }
    .btn-reject { background-color: #F6F4F0; color: #f87171; border: 1px solid rgba(248, 113, 113, 0.2); transition: all 0.3s ease; }
    .btn-reject:hover { background-color: #f87171; color: white; transform: translateY(-2px); }
    .search-input:focus { ring: 2px; ring-color: #79D7BE; border-color: #79D7BE; }
  </style>
</head>
<body class="font-sans text-[#2E5077] antialiased">

<jsp:include page="/templates/sidebar_admin.jsp" />

<main class="main-content min-h-screen p-6 lg:p-10 relative">
  <jsp:include page="/includes/header.jsp" />

  <%-- Page Title & Counter --%>
  <div class="flex flex-col md:flex-row justify-between items-start md:items-end my-10 gap-6 px-4">
    <div>
      <div class="flex items-center gap-3 mt-3">
        <span class="w-10 h-1 bg-[#79D7BE] rounded-full"></span>
        <p class="text-[#4DA1A9] text-[10px] font-bold uppercase tracking-[0.3em]">Incoming Requests</p>
      </div>
    </div>
    <div class="glass-card px-8 py-4 rounded-[2rem] shadow-sm flex items-center gap-4">
      <div class="text-right border-r border-[#4DA1A9]/20 pr-4">
        <span class="text-[8px] font-black text-slate-400 uppercase tracking-widest block">Queue Status</span>
        <span class="text-xs font-black text-[#79D7BE] uppercase italic">Real-time Sync</span>
      </div>
      <span class="text-3xl font-black text-[#2E5077] italic tracking-tighter" id="requestCount"><%= (requests != null) ? requests.size() : 0 %></span>
    </div>
  </div>

  <%-- Quick Search Bar --%>
  <div class="px-4 mb-6">
    <div class="glass-card p-4 rounded-3xl flex items-center gap-4 max-w-md">
      <i class="fas fa-search text-[#4DA1A9] ml-2"></i>
      <input type="text" id="tableSearch" placeholder="Search by asset or node..."
             class="bg-transparent border-none outline-none text-sm font-bold w-full placeholder-[#4DA1A9]/50"
             onkeyup="filterTable()">
    </div>
  </div>

  <%-- Request Table --%>
  <div class="px-4 mb-10">
    <div class="bg-white rounded-[3rem] shadow-xl shadow-slate-200/50 overflow-hidden border border-[#4DA1A9]/10">
      <table class="w-full text-left" id="requestTable">
        <thead class="bg-[#F6F4F0] text-[#4DA1A9] text-[9px] uppercase font-black tracking-[0.2em] border-b border-[#4DA1A9]/10">
        <tr>
          <th class="px-10 py-6">Asset Intelligence</th>
          <th class="px-10 py-6">Originating Node</th>
          <th class="px-10 py-6 text-center">Batch Qty</th>
          <th class="px-10 py-6 text-right">Decision Commands</th>
        </tr>
        </thead>
        <tbody class="divide-y divide-[#F6F4F0]">
        <% if(requests == null || requests.isEmpty()) { %>
        <tr>
          <td colspan="4" class="p-24 text-center">
            <div class="flex flex-col items-center opacity-30">
              <i class="fas fa-inbox text-6xl mb-4"></i>
              <p class="font-bold italic tracking-widest uppercase text-xs">Queue Clear: No pending handshakes.</p>
            </div>
          </td>
        </tr>
        <% } else {
          for(String[] r : requests) { %>
        <tr class="hover:bg-[#F6F4F0]/50 transition-all group request-row">
          <td class="px-10 py-8">
            <div class="flex items-center gap-4">
              <div class="w-12 h-12 bg-[#F6F4F0] rounded-xl flex items-center justify-center text-[#2E5077] group-hover:bg-[#2E5077] group-hover:text-[#79D7BE] transition-all">
                <i class="fas fa-file-signature"></i>
              </div>
              <div>
                <span class="font-black text-[#2E5077] block text-base uppercase italic leading-none mb-2 asset-name"><%= r[1] %></span>
                <span class="text-[8px] text-[#4DA1A9] font-bold uppercase tracking-widest">Received: <%= r[3] %></span>
              </div>
            </div>
          </td>
          <td class="px-10 py-8">
            <div class="flex items-center gap-2">
              <i class="fas fa-network-wired text-[#79D7BE] text-[10px]"></i>
              <span class="font-bold text-slate-500 text-[11px] uppercase italic tracking-tight node-name"><%= r[4] %></span>
            </div>
          </td>
          <td class="px-10 py-8 text-center">
            <span class="font-black text-2xl text-[#2E5077] italic tracking-tighter"><%= r[2] %></span>
            <p class="text-[8px] font-bold text-slate-300 uppercase">Units</p>
          </td>
          <td class="px-10 py-8 text-right space-x-3 whitespace-nowrap">
            <button onclick="confirmApprove(<%= r[0] %>, '<%= r[1].replace("'", "\\'") %>')"
                    class="btn-approve px-8 py-3 rounded-xl font-black text-[9px] uppercase tracking-widest shadow-lg active:scale-95">
              Approve
            </button>
            <button onclick="openRejectModal(<%= r[0] %>)"
                    class="btn-reject px-8 py-3 rounded-xl font-black text-[9px] uppercase tracking-widest active:scale-95">
              Reject
            </button>
          </td>
        </tr>
        <% } } %>
        </tbody>
      </table>
    </div>
  </div>

  <jsp:include page="/includes/footer.jsp" />
</main>

<%-- Rejection Modal --%>
<div id="rejectModal" class="hidden fixed inset-0 bg-[#2E5077]/40 backdrop-blur-md z-[5000] flex items-center justify-center p-4">
  <div class="bg-white rounded-[3rem] w-full max-w-md shadow-2xl overflow-hidden border border-white/20">
    <div class="bg-[#2E5077] p-8 text-white flex justify-between items-center">
      <div class="flex items-center gap-3">
        <i class="fas fa-ban text-rose-400"></i>
        <h3 class="text-xl font-black uppercase tracking-widest">Transaction Rejection</h3>
      </div>
      <button onclick="closeModal()" class="text-white/40 hover:text-rose-400 text-3xl transition-colors">&times;</button>
    </div>
    <form action="manage_requests.jsp" method="POST" class="p-10 bg-[#F6F4F0]/30">
      <input type="hidden" name="request_id" id="reject_id">
      <div class="mb-6">
        <label class="block text-[9px] font-black text-[#4DA1A9] uppercase tracking-widest mb-3 ml-2">Internal Remarks (Reason)</label>
        <textarea name="remark" placeholder="Identify the core issue for rejection..." required
                  class="w-full p-6 bg-white border-none rounded-[2rem] outline-none h-40 font-bold text-xs text-[#2E5077] shadow-sm focus:ring-2 focus:ring-rose-400/50 resize-none"></textarea>
      </div>
      <div class="flex flex-col gap-3">
        <button type="submit" name="reject_request" class="w-full bg-[#2E5077] text-white p-5 rounded-2xl font-black uppercase tracking-widest text-[10px] hover:bg-rose-500 transition-all shadow-xl active:scale-95">Confirm Rejection</button>
        <button type="button" onclick="closeModal()" class="w-full text-slate-400 font-bold uppercase text-[8px] tracking-[0.2em] py-2 hover:text-slate-600 transition-colors">Abort Action</button>
      </div>
    </form>
  </div>
</div>



<script>
  // 🔍 Client-side Table Filter
  function filterTable() {
    const input = document.getElementById("tableSearch");
    const filter = input.value.toUpperCase();
    const rows = document.getElementsByClassName("request-row");
    let visibleCount = 0;

    for (let i = 0; i < rows.length; i++) {
      const asset = rows[i].getElementsByClassName("asset-name")[0].innerText;
      const node = rows[i].getElementsByClassName("node-name")[0].innerText;
      if (asset.toUpperCase().indexOf(filter) > -1 || node.toUpperCase().indexOf(filter) > -1) {
        rows[i].style.display = "";
        visibleCount++;
      } else {
        rows[i].style.display = "none";
      }
    }
    document.getElementById("requestCount").innerText = visibleCount;
  }

  // 🔔 Toast/Alert Handler
  const params = new URLSearchParams(window.location.search);
  if(params.has('msg')) {
    const m = params.get('msg');
    Swal.fire({
      icon: 'success',
      title: m === 'approved' ? 'HANDSHAKE VERIFIED' : 'TRANSACTION REJECTED',
      text: 'The transaction registry has been successfully synchronized.',
      confirmButtonColor: '#2E5077',
      background: '#F6F4F0'
    });
    window.history.replaceState({}, document.title, window.location.pathname);
  }

  function confirmApprove(id, name) {
    Swal.fire({
      title: 'AUTHORIZE TRANSFER?',
      text: `Establish secure release protocol for ${name}?`,
      icon: 'question',
      showCancelButton: true,
      confirmButtonColor: '#79D7BE',
      confirmButtonText: 'CONFIRM RELEASE',
      cancelButtonText: 'CANCEL',
      background: '#F6F4F0'
    }).then((res) => {
      if (res.isConfirmed) window.location.href = `manage_requests.jsp?approve_id=` + id;
    });
  }

  function openRejectModal(id) {
    document.getElementById('reject_id').value = id;
    document.getElementById('rejectModal').classList.remove('hidden');
  }
  function closeModal() { document.getElementById('rejectModal').classList.add('hidden'); }
</script>
</body>
</html>