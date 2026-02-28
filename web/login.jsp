<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session.getAttribute("user_id") != null) {
        response.sendRedirect("modules/admin_dashboard.jsp?msg=login_success");
        return;
    }
%>
<!DOCTYPE html>
<html lang="my">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Omni CORE | စနစ်သို့ဝင်ရောက်ရန်</title>

    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <style>
        @import url('https://fonts.googleapis.com/css2?family=Pyidaungsu:wght@400;700&display=swap');

        body { font-family: 'Pyidaungsu', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }

        @keyframes float {
            0% { transform: translateY(0px) rotate(0deg); opacity: 0.2; }
            50% { transform: translateY(-20px) rotate(5deg); opacity: 0.4; }
            100% { transform: translateY(0px) rotate(0deg); opacity: 0.2; }
        }
        .animate-float { animation: float 8s ease-in-out infinite; }

        .glass-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(15px);
            border: 1px solid rgba(77, 161, 169, 0.2);
        }

        .primary-btn {
            background-color: #2E5077;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .primary-btn:hover {
            background-color: #4DA1A9;
            transform: translateY(-2px);
            box-shadow: 0 10px 20px -5px rgba(46, 80, 119, 0.3);
        }

        ::-webkit-scrollbar { width: 0px; }
    </style>
</head>

<body class="min-h-screen bg-[#F6F4F0] flex flex-col relative overflow-x-hidden">

<div class="absolute inset-0 z-0 pointer-events-none overflow-hidden">
    <div class="absolute top-[-5%] right-[-10%] w-[300px] md:w-[500px] h-[300px] md:h-[500px] bg-[#79D7BE] rounded-full blur-[80px] md:blur-[140px] opacity-20"></div>
    <div class="absolute bottom-[-5%] left-[-10%] w-[300px] md:w-[500px] h-[300px] md:h-[500px] bg-[#4DA1A9] rounded-full blur-[80px] md:blur-[140px] opacity-20"></div>

    <i class="fa-solid fa-truck-fast absolute top-[10%] left-[5%] text-[#2E5077] text-4xl md:text-7xl animate-float opacity-20 md:opacity-40"></i>
    <i class="fa-solid fa-boxes-stacked absolute top-[60%] right-[5%] text-[#4DA1A9] text-5xl md:text-8xl animate-float opacity-10" style="animation-delay: 2s;"></i>
</div>

<div class="relative z-10 flex-1 flex items-center justify-center p-4 md:p-8 lg:p-12">
    <div class="w-full max-w-[450px] lg:max-w-5xl glass-card rounded-[2rem] md:rounded-[3rem] shadow-2xl overflow-hidden grid grid-cols-1 lg:grid-cols-2">

        <div class="bg-[#2E5077] p-8 md:p-12 lg:p-16 flex flex-col justify-between text-white relative">
            <div class="absolute inset-0 opacity-10 pointer-events-none" style="background-image: url('https://www.transparenttextures.com/patterns/carbon-fibre.png');"></div>

            <div class="relative z-10">
                <div class="flex items-center gap-4 mb-8 md:mb-12">
                    <div class="w-12 h-12 md:w-16 md:h-16 bg-[#79D7BE] rounded-2xl flex items-center justify-center shadow-xl ring-4 ring-white/10">
                        <img src="omni_logo.png" class="w-8 h-8 md:w-10 md:h-10 object-contain" alt="Logo">
                    </div>
                    <div>
                        <h2 class="text-xl md:text-2xl font-black tracking-tight leading-none italic uppercase">OMNI <span class="text-[#79D7BE]">Inventory</span></h2>
                        <p class="text-[7px] md:text-[9px] font-bold uppercase tracking-[0.3em] text-[#4DA1A9] mt-1">ကုန်ပစ္စည်းစီမံခန့်ခွဲမှုစနစ်</p>
                    </div>
                </div>

                <h1 class="text-3xl md:text-4xl lg:text-5xl font-extrabold leading-tight mb-4 md:mb-6 tracking-tighter">
                    ကုန်ပစ္စည်းများကို <br class="hidden lg:block"><br><span class="text-[#79D7BE]">အချိန်နှင့်တပြေးညီ</span> <br class="hidden lg:block">စစ်ဆေးပါ။
                </h1>
                <p class="text-slate-300 text-sm md:text-lg leading-relaxed font-light max-w-xs mb-8 lg:mb-0">
                    ထောက်ပံ့ပို့ဆောင်ရေးကွင်းဆက်များကို စနစ်တကျ ချိတ်ဆက်ထိန်းသိမ်းပေးပါသည်။
                </p>
            </div>

            <div class="relative z-10 pt-6 border-t border-white/10 hidden md:flex items-center gap-4">
                <div class="flex -space-x-2">
                    <div class="w-8 h-8 rounded-full border-2 border-[#2E5077] bg-[#4DA1A9] flex items-center justify-center text-[10px]"><i class="fa-solid fa-check"></i></div>
                    <div class="w-8 h-8 rounded-full border-2 border-[#2E5077] bg-[#79D7BE] flex items-center justify-center text-[10px]"><i class="fa-solid fa-shield"></i></div>
                </div>
                <p class="text-[9px] font-bold uppercase tracking-widest text-slate-400 italic">လုံခြုံစိတ်ချရသော စနစ်တစ်ခု</p>
            </div>
        </div>

        <div class="p-8 md:p-12 lg:p-20 flex flex-col justify-center bg-white/95">
            <div class="mb-8 text-center lg:text-left">
                <h2 class="text-2xl md:text-3xl font-black text-[#2E5077] tracking-tight uppercase italic leading-none">အကောင့်ဝင်ရန်</h2>
                <div class="h-1 w-12 md:h-1.5 md:w-16 bg-[#79D7BE] mt-3 md:mt-4 rounded-full mx-auto lg:mx-0"></div>
            </div>

            <form action="LoginServlet" method="POST" class="space-y-5 md:space-y-6">
                <div>
                    <label class="block text-[10px] md:text-[11px] font-bold text-[#4DA1A9] uppercase tracking-widest mb-2 ml-1">အသုံးပြုသူအမည် / အိုင်ဒီ</label>
                    <div class="relative group">
                        <i class="fa-solid fa-id-card absolute left-4 top-1/2 -translate-y-1/2 text-slate-300 group-focus-within:text-[#4DA1A9] transition-colors"></i>
                        <input type="text" name="username" required placeholder="Username ထည့်ပါ"
                               class="w-full pl-12 pr-4 py-4 md:py-5 bg-[#F6F4F0] border-2 border-transparent rounded-xl md:rounded-2xl outline-none focus:border-[#4DA1A9] focus:bg-white transition-all duration-300 font-bold text-[#2E5077] text-sm md:text-base">
                    </div>
                </div>

                <div>
                    <label class="block text-[10px] md:text-[11px] font-bold text-[#4DA1A9] uppercase tracking-widest mb-2 ml-1">လျှို့ဝှက်နံပါတ်</label>
                    <div class="relative group">
                        <i class="fa-solid fa-lock-open absolute left-4 top-1/2 -translate-y-1/2 text-slate-300 group-focus-within:text-[#4DA1A9] transition-colors"></i>
                        <input type="password" name="password" required placeholder="••••••••"
                               class="w-full pl-12 pr-4 py-4 md:py-5 bg-[#F6F4F0] border-2 border-transparent rounded-xl md:rounded-2xl outline-none focus:border-[#4DA1A9] focus:bg-white transition-all duration-300 font-bold text-[#2E5077] text-sm md:text-base">
                    </div>
                </div>

                <div class="pt-2">
                    <button type="submit" class="primary-btn w-full text-white py-4 md:py-5 rounded-xl md:rounded-2xl font-black text-[10px] md:text-xs uppercase tracking-[0.2em] md:tracking-[0.3em] flex items-center justify-center gap-3">
                        <i class="fa-solid fa-fingerprint"></i> စနစ်ထဲသို့ဝင်မည်
                    </button>
                </div>
            </form>

            <p class="text-center mt-8 text-[9px] md:text-[10px] text-slate-400 font-medium tracking-tight">
                OMNI Inventroy &copy; <%= java.time.Year.now().getValue() %> | Copyright
            </p>
        </div>
    </div>
</div>

<script>
    const urlParams = new URLSearchParams(window.location.search);
    const msg = urlParams.get('msg');
    const error = urlParams.get('error');

    // Logout ဖြစ်ပြီးချိန်တွင် ပြသမည့်စာသား
    if (msg === 'logout') {
        Swal.fire({
            icon: 'success',
            title: '<span class="font-bold text-[#2E5077]">စနစ်မှ ထွက်ပြီးပါပြီ</span>',
            text: 'အသုံးပြုမှု အောင်မြင်စွာ ပိတ်သိမ်းပြီးပါပြီ။',
            confirmButtonText: 'အိုကေ',
            confirmButtonColor: '#2E5077',
            customClass: { popup: 'rounded-[1.5rem] md:rounded-[2.5rem]' }
        });
        window.history.replaceState({}, document.title, window.location.pathname);
    }

    // Login မှားယွင်းချိန်တွင် ပြသမည့်စာသား
    if (error) {
        Swal.fire({
            icon: 'error',
            title: '<span class="font-bold text-red-600">ဝင်ရောက်ရန် ငြင်းပယ်ခံရသည်</span>',
            text: 'အသုံးပြုသူအမည် သို့မဟုတ် လျှို့ဝှက်နံပါတ် မှားယွင်းနေပါသည်။',
            confirmButtonText: 'ထပ်မံကြိုးစားမည်',
            confirmButtonColor: '#2E5077',
            customClass: { popup: 'rounded-[1.5rem] md:rounded-[2.5rem]' }
        });
        window.history.replaceState({}, document.title, window.location.pathname);
    }
</script>

</body>
</html>