# HW05 Task 1 - Agent Skill Prompts

## Cách sử dụng

Mở Codex tại thư mục `hw05`:

```bash
cd "/Users/kunda/Documents/hw/hw05"
```

Chạy `/skills` và kiểm tra skill `jmeter-performance-testing` xuất hiện. Nếu chưa thấy, restart Codex hoặc mở thread mới.

Không gửi một prompt chung chung để làm toàn bộ Task 1. Dùng lần lượt bốn prompt bên dưới, kiểm tra output và ghi nhận human review sau mỗi giai đoạn.

Các artifact sau phải được tạo từ quá trình thực thi thật, không được AI tạo giả: raw JTL, HTML report, screenshot công cụ/resource monitor, hardware evidence, Git history và video có giọng sinh viên.

## Prompt 1 - Phân tích và thiết kế

```text
Sử dụng $jmeter-performance-testing để thực hiện GIAI ĐOẠN 1
của HW05 Task 1 - phân tích SUT và thiết kế performance workflow.

Thông tin:
- Student ID: 23127035
- Đề bài: 2026.HW05.Performance Testing_En.pdf
- SUT source: ../hw04/eshop-sut-main
- Backend dự kiến: http://127.0.0.1:3000
- Công cụ: JMeter
- Bộ feature đã chọn: FR03, FR09, FR16
- Workflow này đã được nhóm xác nhận không trùng.
  Nếu chưa có bằng chứng xác nhận thì đánh dấu là việc sinh viên còn phải làm,
  không được tự tuyên bố đã xác nhận.

Workflow dự kiến dùng cho cả Load, Stress và Spike:
1. FR03: POST /api/forgot-password
2. Trích xuất resetToken từ response
3. FR03: POST /api/reset-password
4. POST /api/login và trích xuất JWT cùng user ID
5. FR09: POST /api/apply-coupon
6. FR16: POST /api/admin/import-products bằng admin token
7. GET /api/products?search=${imported_product} để kiểm tra kết quả import
   và đáp ứng nhóm read-heavy.

Yêu cầu của giai đoạn này:
1. Đọc kỹ đề bài, SKILL.md, references của skill và source backend thật.
2. Xác minh chính xác request method, URL, header, request body,
   authentication và response cần correlation.
3. Lập bảng ánh xạ endpoint thành auth-heavy, read-heavy và transactional.
4. Đánh giá tính hợp lý của workflow FR03-FR09-FR16 và ghi rõ
   các hạn chế cần bảo vệ trong báo cáo.
5. Xác định state risk:
   - reset mật khẩu;
   - account lockout;
   - coupon usage;
   - quyền admin của FR16;
   - database tăng dữ liệu sau mỗi lần import;
   - concurrent virtual users dùng chung tài khoản.
6. Đề xuất CSV schema và cách tạo đủ tài khoản độc lập cho peak users.
7. Đề xuất assertions, JSON extraction và cleanup/reset database.
8. Đề xuất smoke test 1 user/1 iteration.
9. Chưa tạo Load/Stress/Spike JMX và chưa chạy performance test.
10. Không tạo giả JTL, report, screenshot, hardware evidence,
    video, Git commit hoặc số liệu hiệu năng.
11. Tạo file Markdown lưu kết quả thiết kế trong hw05 và chỉ rõ
    những quyết định nào cần tôi human-review.
12. Sau khi hoàn thành giai đoạn 1 thì dừng lại để tôi kiểm tra.
```

Sau khi Agent hoàn thành, đọc kết quả và yêu cầu sửa các điểm chưa hợp lý. Giữ lại phần trao đổi này làm bằng chứng human review và AI Audit.

## Prompt 2 - Tạo CSV, smoke test và JMX

```text
Tiếp tục sử dụng $jmeter-performance-testing cho GIAI ĐOẠN 2.

Tôi đã human-review thiết kế giai đoạn 1. Hãy:
1. Ghi lại các nhận xét và chỉnh sửa của tôi vào phần Human Review.
2. Kiểm tra JMeter đã được cài đặt; nếu chưa có thì báo prerequisite
   và xin phép trước khi cài.
3. Tạo CSV data-driven với tài khoản riêng cho virtual users.
4. Không đưa credential cá nhân hoặc secret thật vào Git.
5. Tạo smoke-test JMX cho workflow FR03-FR09-FR16.
6. Kiểm tra resetToken, JWT, user ID, admin token và imported product
   đều được correlate động.
7. Thêm assertions cho status code, JSON fields và business result.
8. Chạy trước 1 user, 1 iteration.
9. Đọc kết quả smoke test và phân biệt automation fault với SUT defect.
10. Chỉ khi smoke test hợp lệ mới tạo ba plan:
    23127035_Load_<ngày-chạy-thật>.jmx
    23127035_Stress_<ngày-chạy-thật>.jmx
    23127035_Spike_<ngày-chạy-thật>.jmx
11. Ba plan phải dùng cùng workflow và CSV schema.
12. Dùng ba listener khác nhau, không lặp loại.
13. Chưa chạy official Load/Stress/Spike cho đến khi tôi duyệt JMX.
14. Không tạo giả execution evidence.
```

## Prompt 3 - Audit ba test plan

```text
Tiếp tục sử dụng $jmeter-performance-testing cho GIAI ĐOẠN 3.

Audit ba JMX vừa tạo trước khi chạy:
1. So sánh workload model của Load, Stress và Spike.
2. Kiểm tra thread count, ramp-up, duration và think-time có căn cứ.
3. Kiểm tra ba scenario không chỉ là cùng một constant load đổi tên.
4. Kiểm tra CSV không bị recycle ngoài ý muốn.
5. Kiểm tra tài khoản, reset password, coupon và import data được cô lập.
6. Kiểm tra JWT/admin token và assertions.
7. Kiểm tra View Results Tree không chạy trong lúc đo tải lớn.
8. Liệt kê rõ AI đã làm sai/thiếu gì, cách sửa và nguyên nhân.
9. Chưa chạy official test; dừng để tôi human-review lần cuối.
```

## Prompt 4 - Chạy Task 1

Chỉ gửi prompt này sau khi backend, JMeter và Activity Monitor đã sẵn sàng.

```text
Tiếp tục sử dụng $jmeter-performance-testing cho GIAI ĐOẠN 4.

Tôi đã duyệt ba JMX. Hãy hỗ trợ chạy Task 1 bằng dữ liệu và
môi trường thật:

1. Kiểm tra backend http://127.0.0.1:3000 đang hoạt động.
2. Ghi lại trạng thái database trước mỗi scenario.
3. Hướng dẫn tôi mở Activity Monitor và đặt cạnh terminal/JMeter
   để tự chụp bằng chứng thật.
4. Chờ tôi xác nhận đang ghi hình trước mỗi official run.
5. Chạy lần lượt Load, Stress và Spike bằng JMeter non-GUI.
6. Không ghi đè kết quả cũ.
7. Giữ nguyên full raw JTL.
8. Tạo một HTML report folder cho mỗi scenario.
9. Sau mỗi run, kiểm tra file tồn tại, số sample, error rate,
   throughput, average, p90, p95, p99 và response codes.
10. Reset database/account state giữa các run bằng quy trình đã duyệt.
11. Không tự tuyên bố screenshot hoặc video đã hoàn thành.
12. Nếu run bị gián đoạn hoặc thiếu resource evidence,
    đánh dấu inconclusive thay vì tạo số liệu.
13. Sau ba scenario, chuẩn bị soak test 10-15 phút nhưng chờ tôi
    xác nhận trước khi chạy.
14. Cập nhật Task 1 report và AI Audit bằng dữ liệu thật.
```

## Việc sinh viên phải tự làm

- Xác nhận workflow không trùng với thành viên khác.
- Human-review output sau mỗi giai đoạn.
- Chụp công cụ và backend resource monitor trong cùng khung hình.
- Ghi hardware evidence có đúng hostname.
- Thu âm lời thuyết minh tiếng Việt bằng giọng thật.
- Upload video YouTube ở chế độ Unlisted.
- Kiểm tra và chịu trách nhiệm về test plan, kết quả và báo cáo cuối cùng.

## Tài liệu về Codex Skills

- [OpenAI - Build skills](https://learn.chatgpt.com/docs/build-skills)
