# Kịch bản chi tiết video demo Agent Skill

## 1. Mục tiêu của video

Chứng minh skill `jmeter-performance-testing` được dùng **end-to-end trên một endpoint group hoàn chỉnh**, không chỉ mở file `SKILL.md` và đọc nội dung. Video nên dài khoảng **3-5 phút**, dùng giọng thật tiếng Việt và upload YouTube **Unlisted**.

Demo này sử dụng toàn bộ WF-04:

```text
POST /api/login
  -> POST /api/admin/import-products
  -> GET /api/products?search=<unique imported name>
  -> GET /api/products/{correlated id}
```

Đây là demo audit chỉ-đọc trên evidence đã có. Không chạy lại performance test, không tạo JTL mới và không sửa artifact chính thức trong lúc quay.

## 2. Chuẩn bị trước khi quay

1. Mở Codex tại workspace `/Users/kunda/Documents/hw/hw05`.
2. Mở Terminal tại cùng thư mục.
3. Mở Finder hoặc editor tại:
   - `skills/jmeter-performance-testing/SKILL.md`;
   - `skills/jmeter-performance-testing/references/eshop-workflow.md`;
   - `skills/jmeter-performance-testing/references/hw05-deliverables.md`;
   - `skills/jmeter-performance-testing/scripts/analyze_jtl.py`;
   - `test-plans/23127035_Load_20260903.jmx`;
   - `results/23127035_Load_20260903.jtl`.
4. Đóng các cuộc trò chuyện hoặc cửa sổ có dữ liệu cá nhân.
5. Bật hiển thị con trỏ chuột nếu phần mềm quay có tùy chọn này.

Kiểm tra nhanh các file trước khi ghi:

```bash
cd /Users/kunda/Documents/hw/hw05
test -s skills/jmeter-performance-testing/SKILL.md
test -s test-plans/23127035_Load_20260903.jmx
test -s results/23127035_Load_20260903.jtl
jmeter --version
```

## 3. Prompt dùng trong video

Dán nguyên prompt sau vào Codex. Nếu giao diện không nhận skill theo tên, đường dẫn `SKILL.md` trong prompt vẫn buộc agent đọc đúng skill cục bộ.

```text
Hãy đọc và áp dụng skill tại skills/jmeter-performance-testing/SKILL.md để audit chỉ-đọc end-to-end endpoint group WF-04 trong HW05.

Phạm vi evidence:
- test-plans/23127035_Load_20260903.jmx
- results/23127035_Load_20260903.jtl
- reports/23127035_Load_20260903/
- evidence/database/ và evidence/resource/ tương ứng với Load 20260903
- source SUT tại ../hw04/eshop-sut-main

Hãy kiểm tra đủ bốn bước login -> import product -> exact search/correlate ID -> product detail; CSV, JWT, assertions, timer và thread model; sau đó chạy bundled JTL analyser của skill, đối chiếu raw log và báo samples, errors, p95, p99, samples/s và số completed workflows. Phân biệt sample throughput với workflow throughput. Cuối cùng phân loại ngắn các đề xuất transaction, WAL/busy_timeout, users(email) index và products(name) B-tree theo source thực tế.

Không sửa file, không chạy SUT/JMeter load test, không tạo evidence và không khẳng định human approval thay cho sinh viên. Trích rõ đường dẫn evidence đã dùng.
```

Nếu Codex đề nghị sửa file hoặc chạy lại test, nhắc lại: **“Chỉ audit read-only evidence hiện có.”**

## 4. Timeline và lời thoại gợi ý

### 0:00-0:35 — Giới thiệu skill

**Thao tác trên màn hình**

Mở `skills/jmeter-performance-testing/SKILL.md`, cho thấy phần front matter có tên và description, sau đó cuộn nhanh qua các mục Design, Review, Execute, Analyse và Continuous Testing.

**Lời thoại gợi ý**

> Đây là Agent Skill jmeter-performance-testing em xây dựng cho HW05. Skill hướng dẫn agent thiết kế, audit và phân tích JMeter dựa trên source và raw JTL. Nó cũng đặt ranh giới chống tạo giả: AI không được tự tạo screenshot, video, hardware evidence, Git history hoặc human approval.

### 0:35-1:05 — Cho thấy cấu trúc có thể tái sử dụng

**Thao tác trên màn hình**

Trong Terminal chạy:

```bash
find skills/jmeter-performance-testing -maxdepth 3 -type f | sort
```

Chỉ ra:

- `SKILL.md`: quy trình chính;
- `references/eshop-workflow.md`: mapping endpoint/source;
- `references/hw05-deliverables.md`: checklist đầu ra;
- `scripts/analyze_jtl.py`: analyser raw JTL không cần thư viện ngoài.

**Lời thoại gợi ý**

> Skill không chỉ là một prompt. Nó có reference cho SUT, checklist deliverable và một script phân tích JTL tái lập được. Vì vậy cùng quy trình có thể dùng lại cho một endpoint group khác mà vẫn giữ các quy tắc correlation, assertion và evidence.

### 1:05-1:35 — Gửi prompt end-to-end

**Thao tác trên màn hình**

Dán prompt ở mục 3 vào Codex và gửi. Trong lúc agent xử lý, giữ màn hình quay. Nếu thời gian chờ dài, có thể cắt phần đứng yên nhưng không cắt mất prompt hoặc output chính.

**Lời thoại gợi ý**

> Em yêu cầu skill audit toàn bộ WF-04, không chỉ một request. Phạm vi gồm JMX, raw JTL, HTML report, database/resource evidence và source HW04. Em giới hạn thao tác ở read-only để không thay đổi bằng chứng đã chấp nhận.

### 1:35-2:20 — Chứng minh analyser chạy trên raw JTL

Khi Codex thực hiện hoặc để đối chiếu thủ công, chạy trong Terminal:

```bash
python3 skills/jmeter-performance-testing/scripts/analyze_jtl.py \
  results/23127035_Load_20260903.jtl
```

Cuộn tới dòng `ALL` và các label FR02, FR16, FR05, FR06.

**Kết quả cần nhận diện**

- ALL: 1,902 samples;
- errors: 0;
- p95: 5 ms;
- p99: 6 ms;
- throughput xấp xỉ 15.93 samples/s;
- số workflow hoàn tất phải đếm theo FR06 thành công: 474;
- workflow throughput xấp xỉ 3.97 workflows/s.

**Lời thoại gợi ý**

> Script đọc trực tiếp CSV JTL và tính percentile theo nearest-rank. Dòng ALL là throughput của HTTP samples. Một workflow có bốn request nên skill không chia máy móc nếu iteration có thể dang dở; nó kiểm tra sampler FR06 cuối thành công và xác định 474 workflow hoàn tất, tương đương khoảng 3,97 workflow mỗi giây.

### 2:20-3:20 — Review output của agent

**Thao tác trên màn hình**

Quay lại output Codex và chỉ từng nhóm kết luận:

1. **Workflow completeness**: đủ FR02 → FR16 → FR05 → FR06 trong một iteration.
2. **Data/correlation**: CSV account, JWT admin, unique product name, exact match và correlated ID.
3. **Assertions/timer**: response code và business assertions; think time 200-500 ms.
4. **Workload**: Load 6 VUs, ramp-up 15 giây, khoảng 120 giây.
5. **Raw metrics**: 1,902 samples, 0 error, p95 5 ms, p99 6 ms.
6. **State consistency**: số product tăng tương ứng import thành công.

**Lời thoại gợi ý**

> Output cho thấy skill đi hết chuỗi từ kiểm tra thiết kế JMX, correlation và assertions, sang raw metric và trạng thái database. Mỗi kết luận đều phải dẫn về file nguồn hoặc evidence; HTML dashboard không thay thế raw JTL.

### 3:20-4:10 — Kiểm tra optimization và hallucination

**Thao tác trên màn hình**

Trong output, chỉ phần phân loại recommendation.

**Lời thoại gợi ý**

> Skill yêu cầu đối chiếu đề xuất với source Express và SQLite. Transaction cho batch import là thử nghiệm khả thi. WAL và busy timeout có thể benchmark nhưng không được hứa chắc sẽ cải thiện. Index users email cần profile vì dataset nhỏ. B-tree thông thường không phải fix trực tiếp cho truy vấn LIKE có wildcard ở đầu. Việc phân loại này ngăn AI đề xuất connection pool hoặc công nghệ không khớp kiến trúc hiện tại.

### 4:10-4:40 — Giới hạn AI và kết luận

**Thao tác trên màn hình**

Quay lại phần Completion Standard trong `SKILL.md`, rồi hiển thị đường dẫn raw JTL và screenshot thật trong Finder.

**Lời thoại gợi ý**

> Skill hỗ trợ phân tích và kiểm tra lặp lại, nhưng không thay thế sinh viên. Raw log, screenshot, hardware evidence, giọng nói và quyết định human review phải do em xác minh. Đây là một lần sử dụng end-to-end skill trên endpoint group WF-04 hoàn chỉnh.

## 5. Tiêu chí để demo được xem là end-to-end

Video phải cho thấy đủ chuỗi sau:

```text
Skill source
  -> prompt gọi đúng skill
  -> đọc JMX và source
  -> kiểm tra đủ bốn endpoint WF-04
  -> chạy analyser trên raw JTL
  -> kiểm tra metrics và workflow completion
  -> đánh giá recommendation theo source
  -> nêu ranh giới human evidence
```

Chỉ mở `SKILL.md`, đọc mô tả rồi kết thúc **không đủ** chứng minh end-to-end.

## 6. Checklist sau khi quay

- [ ] Có giọng thật tiếng Việt.
- [ ] Hiển thị rõ tên `jmeter-performance-testing` và đường dẫn skill.
- [ ] Prompt yêu cầu áp dụng skill xuất hiện đầy đủ.
- [ ] Có đủ bốn endpoint của WF-04.
- [ ] Có JMX, source và raw JTL trong phạm vi audit.
- [ ] Bundled analyser được chạy trên JTL thật ngày `20260903`.
- [ ] Phân biệt samples/s và workflows/s.
- [ ] Có ít nhất một feasible recommendation và một hallucinated/unsupported recommendation.
- [ ] Nêu rõ AI không tạo hoặc phê duyệt evidence thay sinh viên.
- [ ] Upload YouTube ở chế độ Unlisted và thử URL bằng cửa sổ ẩn danh.
- [ ] Thêm URL video Skill vào `README.md` và `main_report.md` trước khi dựng PDF cuối.
- [ ] Tạo commit riêng cho phần demo/URL sau khi video đã upload.

