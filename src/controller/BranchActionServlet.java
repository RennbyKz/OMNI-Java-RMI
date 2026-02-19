package controller;

import common.InventoryService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.rmi.Naming;

@WebServlet("/BranchActionServlet")
public class BranchActionServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");
            String id = request.getParameter("branch_id");
            String name = request.getParameter("branch_name");
            String loc = request.getParameter("location");

            boolean success = service.saveBranch(id, name, loc);
            response.sendRedirect("modules/branch_control.jsp?msg=" + (success ? "success" : "error"));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("modules/branch_control.jsp?msg=exception");
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");

            String toggleId = request.getParameter("toggle_id");
            String deleteId = request.getParameter("delete_id");

            // ⭐ Toggle Logic: null check နှင့် trim() ထည့်သွင်းခြင်း
            if (toggleId != null && !toggleId.trim().isEmpty()) {
                String currentStatus = request.getParameter("current");
                service.toggleBranchStatus(Integer.parseInt(toggleId.trim()), currentStatus);
                response.sendRedirect("modules/branch_control.jsp?msg=success");
                return;
            }

            // ⭐ Delete Logic: null check နှင့် trim() ထည့်သွင်းခြင်း
            if (deleteId != null && !deleteId.trim().isEmpty()) {
                try {
                    boolean success = service.deleteBranch(Integer.parseInt(deleteId.trim()));
                    response.sendRedirect("modules/branch_control.jsp?msg=" + (success ? "deleted" : "error"));
                } catch (Exception e) {
                    // Dependency ရှိနေပါက error_fk ဟု ပို့ပေးခြင်း
                    response.sendRedirect("modules/branch_control.jsp?msg=error_fk");
                }
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("modules/branch_control.jsp?msg=exception");
        }
    }
}