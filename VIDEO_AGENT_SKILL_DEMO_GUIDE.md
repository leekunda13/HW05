# Kịch bản ngắn video demo Agent Skill

Video khoảng **3-4 phút**, dùng giọng thật tiếng Việt và upload YouTube ở chế độ **Unlisted**.

## 0:00-0:30 — Giới thiệu skill

**Mở:** `skills/jmeter-performance-testing/SKILL.md`.

**Chỉ vào:** tên `jmeter-performance-testing`, phần description và các mục Design, Review, Analyse.

**Nói:**

> Đây là Agent Skill jmeter-performance-testing em xây dựng cho HW05. Skill hỗ trợ thiết kế, kiểm tra và phân tích JMeter từ source và raw JTL. Skill không được tự tạo giả log, screenshot, video, hardware evidence hoặc human review.

## 0:30-0:55 — Cấu trúc skill

**Mở:** thư mục `skills/jmeter-performance-testing` trong Finder hoặc editor.

**Chỉ vào:**

- `SKILL.md`;
- `references/eshop-workflow.md`;
- `references/hw05-deliverables.md`;
- `scripts/analyze_jtl.py`.

**Nói:**

> Skill gồm quy trình chính, reference mô tả endpoint EShop, checklist bài nộp và script phân tích raw JTL. Các thành phần này giúp dùng lại cùng quy trình cho những endpoint group khác.

## 0:55-1:25 — Gọi skill trong Codex

**Mở:** Codex tại workspace `hw05`.

**Dán prompt:**

```text
Hãy đọc và áp dụng skill tại skills/jmeter-performance-testing/SKILL.md để audit read-only WF-04 từ test-plans/23127035_Load_20260903.jmx và results/23127035_Load_20260903.jtl. Kiểm tra đủ login -> import product -> exact search/correlate ID -> product detail, CSV, JWT, assertions, timer và workload. Chạy analyser của skill, báo samples, errors, p95, p99, samples/s và completed workflows. Phân biệt sample throughput với workflow throughput. Không sửa file hoặc tạo evidence.
```

**Chỉ vào:** nội dung prompt có đường dẫn skill, JMX, JTL và đủ bốn bước WF-04.

**Nói:**

> Em yêu cầu skill audit toàn bộ endpoint group WF-04 ở chế độ chỉ đọc. Input gồm JMX và raw JTL thật ngày 03/09/2026. Skill phải kiểm tra cả thiết kế test lẫn kết quả, không chỉ đọc dashboard.

## 1:25-2:05 — Chạy analyser trên raw JTL

**Mở:** Terminal tại thư mục `hw05`.

**Chạy:**

```bash
python3 skills/jmeter-performance-testing/scripts/analyze_jtl.py \
  results/23127035_Load_20260903.jtl
```

**Chỉ vào:** dòng `ALL` và bốn dòng FR02, FR16, FR05, FR06.

**Nói:**

> Analyser đọc trực tiếp raw JTL. Load có 1.902 HTTP samples, 0 lỗi, p95 5 mili giây, p99 6 mili giây và 15,93 samples mỗi giây. Sampler FR06 cuối thành công 474 lần, nên có 474 workflow hoàn tất, tương đương khoảng 3,97 workflow mỗi giây.

## 2:05-2:50 — Kiểm tra output của skill

**Mở:** kết quả trả lời của Codex.

**Chỉ vào:**

1. Chuỗi FR02 → FR16 → FR05 → FR06;
2. CSV và JWT correlation;
3. unique product name và correlated product ID;
4. HTTP/business assertions;
5. p95, p99, samples/s và completed workflows.

**Nói:**

> Output xác nhận bốn request nằm trong cùng một workflow. JWT từ login được dùng cho import; product ID được correlate từ exact search rồi dùng cho product detail. Skill cũng kiểm tra assertions và think time. Kết quả phân biệt 15,93 HTTP samples mỗi giây với 3,97 workflow mỗi giây.

Nếu output thiếu một trong các nội dung trên, yêu cầu Codex bổ sung trước khi kết thúc video.

## 2:50-3:20 — Kết luận

**Mở:** lại `SKILL.md`, sau đó mở thư mục `results` và `evidence`.

**Chỉ vào:** quy tắc không tạo giả evidence và các JTL/screenshot thật.

**Nói:**

> Đây là một lần sử dụng Agent Skill end-to-end trên endpoint group WF-04 hoàn chỉnh: nhận JMX và raw JTL, kiểm tra workflow, chạy phân tích và đối chiếu kết quả. Skill hỗ trợ tự động hóa nhưng raw log, screenshot, giọng nói và quyết định human review vẫn do sinh viên xác minh.

## Checklist trước khi upload

- [ ] Có giọng thật tiếng Việt.
- [ ] Có tên và cấu trúc của skill.
- [ ] Prompt gọi đúng `SKILL.md` xuất hiện trên màn hình.
- [ ] Có đủ FR02, FR16, FR05 và FR06.
- [ ] Có lệnh analyser chạy trên JTL thật.
- [ ] Nói đúng 1.902 samples, 0 lỗi, p95 5 ms và 474 workflows.
- [ ] Phân biệt samples/s với workflows/s.
- [ ] Upload YouTube Unlisted và thử URL bằng cửa sổ ẩn danh.
- [ ] Thêm URL vào `README.md` và `main_report.md` trước khi tạo PDF cuối.
