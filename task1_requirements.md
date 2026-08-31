# HW05 Task 1 - Yêu cầu thực hiện

Task 1 yêu cầu thiết kế, chạy và thu thập bằng chứng cho kiểm thử hiệu năng với AI hỗ trợ.

Điểm quan trọng nhất: không phải mỗi test plan kiểm tra một nhóm API riêng. Cả ba test plan Load, Stress và Spike đều phải chạy cùng một workflow end-to-end, đồng thời bao phủ đủ ba nhóm endpoint.

Ví dụ workflow phù hợp với EShop:

```text
POST /api/login                   -> Auth-heavy
GET  /api/products?search=...     -> Read-heavy
GET  /api/products/{id}           -> Read-heavy
POST /api/cart                    -> Transactional
POST /api/checkout                -> Transactional
```

## 1. Dùng AI thiết kế ba test plan

Phải hướng dẫn AI từng bước, không dùng một prompt chung chung, để tạo:

- Load Test.
- Stress Test.
- Spike Test.

AI hỗ trợ lựa chọn và giải thích:

- Số thread/virtual user.
- Ramp-up.
- Thời gian chạy.
- Think-time.
- Cách tạo spike.
- Điều kiện dừng hoặc xác định hệ thống quá tải.

Ba plan phải sử dụng cùng workflow, dữ liệu và assertions; chủ yếu khác nhau ở mô hình tải.

## 2. Làm workflow data-driven

Dùng ít nhất một file CSV để truyền dữ liệu, chẳng hạn:

```csv
email,password,search,product_id,quantity,total_amount,shipping_address
```

Nên có đủ tài khoản riêng cho số user chạy đồng thời, tránh tất cả thread dùng chung `test@eshop.com`.

Trong JMeter cần:

- Đọc dữ liệu bằng CSV Data Set Config.
- Trích xuất JWT sau khi login.
- Gửi `Authorization: Bearer ${token}` cho cart và checkout.
- Có assertions kiểm tra status code và nội dung JSON.
- Không chỉ kiểm tra request có kết nối thành công.

## 3. Dùng ba report view khác nhau

Mỗi plan phải có một listener/report type khác nhau, không được lặp:

| Test plan | Report view gợi ý |
| --- | --- |
| Load | Summary Report |
| Stress | Aggregate Report |
| Spike | View Results Tree |

View Results Tree không nên bật khi đo tải lớn vì nó tiêu tốn tài nguyên. Có thể chạy non-GUI, sau đó nạp JTL vào listener để xem.

## 4. Đặt tên đúng quy định

Với mã sinh viên `23127035` và ngày chạy ví dụ `20260829`:

```text
23127035_Load_20260829.jmx
23127035_Stress_20260829.jmx
23127035_Spike_20260829.jmx
```

Các file `.jtl` và thư mục HTML report nên dùng cùng tên tương ứng.

## 5. Human review bắt buộc

Sau khi AI tạo test plan, sinh viên phải tự kiểm tra và sửa. Báo cáo phải trình bày:

- AI làm sai hoặc thiếu điều gì.
- Sinh viên sửa như thế nào.
- Bằng chứng hoặc lý do sửa.
- Tại sao AI mắc lỗi.

Ví dụ lỗi cần tìm:

- Thread count quá cao hoặc không có căn cứ.
- Ramp-up không thực tế.
- Think-time không phù hợp.
- Assertions yếu.
- Không trích xuất JWT đúng.
- CSV không đủ tài khoản.
- Ba scenario thực chất chỉ là cùng một constant load được đổi tên.
- Không xử lý account lockout.

## 6. Chạy thật và thu thập bằng chứng

Phải chạy đủ Load, Stress và Spike. Mỗi lần chạy cần có:

- File raw `.jtl` đầy đủ.
- Thư mục HTML report.
- Ảnh chụp công cụ kiểm thử.
- Resource monitor của tiến trình backend trong cùng khung hình:
  - Activity Monitor trên macOS.
  - htop trên Linux.
  - Task Manager trên Windows.
- Thời điểm hoặc thông tin giúp đối chiếu screenshot với lần chạy.

Nếu Stress hoặc Spike làm tài khoản bị khóa sau ba lần đăng nhập sai:

- Reset trạng thái trước lần chạy tiếp theo.
- Ghi lại chính xác cách reset.
- Không được âm thầm sửa database rồi bỏ qua trong báo cáo.

## 7. Làm thêm endurance/soak test

Chạy tải ổn định khoảng 10-15 phút để tìm giới hạn phần cứng thực tế.

Phải báo bằng số đo thật, chẳng hạn:

- Maximum stable RPS.
- p95 response time.
- Error rate.
- CPU cao nhất hoặc ổn định.
- Memory ceiling.
- Thời điểm hệ thống bắt đầu mất ổn định.

Không được tự đặt threshold nếu chưa có raw log và resource evidence.

## 8. Hardware report

Cần:

- Screenshot screenfetch, dxdiag hoặc công cụ tương đương.
- Bảng thông số CPU, RAM, hệ điều hành và kiến trúc.
- Hostname phải khớp với bằng chứng triển khai ở homework trước.

## 9. Video demo

Upload video YouTube ở chế độ Unlisted:

- Tổng thời lượng ít nhất 6 phút.
- Có thể quay một video chung hoặc chia theo scenario.
- Công cụ test và resource monitor phải xuất hiện trong cùng khung hình.
- Phải dùng giọng thật của sinh viên để thuyết minh bằng tiếng Việt.
- Không được dùng video hoặc giọng AI tạo.

## 10. Báo lỗi nếu phát hiện

Nếu chạy test thấy lỗi thật như:

- HTTP error.
- Backend crash.
- Functional regression.
- Hệ thống không phục hồi sau spike.
- Latency hoặc error rate tăng bất thường.

Nên tạo GitHub Issue và đính kèm screenshot. Bug chức năng thật phải được báo; performance issue được khuyến khích nhưng không bị phạt nếu không tìm thấy.

## Đầu ra tối thiểu của Task 1

- [ ] 3 file JMX: Load, Stress và Spike.
- [ ] CSV test data.
- [ ] 3 raw JTL logs.
- [ ] 3 HTML report folders.
- [ ] Ảnh resource monitor của từng scenario.
- [ ] Hardware screenshot và spec table.
- [ ] Kết quả soak test 10-15 phút.
- [ ] Phần human review.
- [ ] Video YouTube ít nhất 6 phút.
- [ ] GitHub Issues nếu có lỗi thật.

## Nguồn

[2026.HW05.Performance Testing_En.pdf](./2026.HW05.Performance%20Testing_En.pdf)
