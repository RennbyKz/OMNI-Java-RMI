package controller;

import common.InventoryService;
import common.AppConfig; // ⭐ AppConfig ကို import လုပ်ပါ
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.net.URLEncoder;
import java.rmi.Naming;

@WebServlet("/InventoryActionServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10,      // 10MB
        maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class InventoryActionServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // ⭐ localhost အစား AppConfig.getRmiUrl() ကို သုံးပါ
            InventoryService service = (InventoryService) Naming.lookup(AppConfig.getRmiUrl());

            String idStr = request.getParameter("item_id");
            String name = request.getParameter("item_name");
            int qty = parseOrDefault(request.getParameter("quantity"), 0);
            double price = parseDoubleOrDefault(request.getParameter("price"), 0.0);
            int branchId = parseOrDefault(request.getParameter("branch_id"), 0);
            int supplierId = parseOrDefault(request.getParameter("supplier_id"), 0);
            String category = request.getParameter("category");
            String metadata = request.getParameter("metadata");

            // 📸 Image Handling
            String imageUrl = null; // Update အတွက် null ထားပါမည်
            Part filePart = request.getPart("image_file");

            if (filePart != null && filePart.getSize() > 0) {
                String fileName = System.currentTimeMillis() + "_" + filePart.getSubmittedFileName();
                String uploadPath = getServletContext().getRealPath("") + File.separator + "assets/uploads/products";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdirs();

                filePart.write(uploadPath + File.separator + fileName);
                imageUrl = "assets/uploads/products/" + fileName;
            }

            boolean success;
            if (idStr == null || idStr.trim().isEmpty() || idStr.equals("0")) {
                // အသစ်ထည့်ခြင်း (Insert)
                if (imageUrl == null) imageUrl = "assets/uploads/products/default.png";
                success = service.addInventory(name, price, qty, branchId, supplierId, category, metadata, imageUrl);
            } else {
                // ⭐ ပြင်ဆင်ခြင်း (Update) - imageUrl ကို parameter အဖြစ် ထည့်ပေးရပါမည်
                int id = Integer.parseInt(idStr);
                // သတိပြုရန်: service.updateInventory ထဲတွင် imageUrl လက်ခံသော parameter ပါရပါမည်
                success = service.updateInventory(id, name, qty, price, branchId, supplierId, category, metadata, imageUrl);
            }

            response.sendRedirect("modules/inventory.jsp?msg=" + (success ? "success" : "error"));

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("modules/inventory.jsp?msg=error&details=" + URLEncoder.encode(e.getMessage(), "UTF-8"));
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            InventoryService service = (InventoryService) Naming.lookup(AppConfig.getRmiUrl());
            String deleteId = request.getParameter("delete_id");
            if (deleteId != null) {
                service.deleteInventory(Integer.parseInt(deleteId));
                response.sendRedirect("modules/inventory.jsp?msg=deleted");
            }
        } catch (Exception e) {
            response.sendRedirect("modules/inventory.jsp?msg=error");
        }
    }

    private int parseOrDefault(String val, int def) { return (val == null || val.isEmpty()) ? def : Integer.parseInt(val); }
    private double parseDoubleOrDefault(String val, double def) { return (val == null || val.isEmpty()) ? def : Double.parseDouble(val); }
}