# Kịch bản demo Task 1 (6-7 phút)

## 0:00-0:40 - Danh tính và môi trường

Mở Terminal, chạy `whoami`, `hostname`, `jmeter --version`, sau đó mở Activity Monitor và lọc tiến trình `node`. Nói rõ MSSV `23127035`, SUT EShop, ngày chạy `2026-08-31`, máy Apple M4/16 GB.

## 0:40-1:40 - Workflow và dữ liệu

Mở `data/performance_users.csv` và một JMX. Giải thích hành trình chung:

`FR03 forgot -> reset -> login/JWT -> FR09 apply coupon -> FR16 import -> GET search verify`.

Chỉ ra CSV Data Set Config, dynamic `resetToken`, JWT/user ID, unique product name, HTTP 200 assertions và business assertions.

## 1:40-2:30 - Human review

Trình bày ba correction thật:

- đưa CSV/header/timer từ thread group đầu lên Test Plan scope;
- thêm database readiness gate vì initializer bất đồng bộ đã làm attempt 1 inconclusive;
- đổi soak từ 6 lên 30 VU sau khi spike 30 VU pass 0 lỗi.

## 2:30-4:30 - Ba run chính thức

Mở lần lượt ba JMX và HTML dashboard:

- Load: 6 VU, ramp 15 s, 120 s, Summary Report;
- Stress: 6 -> 12 -> 24 VU, mỗi bậc 60 s, Aggregate Report;
- Spike: 3 -> 30 -> 3 VU, View Results Tree disabled trong non-GUI rồi nạp JTL sau.

Đọc sample count, error rate, throughput, p95 và resource peak đúng theo `analysis/task1_metrics.md`. Đặt cửa sổ kết quả cạnh Activity Monitor khi quay.

## 4:30-5:40 - Soak 10 phút

Mở JTL/HTML của Soak, resource CSV và đồ thị. Nói rõ 30 VU là mức ổn định cao nhất **đã thử**, không phải giới hạn tuyệt đối của phần cứng. Phân biệt sample/s với completed workflow/s (một workflow đủ có 6 HTTP sample).

## 5:40-6:30 - Kết luận và integrity

Cho xem raw JTL, database pre/post state, Git log và hostname. Nêu rằng attempt Load đầu bị loại nhưng được giữ nguyên trong `evidence/inconclusive`; ba official run dùng database reset sạch và không bị account lockout. Kết thúc bằng nhận xét ngắn về việc luôn smoke, audit scope và đối chiếu raw log trước khi tin output AI.
