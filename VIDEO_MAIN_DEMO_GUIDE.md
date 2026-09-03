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

## 4:30-5:20 — Task 2: kiểm tra phân tích AI

**Mở:** mục 10-12 trong `main_report.md`.

**Nói:**

> Em không sử dụng nguyên văn kết luận AI mà đối chiếu lại với raw JTL. AI từng nhầm samples mỗi giây với workflows mỗi giây, dùng throughput trung bình của toàn bài để đại diện cho stage tải cao nhất và dùng maximum để kết luận về percentile.
>
> Sau khi kiểm tra, Soak đạt 80,15 samples mỗi giây nhưng chỉ có 20,04 workflow mỗi giây. Stress stage 24 VUs đạt 62,08 samples mỗi giây, còn Spike burst đạt 83,04 samples mỗi giây. Soak có maximum 33 mili giây nhưng p95 chỉ là 4 mili giây.
>
> Về tối ưu, transaction cho batch import và WAL với busy timeout là các thử nghiệm khả thi. B-tree thông thường không trực tiếp giải quyết truy vấn `LIKE` có wildcard ở đầu. Các threshold trong báo cáo chỉ là regression gate đề xuất cho cùng môi trường, không phải SLA.

## 5:20-6:00 — Task 3: continuous testing

**Mở:** `assets/task3_continuous_performance_flow.svg`.

**Nói:**

> Task 3 đề xuất pipeline theo mức rủi ro của commit. Thay đổi backend liên quan phải chạy Smoke trước; nếu Smoke fail thì dừng. Pull request chạy Load, thay đổi database hoặc import có thể thêm Stress, nightly chạy Stress và Spike, còn weekly hoặc release candidate chạy Soak.
>
> Chỉ so sánh performance khi source, JMX, dataset, database seed và môi trường tương thích. Một p95 regression phải vượt cả ngưỡng tương đối và tuyệt đối, sau đó được chạy xác nhận lại. Baseline mới phải do người review chấp thuận, không tự động thay bằng một kết quả chậm hơn.

## 6:00-6:30 — Kết luận

**Mở:** thư mục `results`, `reports`, `evidence` và Git log.

**Nói:**

> Toàn bộ kết luận sử dụng raw JTL, HTML report, database state và resource evidence ngày 03/09/2026. Những attempt cũ hoặc thiếu evidence được giữ riêng trong thư mục inconclusive và không trộn vào baseline. Các accepted run đều không có lỗi và database delta khớp số import thành công. Không có performance issue được mở vì chưa tái hiện được lỗi hoặc failure thật. Kết quả chỉ áp dụng cho workflow, dữ liệu, máy và cấu hình đã ghi nhận.

## Checklist trước khi upload

- [ ] Video dài ít nhất 6 phút.
- [ ] Có giọng thật tiếng Việt.
- [ ] Có đủ JMX, Load, Stress, Spike, Soak, Task 2 và Task 3.
- [ ] Có ảnh JMeter/Terminal và Activity Monitor trong cùng khung hình.
- [ ] Không gọi samples/s là workflows/s.
- [ ] Không nói 30 VUs là giới hạn tối đa.
- [ ] Upload YouTube ở chế độ Unlisted.
- [ ] Thử URL bằng cửa sổ ẩn danh.
- [ ] Thêm URL vào `README.md` và `main_report.md` trước khi tạo PDF cuối.
