TÀI LIỆU MÔ TẢ YÊU CẦU PHẦN MỀM (SRS) - DEADLINESYNC v2.0
1. GIỚI THIỆU
1.1 Mục đích
Tài liệu này định nghĩa các yêu cầu kỹ thuật và chức năng cho ứng dụng quản lý deadline thông minh tích hợp Gmail và AI (Gemini).
1.2 Phạm vi hệ thống
Ứng dụng di động (Android) giúp người dùng tập hợp, phân tích rủi ro và nhận gợi ý làm việc dựa trên dữ liệu từ Gmail và các deadline tự tạo.
2. MÔ TẢ TỔNG QUAN
2.1 Các tính năng chính (Core Functions)
•
Xác thực: Đăng nhập thông qua Google Account (Firebase Auth).
•
Tích hợp Gmail: Kết nối và quét Email theo khoảng thời gian tùy chọn (7 ngày hoặc 30 ngày).
•
Xử lý AI (Gemini-powered): Trích xuất thông tin deadline tự động từ nội dung Email.
•
Phân tích rủi ro: AI đánh giá mức độ rủi ro trễ hạn dựa trên mật độ công việc.
•
Gợi ý thông minh: AI đưa ra lời khuyên về thứ tự thực hiện công việc.
•
Quản lý Offline: Hỗ trợ xem và thao tác dữ liệu khi không có mạng qua SQLite.
2.2 Đối tượng người dùng
Sinh viên, nhân viên văn phòng và những người thường xuyên nhận yêu cầu công việc qua Email.
3. YÊU CẦU CHỨC NĂNG (FUNCTIONAL REQUIREMENTS)
3.1 Module Tích hợp & Đồng bộ (Gmail Integration)
•
REQ-1: Cho phép người dùng kết nối/ngắt kết nối với tài khoản Gmail.
•
REQ-2: Chức năng "Import chủ động": Quét Email theo khung thời gian 7 ngày hoặc 30 ngày gần nhất.
•
REQ-3: Chống trùng lặp: Hệ thống phải nhận diện ID Email để tránh import lại các deadline đã tồn tại.
3.2 Module AI (Gemini AI Engine)
•
REQ-4 (AI Extraction): Chuyển đổi nội dung Email thô thành JSON gồm: Tiêu đề, Ngày hạn chót, Mô tả công việc.
•
REQ-5 (Risk Analysis): Phân loại rủi ro (Thấp - Trung bình - Cao) dựa trên ngày hiện tại và số lượng task dồn dập.
•
REQ-6 (Smart Suggestion): Hiển thị lời khuyên cụ thể cho từng cá nhân để tối ưu hóa lịch trình.
3.3 Module Quản lý Deadline
•
REQ-7: Hiển thị Dashboard tổng hợp các deadline (Nguồn Gmail có logo Gmail, nguồn thủ công có icon riêng).
•
REQ-8: Cho phép người dùng xem lại (Review) danh sách deadline AI vừa tìm thấy trước khi chính thức lưu vào máy.
•
REQ-9: CRUD cơ bản: Thêm, xóa, sửa, đánh dấu hoàn thành deadline.
3.4 Module Dữ liệu & Thông báo
•
REQ-10: Lưu trữ local (SQLite) và đồng bộ đám mây (Firestore) khi có mạng.
•
REQ-11: Gửi thông báo đẩy (Notification) kèm nội dung cảnh báo rủi ro từ AI.
4. YÊU CẦU PHI CHỨC NĂNG (NON-FUNCTIONAL REQUIREMENTS)
•
Hiệu năng: Quá trình quét và phân tích AI không được làm treo giao diện chính (Sử dụng Loading state).
•
Bảo mật: Sử dụng OAuth 2.0, không lưu mật khẩu người dùng, chỉ xin quyền readonly đối với Gmail.
•
Trải nghiệm (UX): Giao diện Material 3, hỗ trợ Dark mode (tùy chọn).
5. PHÂN CHIA CÔNG VIỆC (DIVISION OF LABOR)
Thành viên
Vai trò
Trách nhiệm chính
Lê Nguyễn Quốc Toàn (A)
Leader / AI & Logic
Google OAuth, Gmail API, AI Gemini Integration (Extraction & Risk Analysis).
Tạ Minh Thiện (B)
UI/UX & Frontend
Design Figma, Dashboard UI, Integrations Page, AI Insights Visualization.
Nguyễn Hoàng Quân (C)
Data & System
Firebase Setup, SQLite Database, Firestore Sync, Notification Service.
6. KIẾN TRÚC HỆ THỐNG
•
Architecture: Clean Architecture (Domain - Data - Presentation).
•
State Management: Riverpod.
•
AI SDK: Google Generative AI (Gemini Pro).
•
Database: SQLite + Firebase Firestore.
