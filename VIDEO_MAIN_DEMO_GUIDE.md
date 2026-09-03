# Kịch bản chi tiết video demo chính HW05

## 1. Yêu cầu bắt buộc

- Thời lượng tối thiểu: **6 phút**. Nên quay khoảng **8-10 phút** để không phải nói quá nhanh.
- Dùng **giọng thật của sinh viên**, thuyết minh bằng tiếng Việt.
- Upload YouTube ở chế độ **Unlisted**.
- Phải cho thấy công cụ test và resource monitor trong cùng khung hình. Với các lần chạy đã hoàn tất, mở rõ các ảnh cùng khung đã lưu trong `evidence/screenshots/20260903/` và giải thích PID tương ứng.
- Chỉ trình bày evidence thật ngày `20260903`. Không gọi evidence cũ hoặc attempt bị loại là kết quả chính thức.
- Không cần chạy lại Load, Stress, Spike hoặc Soak trong lúc quay.

## 2. Chuẩn bị trước khi bấm quay

1. Bật Do Not Disturb và đóng các cửa sổ có thông tin riêng tư.
2. Đặt độ phân giải/zoom sao cho tên file, số liệu và PID đọc được.
3. Mở sẵn Finder tại thư mục `hw05`.
4. Mở sẵn các nội dung sau, nhưng chưa cần chuyển qua lại:
   - `main_report.md`;
   - `analysis/task1_metrics.md`;
   - ba JMX Load, Stress và Spike ngày `20260903`;
   - bốn HTML dashboard ngày `20260903`;
   - bốn ảnh cùng khung trong `evidence/screenshots/20260903/`;
   - `assets/task3_continuous_performance_flow.svg`;
   - Terminal tại `/Users/kunda/Documents/hw/hw05`.
5. Không mở toàn bộ JTL bằng editor nếu máy chậm. Dùng `wc`, `head` hoặc JMeter để chứng minh file raw tồn tại.
6. Kiểm tra microphone bằng một đoạn ghi thử ngắn.

Các lệnh chuẩn bị có thể dùng:

```bash
cd /Users/kunda/Documents/hw/hw05
open reports/23127035_Load_20260903/index.html
open reports/23127035_Stress_20260903/index.html
open reports/23127035_Spike_20260903/index.html
open reports/23127035_Soak_20260903/index.html
open evidence/screenshots/20260903
```

## 3. Timeline và lời thoại gợi ý

### 0:00-0:45 — Danh tính, đề tài và môi trường

**Thao tác trên màn hình**

Trong Terminal chạy lần lượt:

```bash
whoami
hostname
jmeter --version
pwd
```

Sau đó mở Activity Monitor và cho thấy ứng dụng này là công cụ dùng để quan sát tiến trình backend `node` khi chạy test.

**Lời thoại gợi ý**

> Em là sinh viên mã số 23127035. Đây là bài HW05 Performance Testing trên EShop. Các lần chạy chính thức được thực hiện ngày 03/09/2026 bằng Apache JMeter 5.6.3 trên máy Apple M4, RAM 16 GB. Backend được chạy cô lập tại port 3001, và Activity Monitor được dùng để theo dõi đúng PID của tiến trình Node.

Không nói rằng CPU/RSS là của toàn bộ máy; đó là số của tiến trình backend Node được theo dõi.

### 0:45-1:50 — Workflow WF-04 và cấu trúc JMeter

**Thao tác trên màn hình**

Mở `test-plans/23127035_Load_20260903.jmx` trong JMeter. Lần lượt chọn ở cây bên trái:

1. CSV Data Set Config;
2. JSON headers;
3. Think Time;
4. Thread Group Load;
5. `FR02 Login and correlate admin JWT`;
6. `FR16 Import one product`;
7. `FR05 Search imported product`;
8. `FR06 View imported product detail`;
9. Summary Report.

Mở rộng từng request vừa đủ để cho thấy thứ tự, không chỉnh sửa hoặc bấm Save.

**Lời thoại gợi ý**

> Workflow em chọn là WF-04: admin đăng nhập, import một sản phẩm, tìm đúng sản phẩm vừa import và mở trang chi tiết bằng ID đã correlate. Đây là một mục tiêu end-to-end thống nhất: phát hành sản phẩm và xác nhận nó xuất hiện đúng trong catalogue. CSV cung cấp tài khoản độc lập; tên sản phẩm được tạo duy nhất theo iteration. JWT được lấy từ response đăng nhập, còn product ID được lấy từ kết quả search. Các assertion kiểm tra HTTP 200, dữ liệu nghiệp vụ, tên, ID và giá sản phẩm. Think time 200 đến 500 mili giây được dùng nhất quán giữa các scenario.

Nêu rõ WF-04 khác ba workflow của nhóm đã cung cấp: cart/checkout, coupon/checkout và cancel order.

### 1:50-2:50 — Load

**Thao tác trên màn hình**

1. Cho thấy Thread Group của `23127035_Load_20260903.jmx`: 6 VUs, ramp-up 15 giây, chạy khoảng 120 giây.
2. Mở `reports/23127035_Load_20260903/index.html`.
3. Mở `evidence/screenshots/20260903/23127035_Load_20260903_tool_resource.png` ở kích thước đọc được.
4. Chỉ vào Terminal/JMeter và Activity Monitor trong cùng ảnh, cùng PID `24610`.

**Số liệu phải đọc đúng**

- 1,902 HTTP samples;
- 0 lỗi, error rate 0.00%;
- p95 5 ms, p99 6 ms;
- 15.93 samples/s, 3.97 completed workflows/s;
- peak CPU 7.5%, peak RSS 72.55 MB.

**Lời thoại gợi ý**

> Load test dùng 6 virtual users để kiểm tra tải ổn định thông thường. Kết quả có 1.902 HTTP samples, không có lỗi, p95 là 5 mili giây. Vì mỗi workflow đầy đủ có bốn HTTP request, em không gọi 15,93 samples mỗi giây là workflow throughput; completion thực tế được đếm bằng sampler FR06 cuối và đạt 3,97 workflow mỗi giây.

### 2:50-3:50 — Stress

**Thao tác trên màn hình**

1. Mở JMX Stress và chỉ ba stage 6, 12, 24 VUs.
2. Mở HTML dashboard Stress.
3. Mở ảnh `23127035_Stress_20260903_tool_resource.png`, chỉ PID `27079`.

**Số liệu phải đọc đúng**

- toàn bài: 6,489 samples, 0 lỗi, p95 5 ms, 36.19 samples/s;
- stage 6 VUs: 15.74 samples/s, p95 5 ms;
- stage 12 VUs: 31.09 samples/s, p95 5 ms;
- stage 24 VUs: 62.08 samples/s, p95 4 ms;
- peak CPU 14.0%, peak RSS 118.81 MB.

**Lời thoại gợi ý**

> Stress test tăng dần từ 6 lên 12 rồi 24 VUs. Giá trị 36,19 samples mỗi giây là trung bình của toàn bài, không phải throughput của mức tải cao nhất. Riêng stage 24 VUs đạt 62,08 samples mỗi giây, p95 4 mili giây và vẫn không có lỗi. Test chưa tìm thấy điểm sụp đổ nên em không khẳng định 24 VUs là giới hạn hệ thống.

### 3:50-4:50 — Spike

**Thao tác trên màn hình**

1. Mở JMX Spike, chỉ ba stage 3 → 30 → 3 VUs.
2. Mở HTML dashboard Spike.
3. Mở ảnh `23127035_Spike_20260903_tool_resource.png`, chỉ PID `31133`.

**Số liệu phải đọc đúng**

- toàn bài: 3,208 samples, 0 lỗi, p95 5 ms;
- baseline 3 VUs: 8.06 samples/s, p95 7 ms;
- burst 30 VUs: 83.04 samples/s, p95 5 ms;
- recovery 3 VUs: 8.66 samples/s, p95 5 ms;
- peak CPU 17.7%, peak RSS 101.23 MB.

**Lời thoại gợi ý**

> Spike test tăng đột ngột từ 3 lên 30 VUs rồi trở về 3 VUs. Phần burst đạt 83,04 samples mỗi giây. Recovery đạt 8,66 samples mỗi giây so với baseline 8,06, đồng thời p95 không xấu đi. Vì vậy trong phạm vi lần chạy này backend đã hồi phục sau spike. Em chỉ so recovery với baseline cùng 3 VUs, không so với trung bình toàn bài.

### 4:50-5:55 — Soak và resource evidence

**Thao tác trên màn hình**

1. Mở HTML dashboard Soak.
2. Mở ảnh `23127035_Soak_20260903_tool_resource.png`, chỉ PID `33539`.
3. Mở `analysis/task1_metrics.md` và chỉ dòng Soak.
4. Nếu cần, cho thấy resource CSV và database pre/post state trong Finder.

**Số liệu phải đọc đúng**

- 30 VUs, 410 iterations/thread;
- 613.82 giây;
- 49,200 samples, 0 lỗi;
- 12,300 completed workflows;
- p95 4 ms, p99 6 ms, max 33 ms;
- 80.15 samples/s, 20.04 workflows/s;
- CPU peak 28.2%;
- RSS start/peak/final 66.59/138.95/69.39 MB;
- products tăng từ 5 lên 12,305, khớp 12,300 import thành công.

**Lời thoại gợi ý**

> Soak duy trì 30 VUs trong 613,82 giây và hoàn tất đúng 12.300 workflow. Toàn bộ 49.200 samples đều thành công. Peak RSS là 138,95 MB nhưng cuối run giảm về 69,39 MB, vì vậy peak không được xem là memory ceiling hoặc bằng chứng memory leak. Kết quả chỉ chứng minh 30 VUs là mức ổn định cao nhất đã thử; chưa tìm thấy giới hạn tuyệt đối.

### 5:55-7:10 — Task 2: kiểm tra lại phân tích AI

**Thao tác trên màn hình**

Mở mục 10-12 trong `main_report.md`, sau đó chỉ vào `analysis/task2_metrics.md` hoặc raw JTL tương ứng.

Trình bày ít nhất ba correction:

1. `80.15 samples/s` không phải `80.15 workflows/s`; giá trị đúng là `20.04 workflows/s`.
2. Stress toàn bài `36.19 samples/s` không đại diện stage 24 VUs `62.08 samples/s`.
3. Spike toàn bài `26.91 samples/s` không đại diện burst `83.04 samples/s`.
4. Max 33 ms không phải p95; p95 Soak là 4 ms và p99 là 6 ms.
5. Các threshold trong báo cáo chỉ là regression gate đề xuất, không phải SLA.

Sau đó chỉ nhanh bảng optimization:

- transaction cho FR16: khả thi, nên thử trước;
- WAL và `busy_timeout`: khả thi nhưng phải benchmark;
- index `users(email)`: profile trước;
- B-tree cho `LIKE '%term%'`, coupon index bổ sung, connection pool kiểu client/server và clustered workers: không phải fix trực tiếp được evidence hiện tại chứng minh.

**Lời thoại gợi ý**

> Em không chấp nhận nguyên văn output AI. Em đối chiếu lại raw JTL, phân biệt sample throughput với workflow throughput, phân tích đúng từng stage và kiểm tra đề xuất tối ưu dựa trên source Express/SQLite. Đây là human review của em; các regression gate chỉ là đề xuất cho cùng môi trường test, không được gọi là SLA.

Chỉ nói câu xác nhận human review nếu bạn đã thật sự đọc và đồng ý với các bảng.

### 7:10-8:00 — Task 3: continuous performance testing

**Thao tác trên màn hình**

Mở `assets/task3_continuous_performance_flow.svg` và phóng to flowchart.

**Lời thoại gợi ý**

> Task 3 đề xuất pipeline theo mức rủi ro của commit. Thay đổi backend liên quan sẽ chạy Smoke trước; Smoke fail thì dừng. Pull request phù hợp chạy Load, thay đổi database hoặc import có thể thêm Stress, nightly chạy Stress và Spike, còn weekly hoặc release candidate chạy Soak. Kết quả chỉ so với baseline khi JMX, dataset, database seed và hardware fingerprint tương thích. Một p95 regression cần vượt cả ngưỡng tương đối lẫn tuyệt đối, sau đó chạy xác nhận lại. Baseline mới chỉ được chấp thuận bởi người review, không tự động học theo kết quả chậm hơn.

Nêu ngắn trade-off: chi phí chạy, false alarm, noisy neighbour, data drift và dung lượng artifact.

### 8:00-8:40 — Tính toàn vẹn và kết luận

**Thao tác trên màn hình**

Trong Terminal chạy:

```bash
wc -l results/23127035_Load_20260903.jtl \
  results/23127035_Stress_20260903.jtl \
  results/23127035_Spike_20260903.jtl \
  results/23127035_Soak_20260903.jtl
git log --oneline -12
```

Cho thấy các thư mục `results`, `reports`, `evidence/database`, `evidence/resource` và `evidence/inconclusive`.

**Lời thoại gợi ý**

> Báo cáo sử dụng raw evidence ngày 03/09/2026 và không trộn các attempt cũ. Attempt Soak bị clock jump được giữ riêng dưới evidence/inconclusive. Các database delta khớp số import thành công. Không có performance issue được mở vì các accepted sample đều pass và chưa có failure được tái hiện. Kết luận của em chỉ áp dụng cho workflow, dữ liệu, máy và cấu hình đã ghi nhận.

## 4. Những câu không nên nói

- Không nói “hệ thống chịu tối đa 30 users”; chỉ nói “30 VUs là mức cao nhất đã thử ổn định”.
- Không gọi samples/s là requests của người dùng hoặc workflows/s.
- Không gọi peak RSS là memory ceiling.
- Không nói AI đã tự quay/chụp evidence hoặc tự thực hiện human review.
- Không gọi regression gate đề xuất là SLA.
- Không nói WF-04 chắc chắn không trùng toàn lớp; chỉ xác nhận nó khác ba workflow nhóm đã cung cấp.

## 5. Checklist sau khi quay

- [ ] Video dài ít nhất 6 phút.
- [ ] Có giọng thật tiếng Việt, nghe rõ.
- [ ] MSSV, hostname, JMeter version và ngày chạy xuất hiện.
- [ ] Có đủ Load, Stress, Spike và Soak.
- [ ] Có JMX, raw JTL, HTML dashboard và resource evidence.
- [ ] Công cụ test và Activity Monitor xuất hiện cùng khung qua evidence thật.
- [ ] Có Task 2 human review và Task 3 flowchart.
- [ ] Không để lộ thông tin cá nhân không cần thiết.
- [ ] Upload YouTube ở chế độ Unlisted.
- [ ] Thử mở URL bằng cửa sổ ẩn danh.
- [ ] Chưa sửa PDF; chỉ thêm URL vào Markdown trước lần build PDF cuối.

