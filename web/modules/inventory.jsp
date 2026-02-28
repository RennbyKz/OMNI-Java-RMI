<%@ page import="java.rmi.Naming, common.InventoryService, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  if (session.getAttribute("user_id") == null) {
    response.sendRedirect("../login.jsp"); return;
  }
  request.setAttribute("active_page", "inventory");

  String search = request.getParameter("search") != null ? request.getParameter("search") : "";
  String branchFilter = request.getParameter("branch_filter") != null ? request.getParameter("branch_filter") : "";

  InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");
  List<String[]> products = service.getInventory();
  List<String[]> branches = service.getBranches();
  List<String[]> suppliers = service.getSuppliers();
%>

<!DOCTYPE html>
<html lang="my">
<head>
  <meta charset="UTF-8">
  <title>လက်ကျန်စာရင်း | OMNI CORE</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

  <style>
    @import url('https://fonts.googleapis.com/css2?family=Pyidaungsu:wght@400;700&display=swap');
    body { background-color: #F6F4F0; font-family: 'Pyidaungsu', sans-serif; }
    .main-content { margin-left: 310px; transition: all 0.4s ease; }
    @media (max-width: 1024px) { .main-content { margin-left: 0; } }

    .glass-card { background: rgba(255, 255, 255, 0.7); backdrop-filter: blur(12px); border: 1px solid rgba(77, 161, 169, 0.1); }
    .btn-enterprise { background-color: #2E5077; transition: all 0.3s ease; }
    .btn-enterprise:hover { background-color: #4DA1A9; transform: translateY(-2px); box-shadow: 0 10px 25px -5px rgba(46, 80, 119, 0.3); }

    .inventory-table thead th { background-color: #F6F4F0; color: #4DA1A9; }
    .custom-scrollbar::-webkit-scrollbar { width: 6px; }
    .custom-scrollbar::-webkit-scrollbar-thumb { background: #4DA1A9; border-radius: 10px; }
  </style>
</head>
<body class="antialiased text-[#2E5077]">

<jsp:include page="/templates/sidebar_admin.jsp" />

<main class="main-content min-h-screen p-6 lg:p-10 relative">
  <jsp:include page="/includes/header.jsp" />

  <%-- Page Title Section --%>
  <div class="flex flex-col md:flex-row justify-between items-start md:items-end my-10 gap-6 no-print px-4">
    <div>
      <div class="flex items-center gap-3 mt-3">
        <span class="w-12 h-1 bg-[#79D7BE] rounded-full"></span>
        <p class="text-[#4DA1A9] text-[10px] font-bold uppercase tracking-[0.3em]">ပစ္စည်းလက်ကျန် စာရင်းဇယား</p>
      </div>
      <h2 class="text-3xl font-black text-[#2E5077] mt-2 italic uppercase">လက်ကျန် <span class="text-[#4DA1A9]">စာရင်း</span></h2>
    </div>
    <button onclick="openAddModal()" class="btn-enterprise text-white px-10 py-5 rounded-2xl font-bold shadow-xl flex items-center gap-3 active:scale-95 duration-300 text-[11px] uppercase tracking-widest">
      <i class="fas fa-plus-circle text-[#79D7BE]"></i> ပစ္စည်းအသစ်သွင်းရန်
    </button>
  </div>

  <%-- Filter Bar --%>
  <div class="mb-10 no-print glass-card p-6 rounded-[2.5rem] shadow-sm flex flex-wrap gap-4 items-center mx-4">
    <form action="inventory.jsp" method="GET" class="flex flex-wrap gap-4 flex-1">
      <div class="relative flex-1 min-w-[280px]">
        <i class="fas fa-search absolute left-5 top-1/2 -translate-y-1/2 text-[#4DA1A9]"></i>
        <input type="text" name="search" value="<%= search %>" placeholder="ပစ္စည်းအမည်ဖြင့် ရှာဖွေရန်..." class="w-full pl-14 pr-4 py-4 bg-[#F6F4F0] border-none rounded-2xl font-bold outline-none focus:ring-2 focus:ring-[#79D7BE] text-[#2E5077]">
      </div>
      <select name="branch_filter" class="p-4 bg-[#F6F4F0] border-none rounded-2xl font-bold text-[#4DA1A9] min-w-[200px] outline-none cursor-pointer">
        <option value="">ဌာနခွဲအားလုံး</option>
        <% if(branches != null) { for(String[] b : branches) { %>
        <option value="<%= b[1] %>" <%= branchFilter.equals(b[1]) ? "selected" : "" %>><%= b[1] %></option>
        <% } } %>
      </select>
      <button type="submit" class="bg-[#2E5077] text-white px-10 py-4 rounded-2xl font-bold uppercase text-[10px] tracking-widest hover:bg-[#4DA1A9] transition shadow-md">စစ်ထုတ်မည်</button>
    </form>
  </div>

  <%-- Data Table --%>
  <div class="bg-white rounded-[3.5rem] shadow-sm overflow-hidden border border-[#4DA1A9]/10 mx-4">
    <div class="overflow-x-auto">
      <table class="w-full text-left inventory-table border-collapse">
        <thead>
        <tr class="text-[10px] uppercase font-bold tracking-wider">
          <th class="p-10">ပစ္စည်းအမည်နှင့် အချက်အလက်</th>
          <th class="p-10 text-center">လက်ကျန်</th>
          <th class="p-10 text-right">ယူနစ်ဈေးနှုန်း</th>
          <th class="p-10 text-right no-print">လုပ်ဆောင်ချက်</th>
        </tr>
        </thead>
        <tbody class="divide-y divide-[#F6F4F0]">
        <% if (products != null) {
          for(String[] p : products) {
            if(!search.isEmpty() && !p[1].toLowerCase().contains(search.toLowerCase())) continue;
            if(!branchFilter.isEmpty() && !p[4].equals(branchFilter)) continue;
        %>
        <tr class="hover:bg-[#F6F4F0]/50 transition-all group">
          <td class="p-8 border-none">
            <div class="flex items-center gap-6">
              <div class="relative">
                <img src="<%= request.getContextPath() %>/<%= (p.length > 9 && p[9] != null) ? p[9] : "assets/uploads/products/default.png" %>"
                     class="w-16 h-16 rounded-[1.5rem] object-cover shadow-lg border-2 border-white group-hover:rotate-3 transition duration-500">
              </div>
              <div>
                <span class="text-lg font-bold text-[#2E5077] block leading-none mb-2 uppercase tracking-tight group-hover:text-[#4DA1A9] transition-colors"><%= p[1] %></span>
                <div class="flex items-center gap-2">
                  <i class="fas fa-location-dot text-[#79D7BE] text-[10px]"></i>
                  <span class="text-[10px] font-bold text-slate-400 uppercase tracking-widest"><%= (p.length > 7 ? p[7] : "အထွေထွေ") %> • ဌာနခွဲ: <%= p[4] %></span>
                </div>
              </div>
            </div>
          </td>
          <td class="p-8 text-center border-none">
            <span class="text-3xl font-black italic <%= Integer.parseInt(p[2]) < 10 ? "text-rose-500 animate-pulse" : "text-[#2E5077]" %>"><%= p[2] %></span>
            <p class="text-[9px] font-bold text-slate-300 uppercase mt-1">လက်ရှိအရေအတွက်</p>
          </td>
          <td class="p-8 text-right border-none">
            <span class="font-black text-[#4DA1A9] text-2xl tracking-tighter"><%= p[3] %></span>
            <span class="text-[10px] text-slate-300 ml-1 font-bold">ကျပ်</span>
          </td>
          <td class="p-8 text-right space-x-2 no-print border-none">
            <button onclick='openEditModal({ id: "<%= p[0] %>", name: "<%= p[1] %>", qty: "<%= p[2] %>", price: "<%= p[3] %>", bId: "<%= p[5] %>", sId: "<%= p[6] %>", cat: "<%= (p.length > 7 ? p[7] : "") %>", meta: `<%= (p.length > 8 ? p[8] : "{}") %>` })'
                    class="w-11 h-11 bg-[#F6F4F0] text-[#2E5077] rounded-xl hover:bg-[#79D7BE] hover:shadow-lg transition-all" title="ပြင်ဆင်ရန်">
              <i class="fas fa-sliders"></i>
            </button>
            <button onclick="confirmDelete('<%= p[0] %>', '<%= p[1] %>')"
                    class="w-11 h-11 bg-rose-50 text-rose-400 rounded-xl hover:bg-rose-500 hover:text-white transition-all shadow-sm" title="ဖျက်ရန်">
              <i class="fas fa-trash-alt"></i>
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

<%-- Asset Modal --%>
<div id="assetModal" class="hidden fixed inset-0 bg-[#2E5077]/40 backdrop-blur-md z-[5000] flex items-center justify-center p-4 no-print">
  <div class="bg-white rounded-[3.5rem] w-full max-w-2xl shadow-2xl overflow-hidden border border-white/20">
    <div class="bg-[#2E5077] p-8 text-white flex justify-between items-center">
      <div class="flex items-center gap-3">
        <i class="fas fa-cube text-[#79D7BE] text-xl"></i>
        <h3 id="modalTitle" class="text-xl font-bold uppercase tracking-widest">ပစ္စည်းမှတ်ပုံတင်ခြင်း</h3>
      </div>
      <button onclick="closeModal()" class="text-white/40 hover:text-[#79D7BE] text-3xl transition-colors">&times;</button>
    </div>

    <form id="assetForm" action="../InventoryActionServlet" method="POST" enctype="multipart/form-data" class="p-10 grid grid-cols-2 gap-6 bg-[#F6F4F0]/30 max-h-[75vh] overflow-y-auto custom-scrollbar">
      <input type="hidden" name="item_id" id="form_product_id">
      <input type="hidden" name="metadata" id="form_metadata">

      <div class="col-span-2">
        <label class="block text-[10px] font-bold text-[#4DA1A9] uppercase tracking-widest mb-2 ml-2">ပစ္စည်းအမည်</label>
        <input type="text" name="item_name" id="form_product_name" required class="w-full p-4 bg-white border-2 border-transparent rounded-2xl font-bold text-[#2E5077] focus:border-[#79D7BE] outline-none shadow-sm transition-all" placeholder="ဥပမာ - ကွန်ပျူတာ">
      </div>

      <div class="col-span-1">
        <label class="block text-[10px] font-bold text-[#4DA1A9] uppercase tracking-widest mb-2 ml-2">အမျိုးအစား</label>
        <select name="category" id="form_category" class="w-full p-4 bg-white border-none rounded-2xl font-bold text-[#2E5077] outline-none shadow-sm">
          <option value="IT ASSETS">အိုင်တီပစ္စည်း</option>
          <option value="ELECTRONICS">လျှပ်စစ်ပစ္စည်း</option>
          <option value="OFFICE SUPPLY">ရုံးသုံးပစ္စည်း</option>
          <option value="NETWORKING">ကွန်ရက်ပစ္စည်း</option>
          <option value="GENERAL">အထွေထွေ</option>
        </select>
      </div>

      <div class="col-span-1">
        <label class="block text-[10px] font-bold text-[#4DA1A9] uppercase tracking-widest mb-2 ml-2">တံဆိပ် (Brand)</label>
        <input type="text" id="meta_brand" class="w-full p-4 bg-white border-none rounded-2xl font-bold shadow-sm outline-none" placeholder="ဥပမာ - Samsung">
      </div>

      <div class="col-span-1">
        <label class="block text-[10px] font-bold text-[#4DA1A9] uppercase tracking-widest mb-2 ml-2">အရေအတွက်</label>
        <input type="number" name="quantity" id="form_quantity" required class="w-full p-4 bg-white border-none rounded-2xl font-bold shadow-sm outline-none">
      </div>

      <div class="col-span-1">
        <label class="block text-[10px] font-bold text-[#4DA1A9] uppercase tracking-widest mb-2 ml-2">ယူနစ်ဈေးနှုန်း (ကျပ်)</label>
        <input type="number" step="0.01" name="price" id="form_price" required class="w-full p-4 bg-white border-none rounded-2xl font-bold shadow-sm outline-none">
      </div>

      <div class="col-span-2">
        <label class="block text-[10px] font-bold text-[#4DA1A9] uppercase tracking-widest mb-2 ml-2">ပစ္စည်းဓာတ်ပုံ</label>
        <div class="bg-white p-4 rounded-2xl border-2 border-dashed border-[#79D7BE]/30 text-center">
          <input type="file" name="image_file" accept="image/*" class="text-[10px] text-slate-400 font-bold">
        </div>
      </div>

      <div class="col-span-1">
        <label class="block text-[10px] font-bold text-[#4DA1A9] uppercase tracking-widest mb-2 ml-2">ထားရှိမည့် ဌာနခွဲ</label>
        <select name="branch_id" id="form_branch_id" required class="w-full p-4 bg-white border-none rounded-2xl font-bold text-slate-600 outline-none">
          <% for(String[] b : branches) { %>
          <option value="<%= b[0] %>"><%= b[1] %></option>
          <% } %>
        </select>
      </div>

      <div class="col-span-1">
        <label class="block text-[10px] font-bold text-[#4DA1A9] uppercase tracking-widest mb-2 ml-2">ကုန်သွင်းသူ</label>
        <select name="supplier_id" id="form_supplier_id" required class="w-full p-4 bg-white border-none rounded-2xl font-bold text-slate-600 outline-none">
          <% for(String[] s : suppliers) { %>
          <option value="<%= s[0] %>"><%= s[1] %></option>
          <% } %>
        </select>
      </div>

      <button type="submit" class="col-span-2 mt-4 bg-[#2E5077] text-white p-6 rounded-[2rem] font-bold uppercase tracking-widest hover:bg-[#4DA1A9] transition shadow-xl active:scale-95 duration-300">ဒေတာသိမ်းဆည်းမည်</button>
    </form>
  </div>
</div>

<script>
  document.getElementById('assetForm').onsubmit = function() {
    const meta = {
      "brand": document.getElementById('meta_brand').value || "Local",
      "unit": "pcs",
      "threshold": 5
    };
    document.getElementById('form_metadata').value = JSON.stringify(meta);
  };

  function openAddModal() {
    document.getElementById('modalTitle').innerText = "ပစ္စည်းအသစ် မှတ်ပုံတင်ရန်";
    document.getElementById('assetForm').reset();
    document.getElementById('form_product_id').value = "";
    document.getElementById('assetModal').classList.remove('hidden');
  }

  function openEditModal(d) {
    document.getElementById('modalTitle').innerText = "အချက်အလက် ပြင်ဆင်ရန်";
    document.getElementById('form_product_id').value = d.id;
    document.getElementById('form_product_name').value = d.name;
    document.getElementById('form_quantity').value = d.qty;
    document.getElementById('form_price').value = d.price.replace(/,/g, '');
    document.getElementById('form_category').value = d.cat ? d.cat.toUpperCase() : "GENERAL";
    document.getElementById('form_branch_id').value = d.bId;
    document.getElementById('form_supplier_id').value = d.sId;
    try {
      const m = JSON.parse(d.meta || '{}');
      document.getElementById('meta_brand').value = m.brand || "";
    } catch(e) {}
    document.getElementById('assetModal').classList.remove('hidden');
  }

  function closeModal() { document.getElementById('assetModal').classList.add('hidden'); }

  function confirmDelete(id, name) {
    Swal.fire({
      title: '<span class="font-bold">ပစ္စည်းစာရင်း ဖျက်လိုပါသလား?</span>',
      text: name + " ကို စာရင်းမှ အပြီးတိုင် ဖျက်ပစ်ပါမည်။",
      icon: 'warning',
      showCancelButton: true,
      confirmButtonColor: '#ef4444',
      cancelButtonColor: '#cbd5e1',
      confirmButtonText: 'ဟုတ်ကဲ့၊ ဖျက်ပါမည်',
      cancelButtonText: 'မလုပ်တော့ပါ',
      background: '#F6F4F0',
      customClass: { popup: 'rounded-[2rem]' }
    }).then((result) => {
      if (result.isConfirmed) window.location.href = "../InventoryActionServlet?delete_id=" + id;
    });
  }

  const urlParams = new URLSearchParams(window.location.search);
  if (urlParams.get('msg') === 'success') {
    Swal.fire({ icon: 'success', title: 'အောင်မြင်ပါသည်', text: 'စာရင်းဇယားများကို အဆင့်မြှင့်တင်ပြီးပါပြီ။', confirmButtonColor: '#2E5077' });
  }
</script>
</body>
</html>