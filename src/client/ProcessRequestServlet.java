package client;

import common.InventoryService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.rmi.Naming;

@WebServlet("/ProcessRequestServlet")
public class ProcessRequestServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        try {
            // ၁။ Form ဒေတာများ ရယူခြင်း
            int supplierId = Integer.parseInt(request.getParameter("supplier_id"));
            String productName = request.getParameter("product_name");
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            String remark = request.getParameter("remark");
            int branchId = (int) session.getAttribute("branch_id");

            // ၂။ RMI Middleware ချိတ်ဆက်ခြင်း
            InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");

            // ၃။ Middleware Method ကို လှမ်းခေါ်ခြင်း
            boolean success = service.createStockRequest(supplierId, productName, quantity, branchId, remark);

            if (success) {
                response.sendRedirect("modules/stock_requests.jsp?msg=success");
            } else {
                response.sendRedirect("modules/stock_requests.jsp?error=failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("modules/stock_requests.jsp?error=server");
        }
    }
}