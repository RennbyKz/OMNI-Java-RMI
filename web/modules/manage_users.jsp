<%@ page import="java.rmi.Naming, common.InventoryService, java.util.*, java.io.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // ၁။ Security & Service Connection
    if (session.getAttribute("user_id") == null || !"Admin".equals(session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp"); return;
    }
    request.setAttribute("active_page", "manage_users");

    InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");
    String basePath = "manage_users.jsp";

    // ၂။ Logic Handlers (Error handling for empty parameters)
    String deleteId = request.getParameter("delete_id");
    if (deleteId != null && !deleteId.trim().isEmpty()) {
        service.deleteUser(Integer.parseInt(deleteId.trim()));
        response.sendRedirect(basePath + "?msg=deleted"); return;
    }

    String resetId = request.getParameter("reset_id");
    if (resetId != null && !resetId.trim().isEmpty()) {
        service.resetPassword(Integer.parseInt(resetId.trim()));
        response.sendRedirect(basePath + "?msg=reset_success"); return;
    }

    String toggleId = request.getParameter("toggle_id");
    String current = request.getParameter("current");
    if (toggleId != null && !toggleId.trim().isEmpty() && current != null) {
        service.toggleUserStatus(Integer.parseInt(toggleId.trim()), current);
        response.sendRedirect(basePath); return;
    }

    // ၃။ Data Fetching
    String search = request.getParameter("search") != null ? request.getParameter("search") : "";
    String rFilter = request.getParameter("role_filter") != null ? request.getParameter("role_filter") : "";
    List<String[]> users = service.getUsers(search, rFilter);
    List<String[]> roles = service.getRoles();
    List<String[]> branches = service.getBranches();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>User Hub | OMNI CORE</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        body { background-color: #F6F4F0; }
        .main-content { margin-left: 290px; transition: all 0.4s ease; }
        @media (max-width: 1024px) { .main-content { margin-left: 0; } }
        /* ခလုတ်တွေ တစ်တန်းတည်းဖြစ်အောင် whitespace ထိန်းချုပ်ခြင်း */
        .command-cell { white-space: nowrap; width: 150px; }
    </style>
</head>
<body class="font-sans text-[#2E5077] antialiased">

<jsp:include page="/templates/sidebar_admin.jsp" />

<main class="main-content min-h-screen p-6 lg:p-10 relative">
    <jsp:include page="/includes/header.jsp" />

    <div class="flex flex-col md:flex-row justify-between items-start md:items-end my-10 gap-6 px-4">
        <div>

            <div class="flex items-center gap-3 mt-3">
                <span class="w-10 h-1 bg-[#79D7BE] rounded-full"></span>
                <p class="text-[#4DA1A9] text-[10px] font-bold uppercase tracking-[0.3em]">Users Management</p>
            </div>
        </div>
        <button onclick="openAddModal()" class="bg-[#2E5077] text-white px-8 py-4 rounded-2xl font-black shadow-xl hover:bg-[#4DA1A9] transition-all duration-300 uppercase text-[10px] tracking-widest">
            <i class="fas fa-user-plus text-[#79D7BE] mr-2"></i> Register Operator
        </button>
    </div>

    <div class="px-4">
        <div class="bg-white rounded-[3rem] shadow-xl shadow-slate-200/50 overflow-hidden border border-[#4DA1A9]/10">
            <table class="w-full text-left">
                <thead class="bg-[#F6F4F0] text-[#4DA1A9] text-[9px] uppercase font-black tracking-[0.2em] border-b border-[#4DA1A9]/10">
                <tr>
                    <th class="px-8 py-6">Operator Identity</th>
                    <th class="px-8 py-6 text-center">Node Location</th>
                    <th class="px-8 py-6 text-center">Security Status</th>
                    <th class="px-8 py-6 text-right">Command</th>
                </tr>
                </thead>
                <tbody class="divide-y divide-[#F6F4F0]">
                <% if(users != null) { for(String[] u : users) { %>
                <tr class="hover:bg-[#F6F4F0]/50 transition-all">
                    <td class="px-8 py-8">
                        <div class="flex items-center gap-4">
                            <div class="w-11 h-11 rounded-xl bg-[#F6F4F0] flex items-center justify-center border-2 border-white shadow-sm">
                                <i class="fas fa-user-shield text-[#4DA1A9]"></i>
                            </div>
                            <div>
                                <span class="font-black text-[#2E5077] uppercase tracking-tighter text-base italic block leading-none mb-1"><%= u[1] %></span>
                                <span class="text-[9px] font-bold text-[#4DA1A9] uppercase tracking-widest"><%= u[2] %></span>
                            </div>
                        </div>
                    </td>
                    <td class="px-8 py-8 text-center">
                        <span class="text-[11px] font-black text-slate-400 uppercase italic"><%= u[3] != null ? u[3] : "GLOBAL HQ" %></span>
                    </td>
                    <td class="px-8 py-8 text-center">
                        <div class="flex flex-col items-center gap-1.5">
                            <label class="relative inline-flex items-center cursor-pointer">
                                <input type="checkbox" class="sr-only peer" <%= "ACTIVE".equals(u[4]) ? "checked" : "" %>
                                       onchange="location.href='manage_users.jsp?toggle_id=<%= u[0] %>&current=<%= u[4] %>'">
                                <div class="w-10 h-5 bg-slate-200 rounded-full peer peer-checked:bg-[#79D7BE] peer-checked:after:translate-x-full after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:rounded-full after:h-4 after:w-4 after:transition-all"></div>
                            </label>
                            <span class="text-[7px] font-black uppercase tracking-widest <%= "ACTIVE".equals(u[4]) ? "text-[#79D7BE]" : "text-slate-400" %>"><%= u[4] %></span>
                        </div>
                    </td>
                    <td class="px-8 py-8 text-right command-cell">
                        <div class="inline-flex gap-2">
                            <%-- ⭐ Edit Button --%>
                            <button onclick="openEditModal('<%= u[0] %>', '<%= u[1] %>', '<%= u[5] %>', '<%= (u[6] != null ? u[6] : "") %>')"
                                    class="w-10 h-10 bg-[#F6F4F0] text-[#4DA1A9] rounded-xl hover:bg-[#2E5077] hover:text-[#79D7BE] transition flex items-center justify-center">
                                <i class="fas fa-user-pen text-xs"></i>
                            </button>
                            <%-- ⭐ Reset Button --%>
                            <button onclick="confirmReset(<%= u[0] %>, '<%= u[1] %>')"
                                    class="w-10 h-10 bg-amber-50 text-amber-500 rounded-xl hover:bg-amber-500 hover:text-white transition flex items-center justify-center">
                                <i class="fas fa-key text-xs"></i>
                            </button>
                            <%-- ⭐ Delete Button --%>
                            <button onclick="confirmDelete(<%= u[0] %>, '<%= u[1] %>')"
                                    class="w-10 h-10 bg-rose-50 text-rose-300 rounded-xl hover:bg-rose-500 hover:text-white transition flex items-center justify-center">
                                <i class="fas fa-user-minus text-xs"></i>
                            </button>
                        </div>
                    </td>
                </tr>
                <% } } %>
                </tbody>
            </table>
        </div>
    </div>
</main>

<%-- Unified Modal --%>
<div id="userModal" class="hidden fixed inset-0 bg-[#2E5077]/40 backdrop-blur-md z-[5000] flex items-center justify-center p-4">
    <div class="bg-white rounded-[3rem] w-full max-w-md shadow-2xl overflow-hidden border border-white/20">
        <div class="bg-[#2E5077] p-8 text-white flex justify-between items-center">
            <h3 id="modalTitle" class="text-xl font-black uppercase tracking-widest italic">Operator Config</h3>
            <button onclick="closeModal()" class="text-white/40 hover:text-[#79D7BE] text-3xl">&times;</button>
        </div>
        <form action="../UserActionServlet" method="POST" class="p-10 space-y-6 bg-[#F6F4F0]/30">
            <input type="hidden" name="user_id" id="form_id">
            <input type="hidden" name="action_type" id="form_action_type" value="save">
            <div>
                <label class="block text-[9px] font-black text-[#4DA1A9] uppercase tracking-widest mb-2 ml-2">Username</label>
                <input type="text" name="username" id="form_name" required class="w-full p-4 bg-white border-none rounded-2xl font-bold text-[#2E5077] shadow-sm outline-none">
            </div>
            <div>
                <label class="block text-[9px] font-black text-[#4DA1A9] uppercase tracking-widest mb-2 ml-2">Security Role</label>
                <select name="role_id" id="form_role" required class="w-full p-4 bg-white border-none rounded-2xl font-bold text-[#2E5077] shadow-sm outline-none">
                    <% if(roles != null) { for(String[] r : roles) { %>
                    <option value="<%= r[0] %>"><%= r[1] %></option>
                    <% } } %>
                </select>
            </div>
            <div>
                <label class="block text-[9px] font-black text-[#4DA1A9] uppercase tracking-widest mb-2 ml-2">Assigned Node</label>
                <select name="branch_id" id="form_branch" class="w-full p-4 bg-white border-none rounded-2xl font-bold text-[#2E5077] shadow-sm outline-none">
                    <option value="">Global HQ</option>
                    <% if(branches != null) { for(String[] b : branches) { %>
                    <option value="<%= b[0] %>"><%= b[1] %></option>
                    <% } } %>
                </select>
            </div>
            <button type="submit" class="w-full bg-[#2E5077] text-white p-6 rounded-2xl font-black uppercase tracking-widest hover:bg-[#4DA1A9] transition-all shadow-xl">Commit Sync</button>
        </form>
    </div>
</div>

<script>
    function openAddModal() {
        document.getElementById('modalTitle').innerText = "Register Node";
        document.getElementById('form_id').value = "";
        document.getElementById('form_name').value = "";
        document.getElementById('form_action_type').value = "save";
        document.getElementById('userModal').classList.remove('hidden');
    }

    function openEditModal(id, name, role, branch) {
        document.getElementById('modalTitle').innerText = "Modify Node";
        document.getElementById('form_id').value = id;
        document.getElementById('form_name').value = name;
        document.getElementById('form_role').value = role;
        document.getElementById('form_branch').value = branch;
        document.getElementById('form_action_type').value = "update_profile";
        document.getElementById('userModal').classList.remove('hidden');
    }

    function closeModal() { document.getElementById('userModal').classList.add('hidden'); }

    function confirmReset(id, name) {
        if(!id) return;
        Swal.fire({ title: 'RESET KEY?', text: `Reset password for ${name}?`, icon: 'warning', showCancelButton: true, confirmButtonColor: '#2E5077', confirmButtonText: 'CONFIRM' })
            .then((result) => { if (result.isConfirmed) window.location.href = `manage_users.jsp?reset_id=` + id; });
    }

    function confirmDelete(id, name) {
        if(!id) return;
        Swal.fire({ title: 'PURGE ACCESS?', text: `Delete operator ${name} permanently?`, icon: 'error', showCancelButton: true, confirmButtonColor: '#f43f5e', confirmButtonText: 'DELETE' })
            .then((result) => { if (result.isConfirmed) window.location.href = `manage_users.jsp?delete_id=` + id; });
    }
</script>
</body>
</html>