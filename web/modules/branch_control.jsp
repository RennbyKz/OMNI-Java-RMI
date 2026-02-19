<%@ page import="java.rmi.Naming, common.InventoryService, java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session.getAttribute("user_id") == null || !session.getAttribute("role").equals("Admin")) {
        response.sendRedirect("../login.jsp");
        return;
    }
    request.setAttribute("active_page", "branches");

    List<String[]> branches = null;
    try {
        InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");
        branches = service.getBranches();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Branch Control | OMNI CORE</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        body { background-color: #F6F4F0; scroll-behavior: smooth; }
        .main-content { margin-left: 290px; transition: all 0.4s ease; }
        @media (max-width: 1024px) { .main-content { margin-left: 0; } }

        /* Premium Toggle Switch Customization */
        .switch { position: relative; display: inline-block; width: 50px; height: 26px; }
        .switch input { opacity: 0; width: 0; height: 0; }
        .slider { position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background: #cbd5e1; transition: .4s; border-radius: 34px; }
        .slider:before { position: absolute; content: ""; height: 20px; width: 20px; left: 3px; bottom: 3px; background: white; transition: .4s; border-radius: 50%; }
        input:checked + .slider { background: #79D7BE; }
        input:checked + .slider:before { transform: translateX(24px); }

        .glass-card { background: rgba(255, 255, 255, 0.7); backdrop-filter: blur(12px); border: 1px solid rgba(77, 161, 169, 0.15); }
        .table-row-hover:hover { background-color: rgba(121, 215, 190, 0.05); }
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
                <p class="text-[#4DA1A9] text-[10px] font-bold uppercase tracking-[0.3em]">Branch Control</p>
            </div>
        </div>
        <button onclick="openAddModal()" class="bg-[#2E5077] text-white px-8 py-4 rounded-2xl font-black shadow-xl hover:bg-[#4DA1A9] transition-all duration-300 active:scale-95 uppercase text-[10px] tracking-widest flex items-center gap-3">
            <i class="fas fa-plus-circle text-[#79D7BE]"></i> Register New Node
        </button>
    </div>

    <%-- ⚠️ Notification Area for Integrity Violation --%>
    <% if (request.getParameter("msg") != null && request.getParameter("msg").equals("error_fk")) { %>
    <div class="mx-4 mb-8 bg-rose-50 border-l-4 border-rose-400 p-6 rounded-2xl shadow-sm animate-bounce-short">
        <div class="flex items-center gap-4">
            <div class="w-12 h-12 bg-rose-100 rounded-xl flex items-center justify-center text-rose-500">
                <i class="fas fa-shield-virus text-xl"></i>
            </div>
            <div>
                <h4 class="font-black text-rose-900 uppercase italic leading-none tracking-tight">Security Block</h4>
                <p class="text-[10px] text-rose-400 font-bold mt-1 uppercase tracking-wider">Node termination restricted: Active inventory or user dependencies detected.</p>
            </div>
        </div>
    </div>
    <% } %>

    <%-- Branch Data Table --%>
    <div class="px-4">
        <div class="bg-white rounded-[3rem] shadow-xl shadow-slate-200/50 overflow-hidden border border-[#4DA1A9]/10">
            <table class="w-full text-left">
                <thead class="bg-[#F6F4F0] text-[#4DA1A9] text-[9px] uppercase font-black tracking-[0.2em] border-b border-[#4DA1A9]/10">
                <tr>
                    <th class="px-10 py-6">Network Identity & Location</th>
                    <th class="px-10 py-6 text-center">Operational Status</th>
                    <th class="px-10 py-6 text-right">Node Command</th>
                </tr>
                </thead>
                <tbody class="divide-y divide-[#F6F4F0]">
                <% if (branches != null && !branches.isEmpty()) {
                    for (String[] b : branches) {
                        String safeId = (b[0] != null) ? b[0].trim() : "";
                        String safeName = (b[1] != null) ? b[1].replace("'", "\\'") : "Untitled";
                        String safeLoc = (b.length > 2 && b[2] != null) ? b[2].replace("'", "\\'").replace("\n", " ") : "Unknown";
                        String status = (b.length > 3 && b[3] != null) ? b[3] : "OFFLINE";
                %>
                <tr class="table-row-hover group transition-colors">
                    <td class="px-10 py-8">
                        <div class="flex items-center gap-6">
                            <div class="w-14 h-14 bg-[#F6F4F0] rounded-2xl flex items-center justify-center text-[#2E5077] group-hover:bg-[#2E5077] group-hover:text-[#79D7BE] transition-all duration-500 shadow-inner">
                                <i class="fas fa-server text-xl"></i>
                            </div>
                            <div>
                                <span class="text-lg font-black text-[#2E5077] block uppercase tracking-tighter leading-none mb-2"><%= b[1] %></span>
                                <div class="flex items-center gap-2">
                                    <i class="fas fa-location-arrow text-[#79D7BE] text-[10px]"></i>
                                    <span class="text-[10px] font-bold text-slate-400 uppercase tracking-widest"><%= safeLoc %></span>
                                </div>
                            </div>
                        </div>
                    </td>
                    <td class="px-10 py-8 text-center">
                        <div class="flex items-center justify-center gap-4">
                            <label class="switch">
                                <input type="checkbox" <%= status.equals("ONLINE") ? "checked" : "" %>
                                       onchange="if('<%= safeId %>' !== '') confirmToggle('<%= safeId %>', '<%= status %>')">
                                <span class="slider"></span>
                            </label>
                            <span class="text-[10px] font-black uppercase tracking-widest <%= status.equals("ONLINE") ? "text-[#79D7BE]" : "text-rose-300" %>">
                                <%= status %>
                            </span>
                        </div>
                    </td>
                    <td class="px-10 py-8 text-right space-x-2">
                        <button onclick="openEditModal('<%= safeId %>', '<%= safeName %>', '<%= safeLoc %>')"
                                class="w-11 h-11 bg-[#F6F4F0] text-[#4DA1A9] rounded-xl hover:bg-[#79D7BE] hover:text-[#2E5077] transition-all inline-flex items-center justify-center shadow-sm">
                            <i class="fas fa-sliders-h"></i>
                        </button>
                        <button onclick="confirmDelete('<%= safeId %>', '<%= safeName %>')"
                                class="w-11 h-11 bg-rose-50 text-rose-300 rounded-xl hover:bg-rose-500 hover:text-white transition-all inline-flex items-center justify-center shadow-sm">
                            <i class="fas fa-power-off text-sm"></i>
                        </button>
                    </td>
                </tr>
                <% } } else { %>
                <tr><td colspan="3" class="p-20 text-center font-bold text-slate-300 italic uppercase tracking-widest">No branch nodes detected in current cluster</td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <jsp:include page="/includes/footer.jsp" />
</main>

<%-- Modal Box: Node Config --%>
<div id="branchModal" class="hidden fixed inset-0 bg-[#2E5077]/40 backdrop-blur-md z-[9999] flex items-center justify-center p-4">
    <div class="bg-white rounded-[3rem] w-full max-w-md shadow-2xl overflow-hidden border border-white/20">
        <div class="bg-[#2E5077] p-8 text-white flex justify-between items-center">
            <div class="flex items-center gap-3">
                <i class="fas fa-project-diagram text-[#79D7BE]"></i>
                <h3 id="modalTitle" class="text-xl font-black uppercase tracking-widest">Node Registry</h3>
            </div>
            <button onclick="closeModal()" class="text-white/40 hover:text-[#79D7BE] text-3xl transition-colors">&times;</button>
        </div>
        <form id="branchForm" action="../BranchActionServlet" method="POST" class="p-10 space-y-6 bg-[#F6F4F0]/30">
            <input type="hidden" name="branch_id" id="f_id">
            <input type="hidden" name="action_type" id="f_action">
            <div>
                <label class="block text-[9px] font-black text-[#4DA1A9] uppercase tracking-widest mb-2 ml-2">Node Alias</label>
                <input type="text" name="branch_name" id="f_name" required placeholder="Main Distribution Center"
                       class="w-full p-4 bg-white border-2 border-transparent rounded-2xl outline-none focus:border-[#79D7BE] font-bold text-[#2E5077] shadow-sm">
            </div>
            <div>
                <label class="block text-[9px] font-black text-[#4DA1A9] uppercase tracking-widest mb-2 ml-2">Distribution Point</label>
                <textarea name="location" id="f_loc" required placeholder="Detailed Address"
                          class="w-full p-4 bg-white border-2 border-transparent rounded-2xl outline-none focus:border-[#79D7BE] font-bold text-[#2E5077] h-32 shadow-sm resize-none"></textarea>
            </div>
            <button type="submit" class="w-full bg-[#2E5077] text-white p-5 rounded-2xl font-black uppercase tracking-[0.2em] text-[10px] shadow-lg hover:bg-[#4DA1A9] transition-all duration-300 active:scale-95">
                Save Node Data
            </button>
        </form>
    </div>
</div>



<script>
    function openAddModal() {
        document.getElementById('modalTitle').innerText = "Register Node";
        document.getElementById('f_action').value = "add";
        document.getElementById('f_id').value = "";
        document.getElementById('branchForm').reset();
        document.getElementById('branchModal').classList.remove('hidden');
    }

    function openEditModal(id, name, loc) {
        if(!id || id === "") return;
        document.getElementById('modalTitle').innerText = "Modify Topology";
        document.getElementById('f_action').value = "update";
        document.getElementById('f_id').value = id;
        document.getElementById('f_name').value = name;
        document.getElementById('f_loc').value = loc;
        document.getElementById('branchModal').classList.remove('hidden');
    }

    function closeModal() { document.getElementById('branchModal').classList.add('hidden'); }

    function confirmToggle(id, current) {
        if(!id || id === "") return;
        const base = "<%= request.getContextPath() %>";
        window.location.href = base + "/BranchActionServlet?toggle_id=" + id + "&current=" + current;
    }

    function confirmDelete(id, name) {
        if(!id || id === "") return;
        Swal.fire({
            title: '<span class="uppercase italic tracking-tighter">Decommission Node?</span>',
            html: `<div class="text-[11px] text-slate-500 font-bold uppercase tracking-widest">Removing <span class="text-rose-500 italic">"${name}"</span> from the backbone is permanent.</div>`,
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#2E5077',
            cancelButtonColor: '#F6F4F0',
            confirmButtonText: 'YES, TERMINATE',
            background: '#F6F4F0',
            customClass: { popup: 'rounded-[2rem]' }
        }).then((result) => {
            if (result.isConfirmed) {
                window.location.href = "<%= request.getContextPath() %>/BranchActionServlet?delete_id=" + id;
            }
        });
    }

    const params = new URLSearchParams(window.location.search);
    if(params.get('msg') === 'deleted') {
        Swal.fire({ icon: 'success', title: 'TERMINATED', text: 'Branch node removed successfully.', confirmButtonColor: '#2E5077' });
        window.history.replaceState({}, document.title, window.location.pathname);
    } else if(params.get('msg') === 'success') {
        Swal.fire({ icon: 'success', title: 'SYNCHRONIZED', text: 'Network configuration updated.', confirmButtonColor: '#2E5077' });
        window.history.replaceState({}, document.title, window.location.pathname);
    }
</script>
</body>
</html>