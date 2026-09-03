# Kịch bản nói video demo chính HW05

Video dài khoảng **6-7 phút**, dùng giọng thật tiếng Việt. Các câu dưới đây là lời thoại gợi ý; nói tự nhiên, không cần đọc đúng từng chữ.

## 0:00-0:30 — Giới thiệu

**Mở:** Terminal và Activity Monitor.

**Nói:**

> Em là sinh viên mã số 23127035. Đây là bài HW05 Performance Testing cho hệ thống EShop. Em sử dụng Apache JMeter 5.6.3 trên máy Apple M4, RAM 16 GB. Các kết quả chính thức được chạy ngày 03/09/2026 trên backend cô lập tại port 3001. Activity Monitor được dùng để theo dõi đúng tiến trình Node của backend.

## 0:30-1:20 — Workflow và JMeter plan

**Mở:** `test-plans/23127035_Load_20260903.jmx` trong JMeter. Mở rộng bốn request FR02, FR16, FR05 và FR06.

**Nói:**

> Workflow em chọn là WF-04: admin đăng nhập, import một sản phẩm, tìm sản phẩm vừa import và mở chi tiết sản phẩm bằng ID đã correlate. Đây là một workflow end-to-end có một mục tiêu thống nhất: phát hành sản phẩm và xác nhận sản phẩm xuất hiện đúng trong catalogue.
>
> Dữ liệu tài khoản được đọc từ CSV. JWT được lấy từ response đăng nhập và gửi vào request import. Tên sản phẩm là duy nhất theo iteration. Product ID được lấy từ kết quả tìm kiếm rồi dùng cho request chi tiết. Các request có HTTP assertion và business assertion; think time là 200 đến 500 mili giây.

## 1:20-2:05 — Load test

**Mở:** HTML report Load và ảnh `23127035_Load_20260903_tool_resource.png`.

**Nói:**

> Load test sử dụng 6 virtual users, ramp-up 15 giây và chạy khoảng 120 giây. Kết quả có 1.902 HTTP samples, không có lỗi, p95 là 5 mili giây và p99 là 6 mili giây. Throughput là 15,93 samples mỗi giây và 3,97 workflow hoàn tất mỗi giây.
>
> Trong ảnh evidence, Terminal chạy JMeter và Activity Monitor theo dõi cùng backend PID 24610. Peak CPU là 7,5 phần trăm và peak RSS là 72,55 MB.

## 2:05-2:50 — Stress test

**Mở:** JMX/HTML report Stress và ảnh `23127035_Stress_20260903_tool_resource.png`.

**Nói:**

> Stress test tăng tải qua ba mức 6, 12 và 24 virtual users. Toàn bài có 6.489 samples, không có lỗi và p95 là 5 mili giây. Riêng stage 24 virtual users đạt 62,08 samples mỗi giây với p95 4 mili giây.
>
> Giá trị 36,19 samples mỗi giây là trung bình của toàn bài Stress, không phải throughput của stage 24 virtual users. Backend PID là 27079, peak CPU 14 phần trăm và peak RSS 118,81 MB. Test chưa đạt điểm sụp đổ nên em không xem 24 VUs là giới hạn tối đa.

## 2:50-3:35 — Spike test

**Mở:** JMX/HTML report Spike và ảnh `23127035_Spike_20260903_tool_resource.png`.

**Nói:**

> Spike test thay đổi đột ngột từ 3 lên 30 virtual users rồi trở về 3 virtual users. Toàn bài có 3.208 samples, không có lỗi và p95 là 5 mili giây. Burst 30 VUs đạt 83,04 samples mỗi giây.
>
> Recovery đạt 8,66 samples mỗi giây so với baseline 8,06 samples mỗi giây và p95 không xấu đi. Vì vậy hệ thống đã hồi phục trong phạm vi lần chạy này. Backend PID là 31133, peak CPU 17,7 phần trăm và peak RSS 101,23 MB.

## 3:35-4:30 — Soak test

**Mở:** HTML report Soak, `analysis/task1_metrics.md` và ảnh `23127035_Soak_20260903_tool_resource.png`.

**Nói:**

> Soak test duy trì 30 virtual users trong 613,82 giây. Kết quả có 49.200 HTTP samples, không có lỗi và hoàn tất đúng 12.300 workflow. p95 là 4 mili giây, p99 là 6 mili giây và giá trị lớn nhất là 33 mili giây.
>
> Throughput là 80,15 HTTP samples mỗi giây, nhưng workflow throughput chỉ là 20,04 workflow mỗi giây. Em phân biệt hai giá trị này vì một workflow đầy đủ có bốn HTTP request.
>
> Backend PID là 33539, peak CPU 28,2 phần trăm. RSS bắt đầu ở 66,59 MB, đạt peak 138,95 MB và kết thúc ở 69,39 MB. Vì bộ nhớ giảm lại sau test nên peak RSS không phải memory ceiling hoặc bằng chứng memory leak. Ba mươi VUs chỉ là mức ổn định cao nhất đã thử, không phải giới hạn tuyệt đối của hệ thống.

## 4:30-5:20 — Raw log và tính nhất quán dữ liệu

**Mở:** thư mục `results`, sau đó `evidence/database` và `evidence/resource`.

**Nói:**

> Đây là các raw JTL đầy đủ của Load, Stress, Spike và Soak, không chỉ có bảng summary. Mỗi scenario còn có HTML dashboard, resource CSV, backend log và database state trước và sau khi chạy.
>
> Mỗi lần chạy chính thức bắt đầu từ database sạch có 5 sản phẩm. Sau Load có 480 sản phẩm, tương ứng 475 import thành công. Sau Stress có 1.632 sản phẩm, tương ứng 1.627 import. Sau Spike có 814 sản phẩm, tương ứng 809 import. Sau Soak có 12.305 sản phẩm, tương ứng đúng 12.300 workflow hoàn tất. Các database delta này giúp xác nhận request không chỉ trả HTTP thành công mà còn tạo đúng thay đổi nghiệp vụ.

## 5:20-5:55 — Evidence và các lần chạy bị loại

**Mở:** bốn ảnh trong `evidence/screenshots/20260903`, sau đó thư mục `evidence/inconclusive`.

**Nói:**

> Mỗi ảnh chính thức đều đặt output JMeter hoặc Terminal cạnh Activity Monitor và lọc đúng backend PID. Đây là bằng chứng liên kết kết quả test với CPU và bộ nhớ của đúng tiến trình backend.
>
> Những lần chạy cũ, thiếu Activity Monitor hoặc bị ảnh hưởng bởi thay đổi đồng hồ hệ thống được giữ trong thư mục inconclusive nhưng không được trộn vào baseline ngày 03/09. Em không đổi tên log cũ để giả thành evidence mới.

## 5:55-6:30 — Kết luận Task 1

**Mở:** bảng tổng hợp trong `analysis/task1_metrics.md` và Git log.

**Nói:**

> Kết luận Task 1 là cả Load, Stress, Spike và Soak đều có error rate 0 phần trăm trong môi trường đã ghi nhận. Hệ thống xử lý ổn định mức cao nhất đã thử là 30 VUs trong hơn 10 phút, đạt 20,04 workflow hoàn tất mỗi giây, p95 4 mili giây, peak CPU 28,2 phần trăm và peak RSS 138,95 MB.
>
> Em không xem 30 VUs là giới hạn tuyệt đối vì test chưa tạo ra lỗi hoặc điểm sụp đổ. Không có GitHub performance issue được mở vì chưa có lỗi thật được tái hiện. Kết quả chỉ áp dụng cho WF-04, dữ liệu, phần cứng và cấu hình test đã trình bày.

## Checklist trước khi upload

- [ ] Video dài ít nhất 6 phút.
- [ ] Có giọng thật tiếng Việt.
- [ ] Có đủ JMX, Load, Stress, Spike và Soak của Task 1.
- [ ] Có ảnh JMeter/Terminal và Activity Monitor trong cùng khung hình.
- [ ] Không gọi samples/s là workflows/s.
- [ ] Không nói 30 VUs là giới hạn tối đa.
- [ ] Upload YouTube ở chế độ Unlisted.
- [ ] Thử URL bằng cửa sổ ẩn danh.
- [ ] Thêm URL vào `README.md` và `main_report.md` trước khi tạo PDF cuối.
