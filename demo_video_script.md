# Kịch bản demo Task 1 (6-7 phút)

## 0:00-0:40 - Danh tính và môi trường

Mở Terminal, chạy `whoami`, `hostname`, `jmeter --version`, sau đó mở Activity Monitor và lọc tiến trình `node`. Nói rõ MSSV `23127035`, SUT EShop, ngày chạy `2026-09-03`, máy Apple M4/16 GB.

## 0:40-1:40 - Workflow và dữ liệu

Mở `data/performance_users.csv` và một JMX. Giải thích hành trình chung:

`WF-04: FR02 admin login/JWT -> FR16 import -> FR05 exact search/ID correlation -> FR06 product detail`.

Giải thích đây là một mục tiêu end-to-end: admin phát hành sản phẩm rồi xác minh nó xuất hiện trong catalogue. Chỉ ra CSV Data Set Config, JWT/role, unique product name, correlated product ID, HTTP 200 assertions và business assertions.

## 1:40-2:30 - Human review

Trình bày ba correction thật:

- loại luồng FR03-FR09-FR16 vì không có một mục tiêu nghiệp vụ thống nhất;
- dùng đúng ngày chạy thật `20260903` cho JMX/JTL/HTML và không đổi tên log cũ để giả ngày;
- loại soak scheduler bị clock-jump và rerun bằng 410 vòng/thread.

## 2:30-4:30 - Ba run chính thức

Mở lần lượt ba JMX và HTML dashboard:

- Load: 6 VU, ramp 15 s, 120 s, Summary Report;
- Stress: 6 -> 12 -> 24 VU, mỗi bậc 60 s, Aggregate Report;
- Spike: 3 -> 30 -> 3 VU, View Results Tree disabled trong non-GUI rồi nạp JTL sau.

Đọc sample count, error rate, throughput, p95 và resource peak đúng theo `analysis/task1_metrics.md`. Đặt cửa sổ kết quả cạnh Activity Monitor khi quay.

## 4:30-5:40 - Soak 10 phút

Mở JTL/HTML của Soak, resource CSV và đồ thị. Nói rõ 30 VU là mức ổn định cao nhất **đã thử**, không phải giới hạn tuyệt đối của phần cứng. Phân biệt 80.15 sample/s với 20.04 completed workflow/s; một workflow đủ có 4 HTTP samples và completion được đếm bằng sampler FR06 cuối.

## 5:40-6:30 - Kết luận và integrity

Cho xem raw JTL, database pre/post state, Git log và hostname. Nêu rằng attempt Soak bị clock-jump đã được giữ trong `evidence/inconclusive`; các accepted run đều dùng database reset sạch trên port 3001. Kết thúc bằng nguyên tắc: kiểm tra tính nhất quán của business workflow trước, sau đó mới tin kết quả performance.
