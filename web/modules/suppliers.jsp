<%@ page import="java.rmi.Naming, common.InventoryService, java.util.List, org.json.JSONObject" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session.getAttribute("user_id") == null || !session.getAttribute("role").equals("Admin")) {
        response.sendRedirect("../login.jsp"); return;
    }
    request.setAttribute("active_page", "suppliers");

    InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");

    // Action Handling Logic (GET/POST) remains the same as your code...
    String deleteId = request.getParameter("delete_id");
    if (deleteId != null && !deleteId.trim().isEmpty()) {
        try {
            service.deleteSupplier(Integer.parseInt(deleteId.trim()));
            response.sendRedirect(request.getContextPath() + "/modules/suppliers.jsp?msg=deleted");
            return;
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/modules/suppliers.jsp?msg=error_fk");
            return;
        }
    }

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String sid = request.getParameter("supplier_id");
        String name = request.getParameter("name");
        String addr = request.getParameter("address");
        String ph = request.getParameter("phone");
        String em = request.getParameter("email");
        String cp = request.getParameter("contact_person");
        service.saveSupplier(sid, name, addr, ph, em, cp);
        String msgType = (sid == null || sid.trim().isEmpty()) ? "success" : "updated";
        response.sendRedirect(request.getContextPath() + "/modules/suppliers.jsp?msg=" + msgType);
        return;
    }

    List<String[]> suppliers = service.getSuppliers();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Partner Registry | OMNI CORE</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        body { background-color: #F6F4F0; scroll-behavior: smooth; }
        .main-content { margin-left: 290px; transition: all 0.4s ease; }
        @media (max-width: 1024px) { .main-content { margin-left: 0; } }

        .glass-card { background: rgba(255, 255, 255, 0.7); backdrop-filter: blur(12px); border: 1px solid rgba(77, 161, 169, 0.15); }
        .supplier-card { transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1); border: 1px solid transparent; }
        .supplier-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 20px 40px -10px rgba(46, 80, 119, 0.15);
            border-color: #79D7BE;
            background: white;
        }
        .btn-primary { background-color: #2E5077; transition: all 0.3s ease; }
        .btn-primary:hover { background-color: #4DA1A9; transform: translateY(-2px); }
    </style>
</head>
<body class="font-sans text-[#2E5077] antialiased">

<jsp:include page="/templates/sidebar_admin.jsp" />

<main class="main-content min-h-screen p-6 lg:p-10 relative">
    <jsp:include page="/includes/header.jsp" />

    <%-- Page Header --%>
    <div class="flex flex-col md:flex-row justify-between items-start md:items-end my-10 gap-6 px-4">
        <div>

            <div class="flex items-center gap-3 mt-3">
                <span class="w-10 h-1 bg-[#79D7BE] rounded-full"></span>
                <p class="text-[#4DA1A9] text-[10px] font-bold uppercase tracking-[0.3em]">Suppliers Partnership</p>
            </div>
        </div>
        <button onclick="openAddModal()" class="bg-[#2E5077] text-white px-8 py-5 rounded-2xl font-black shadow-xl hover:bg-[#4DA1A9] transition-all duration-300 active:scale-95 uppercase text-[10px] tracking-widest flex items-center gap-3">
            <i class="fas fa-handshake text-[#79D7BE]"></i> Onboard Partner
        </button>
    </div>

    <%-- Cards Grid --%>
    <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-8 px-4 mb-10">
        <% if(suppliers != null) { for(String[] s : suppliers) {
            JSONObject info = new JSONObject(s[2]);
            String contactPerson = (s.length > 4 && s[4] != null) ? s[4] : "Not Specified";
        %>
        <div class="supplier-card glass-card p-8 rounded-[2.5rem] relative overflow-hidden group">
            <div class="relative z-10">
                <div class="flex justify-between items-start mb-6">
                    <div>
                        <h3 class="text-xl font-black text-[#2E5077] uppercase italic tracking-tighter truncate w-48"><%= s[1] %></h3>
                        <span class="text-[8px] font-bold text-[#4DA1A9] uppercase tracking-widest">Partner ID: #SUP-<%= s[0] %></span>
                    </div>
                    <div class="w-10 h-10 bg-[#79D7BE]/20 rounded-xl flex items-center justify-center text-[#79D7BE]">
                        <i class="fas fa-certificate text-sm"></i>
                    </div>
                </div>

                <div class="space-y-3 mb-8">
                    <div class="flex items-center gap-4 p-4 bg-[#F6F4F0]/60 rounded-2xl">
                        <i class="fas fa-user-tie text-[#4DA1A9] text-xs"></i>
                        <div class="flex flex-col leading-none">
                            <span class="text-[7px] font-black text-slate-400 uppercase tracking-widest mb-1">Contact Lead</span>
                            <span class="text-[11px] font-bold text-[#2E5077] uppercase"><%= contactPerson %></span>
                        </div>
                    </div>
                    <div class="flex items-center gap-4 p-4 bg-[#F6F4F0]/60 rounded-2xl">
                        <i class="fas fa-phone-alt text-[#79D7BE] text-xs"></i>
                        <span class="text-[11px] font-bold text-slate-600"><%= info.optString("phone", "N/A") %></span>
                    </div>
                    <div class="flex items-center gap-4 p-4 bg-[#F6F4F0]/60 rounded-2xl">
                        <i class="fas fa-envelope text-blue-400 text-xs"></i>
                        <span class="text-[11px] font-bold text-slate-600 truncate"><%= info.optString("email", "N/A") %></span>
                    </div>
                </div>

                <div class="pt-6 border-t border-[#4DA1A9]/10 flex justify-between items-center">
                    <div class="flex flex-col">
                        <span class="text-[8px] font-black text-slate-300 uppercase tracking-widest">Portal Access</span>
                        <span class="text-[10px] font-black text-[#2E5077] uppercase italic">@<%= s[3] != null ? s[3] : "no-account" %></span>
                    </div>
                    <div class="flex gap-2">
                        <button onclick='openEditModal(<%= new JSONObject()
                            .put("id", s[0])
                            .put("name", s[1])
                            .put("phone", info.optString("phone"))
                            .put("email", info.optString("email"))
                            .put("address", info.optString("address"))
                            .put("contact", contactPerson).toString() %>)'
                                class="w-10 h-10 bg-[#2E5077] text-white rounded-xl hover:bg-[#79D7BE] hover:text-[#2E5077] transition-all flex items-center justify-center">
                            <i class="fas fa-sliders-h text-xs"></i>
                        </button>
                        <button onclick="confirmDelete('<%= s[0] %>', '<%= s[1] %>')"
                                class="w-10 h-10 bg-rose-50 text-rose-400 rounded-xl hover:bg-rose-500 hover:text-white transition-all flex items-center justify-center">
                            <i class="fas fa-trash-alt text-xs"></i>
                        </button>
                    </div>
                </div>
            </div>
            <i class="fas fa-truck-ramp-box absolute -right-4 -bottom-4 text-6xl text-[#79D7BE]/10 group-hover:rotate-12 transition-transform duration-700"></i>
        </div>
        <% } } %>
    </div>

    <jsp:include page="/includes/footer.jsp" />
</main>

<%-- Supplier Modal --%>
<div id="supplierModal" class="hidden fixed inset-0 bg-[#2E5077]/40 backdrop-blur-md z-[5000] flex items-center justify-center p-4">
    <div class="bg-white rounded-[3rem] w-full max-w-lg shadow-2xl overflow-hidden border border-white/20">
        <div class="bg-[#2E5077] p-8 text-white flex justify-between items-center">
            <div class="flex items-center gap-3">
                <i class="fas fa-address-book text-[#79D7BE]"></i>
                <h3 id="modalTitle" class="text-xl font-black uppercase tracking-widest">Partner Profile</h3>
            </div>
            <button onclick="closeModal()" class="text-white/40 hover:text-[#79D7BE] text-3xl transition-colors">&times;</button>
        </div>
        <form id="supplierForm" action="suppliers.jsp" method="POST" class="p-10 space-y-5 bg-[#F6F4F0]/30 max-h-[75vh] overflow-y-auto">
            <input type="hidden" name="supplier_id" id="f_id">

            <div>
                <label class="block text-[9px] font-black text-[#4DA1A9] uppercase tracking-widest mb-2 ml-2">Company Identity</label>
                <input type="text" name="name" id="f_name" required class="w-full p-4 bg-white border-none rounded-2xl outline-none focus:ring-2 focus:ring-[#79D7BE] font-bold text-[#2E5077] shadow-sm">
            </div>

            <div>
                <label class="block text-[9px] font-black text-[#4DA1A9] uppercase tracking-widest mb-2 ml-2">Authorized Representative</label>
                <input type="text" name="contact_person" id="f_contact" required class="w-full p-4 bg-white border-none rounded-2xl outline-none focus:ring-2 focus:ring-[#79D7BE] font-bold text-[#2E5077] shadow-sm">
            </div>

            <div class="grid grid-cols-2 gap-4">
                <div>
                    <label class="block text-[9px] font-black text-[#4DA1A9] uppercase tracking-widest mb-2 ml-2">Secure Phone</label>
                    <input type="text" name="phone" id="f_phone" required class="w-full p-4 bg-white border-none rounded-2xl outline-none font-bold text-[#2E5077] shadow-sm">
                </div>
                <div>
                    <label class="block text-[9px] font-black text-[#4DA1A9] uppercase tracking-widest mb-2 ml-2">Official Email</label>
                    <input type="email" name="email" id="f_email" required class="w-full p-4 bg-white border-none rounded-2xl outline-none font-bold text-[#2E5077] shadow-sm">
                </div>
            </div>

            <div>
                <label class="block text-[9px] font-black text-[#4DA1A9] uppercase tracking-widest mb-2 ml-2">Operational HQ Address</label>
                <textarea name="address" id="f_address" required class="w-full p-4 bg-white border-none rounded-2xl outline-none focus:ring-2 focus:ring-[#79D7BE] font-bold text-[#2E5077] h-24 shadow-sm resize-none"></textarea>
            </div>

            <button type="submit" class="w-full bg-[#2E5077] text-white p-6 rounded-2xl font-black uppercase tracking-widest hover:bg-[#4DA1A9] transition-all shadow-xl">Synchronize Partner Data</button>
        </form>
    </div>
</div>



<script>
    function openAddModal() {
        document.getElementById('modalTitle').innerText = "Onboard Partner";
        document.getElementById('f_id').value = "";
        document.getElementById('supplierForm').reset();
        document.getElementById('supplierModal').classList.remove('hidden');
    }

    function openEditModal(data) {
        document.getElementById('modalTitle').innerText = "Modify Partner Profile";
        document.getElementById('f_id').value = data.id;
        document.getElementById('f_name').value = data.name;
        document.getElementById('f_phone').value = data.phone;
        document.getElementById('f_email').value = data.email;
        document.getElementById('f_address').value = data.address;
        document.getElementById('f_contact').value = data.contact || "";
        document.getElementById('supplierModal').classList.remove('hidden');
    }

    function closeModal() { document.getElementById('supplierModal').classList.add('hidden'); }

    function confirmDelete(id, name) {
        if(!id || id.trim() === "") return;
        Swal.fire({
            title: '<span class="uppercase italic tracking-tighter">Terminate Partnership?</span>',
            text: `Confirming the removal of ${name} from the active registry.`,
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#2E5077',
            cancelButtonColor: '#F6F4F0',
            confirmButtonText: 'CONFIRM DELETE',
            background: '#F6F4F0',
            customClass: { popup: 'rounded-[2rem]' }
        }).then((result) => {
            if (result.isConfirmed) {
                window.location.href = "<%= request.getContextPath() %>/modules/suppliers.jsp?delete_id=" + id;
            }
        });
    }

    const params = new URLSearchParams(window.location.search);
    if(params.get('msg') === 'success') Swal.fire({ icon: 'success', title: 'ONBOARDED', text: 'Supplier synchronized successfully.', confirmButtonColor: '#2E5077' });
    if(params.get('msg') === 'updated') Swal.fire({ icon: 'success', title: 'UPDATED', text: 'Partner profile updated.', confirmButtonColor: '#2E5077' });
    if(params.get('msg') === 'deleted') Swal.fire({ icon: 'success', title: 'TERMINATED', text: 'Supplier removed from registry.', confirmButtonColor: '#2E5077' });
    if(params.get('msg') === 'error_fk') Swal.fire({ icon: 'error', title: 'INTEGRITY ERROR', text: 'Cannot delete. Supplier has active dependencies.', confirmButtonColor: '#2E5077' });
</script>
</body>
</html>