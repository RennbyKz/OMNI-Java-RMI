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

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String user = request.getParameter("username");
        String pass = request.getParameter("password");

        try {
            // ၁။ RMI Service ကို ချိတ်ဆက်ခြင်း
            InventoryService service = (InventoryService) Naming.lookup("rmi://localhost:1100/InventoryService");

            // ၂။ Middleware မှ User Data များကို Array ဖြင့် ရယူခြင်း
            // အစဉ်လိုက်: [0]role, [1]branch_id, [2]supplier_id, [3]branch_name, [4]user_id
            String[] userData = service.login(user, pass);

            if (userData != null) {
                HttpSession session = request.getSession();
                String role = userData[0];

                // ⭐ အရေးကြီးဆုံး ပြင်ဆင်ချက်:
                // "user" (စာသား) ကို user_id နေရာတွင် မသိမ်းတော့ပါ။
                // Middleware မှ ပို့ပေးသော index [4] ရှိ ဂဏန်း ID ကိုသာ သိမ်းပါမည်။
                if (userData.length > 4 && userData[4] != null) {
                    session.setAttribute("user_id", Integer.parseInt(userData[4]));
                }

                // Username ကို Display ပြရန်အတွက် သီးသန့်သိမ်းဆည်းပါ
                session.setAttribute("username", user);
                session.setAttribute("role", role);

                // ၃။ Branch Info သိမ်းဆည်းခြင်း (Manager/Storekeeper များအတွက်)
                if (userData[1] != null && !userData[1].isEmpty()) {
                    session.setAttribute("branch_id", Integer.parseInt(userData[1]));
                    session.setAttribute("branch_name", userData[3]);
                }

                // ၄။ Supplier Info သိမ်းဆည်းခြင်း (Supplier များအတွက်)
                if (userData[2] != null && !userData[2].isEmpty()) {
                    session.setAttribute("supplier_id", Integer.parseInt(userData[2]));
                }

                // ၅။ Role အလိုက် Dashboard သို့ Redirect လုပ်ခြင်း
                String target = role.toLowerCase().trim() + "_dashboard.jsp";
                response.sendRedirect("modules/" + target);
                return;

            } else {
                // Login မအောင်မြင်ပါက Error Message ပြန်ပို့ခြင်း
                response.sendRedirect("login.jsp?error=mismatch");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=server");
        }
    }
}