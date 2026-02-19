package client;

import common.InventoryService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.rmi.Naming;
import java.util.List;

/**
 * ဤ Servlet သည် AJAX/Fetch request ကို လက်ခံပြီး
 * ရွေးချယ်လိုက်သော Supplier နှင့် သက်ဆိုင်သည့် ပစ္စည်းစာရင်းကို JSON ဖြင့် ပြန်ပေးပါသည်။
 */
@WebServlet("/modules/get_supplier_products.jsp") // JSP ထဲရှိ Fetch URL နှင့် အတိအကျ တူရပါမည်
public class GetSupplierProductsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ၁။ URL မှ supplier_id ကို ရယူခြင်း
        String supplierIdStr = request.getParameter("supplier_id");

        // ၂။ Response Header ကို JSON format သတ်မှတ်ခြင်း
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        // ၃။ ဒေတာများကို RMI Middleware မှ တောင်းဆိုခြင်း
        try {
            if (supplierIdStr == null || supplierIdStr.trim().isEmpty()) {
                out.print("[]"); // ID မပါလာပါက empty array ပြန်မည်
                return;
            }

            int supplierId = Integer.parseInt(supplierIdStr);
            InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");

            // Middleware ဆီမှ ပစ္စည်းစာရင်းတောင်းခြင်း
            List<String[]> products = service.getProductsBySupplier(supplierId);

            // ၄။ Manual JSON Construction (Library မသုံးဘဲ ရေးသားခြင်း)
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < products.size(); i++) {
                String productName = products.get(i)[0]; // getProductsBySupplier က String[] ပြန်ပေးသည်ဟု ယူဆပါသည်

                json.append("{");
                json.append("\"product_name\":\"").append(productName).append("\"");
                json.append("}");

                if (i < products.size() - 1) {
                    json.append(",");
                }
            }
            json.append("]");

            // ၅။ JSON ဒေတာကို JavaScript ဆီ ပို့လွှတ်ခြင်း
            out.print(json.toString());

        } catch (Exception e) {
            e.printStackTrace();
            out.print("[]"); // Error တက်ပါက empty array ပြန်မည်
        } finally {
            out.flush();
            out.close();
        }
    }
}