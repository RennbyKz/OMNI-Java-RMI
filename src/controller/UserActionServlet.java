package controller;

import common.InventoryService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.rmi.Naming;

@WebServlet("/UserActionServlet")
public class UserActionServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // ၁။ RMI Connection (Middleware Port 1100 သို့ ချိတ်ဆက်ခြင်း)
            InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");

            // ၂။ Form Data ရယူခြင်း (PHP $_POST နှင့် အလားတူလုပ်ဆောင်ခြင်း)

            // user_id က Update အတွက်ဖြစ်ပြီး Insert ဆိုလျှင် null/empty ဖြစ်နေပါမည်
            String userId = request.getParameter("user_id");
            String username = request.getParameter("username");

            // role_id ကို int အဖြစ် parse လုပ်ရန် လိုအပ်သည် (Interface တွင် int ဟု သတ်မှတ်ထားသောကြောင့်)
            int roleId = Integer.parseInt(request.getParameter("role_id"));

            // ⭐ ပြင်ဆင်ချက်: branch_id ကို Integer အဖြစ်မပြောင်းဘဲ String အဖြစ်သာ တိုက်ရိုက်ယူပါ
            // Interface ရှိ saveUser(String, String, int, String) နှင့် ကိုက်ညီစေရန်ဖြစ်သည်
            String branchId = request.getParameter("branch_id");

            // ၃။ Middleware (RMI Server) ထံသို့ လှမ်းပို့ခြင်း
            boolean success = service.saveUser(userId, username, roleId, branchId);

            if (success) {
                // အောင်မြင်လျှင် manage_users.jsp သို့ success message နှင့် ပြန်ပို့ခြင်း
                response.sendRedirect("modules/manage_users.jsp?msg=success");
            } else {
                // မအောင်မြင်လျှင် error message ပြခြင်း
                response.sendRedirect("modules/manage_users.jsp?msg=error");
            }

        } catch (NumberFormatException e) {
            // Role ID parse လုပ်ရာတွင် အမှားရှိပါက
            e.printStackTrace();
            response.sendRedirect("modules/manage_users.jsp?msg=invalid_input");
        } catch (Exception e) {
            // အခြားသော RMI သို့မဟုတ် Connection Error များရှိပါက
            e.printStackTrace();
            response.sendRedirect("modules/manage_users.jsp?msg=exception");
        }
    }
}