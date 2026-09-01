# HW05 - Những việc còn phải hoàn thành trước khi nộp

Đối chiếu ngày 2026-09-01 với đề `2026.HW05.Performance Testing_En.pdf` và trạng thái Git tại commit `4f1a70f`.

File này là checklist duy nhất cho phần còn lại. Các ô chỉ được đánh dấu hoàn thành sau khi có bằng chứng thật; không dùng ảnh, giọng nói, URL hoặc lời xác nhận do AI tạo.

## 1. Quyết định phạm vi trước khi làm tiếp

- [ ] Hỏi TA/giảng viên và lưu câu trả lời xác nhận rằng FR16 Product Import được chấp nhận là nhóm `transactional` cho HW05.

Lý do: workflow hiện tại là `Admin Login -> Import Product CSV -> Search Imported Product -> View Product Detail`. Nó coherent và không trùng ba workflow nhóm đã cung cấp, nhưng đề minh họa transactional bằng cart/checkout/order creation. FR16 là write-heavy và source hiện tại không bọc batch import trong một SQLite transaction rõ ràng. Đây là rủi ro chấm điểm lớn nhất.

- Nếu TA chấp nhận: giữ WF-04 và tiếp tục checklist bên dưới.
- Nếu TA không chấp nhận: phải chọn lại workflow coherent có cart/checkout/order creation, kiểm tra không trùng nhóm, rồi tạo và chạy lại JMX/JTL/HTML/evidence/report cho Task 1 và Task 2. Không được trộn kết quả WF-04 với workflow mới.

## 2. Phần bài hiện còn thiếu

### Task 3 - Continuous Performance Testing proposal (10 điểm)

- [ ] Viết proposal theo dõi commit của SUT và quyết định khi nào chạy performance test.
- [ ] Nêu smoke gate trước khi chạy Load/Stress/Spike hoặc soak.
- [ ] Mô tả cách so sánh p95 với baseline đã được duyệt và cách flag regression.
- [ ] Thêm flow chart thể hiện commit/change detection -> scope decision -> smoke -> performance run -> compare baseline -> lưu artifacts -> human review.
- [ ] Phân tích trade-off: chi phí runner, thời gian pipeline, false alarm, noisy neighbour, data drift, khác phần cứng, và quyền phê duyệt baseline.
- [ ] Đưa Task 3 vào phần conclusion của `main_report.md` và cập nhật `README.md`.
- [ ] Dựng lại `output/pdf/main_report.pdf`, render và kiểm tra bố cục.
- [ ] Tạo một commit Git riêng, message ngắn, cho Task 3.

### Agent Skill (10 điểm)

Skill `skills/jmeter-performance-testing/` đã có; còn thiếu bằng chứng sử dụng.

- [ ] Tự chạy skill end-to-end trên một endpoint group hoàn chỉnh và kiểm tra output.
- [ ] Quay demo cho lần sử dụng skill này và upload YouTube Unlisted. Cách an toàn nhất là video riêng; nếu ghép vào video chính thì phải có một đoạn được đánh dấu rõ và vẫn chứng minh đầy đủ end-to-end.
- [ ] Thêm link demo skill vào `README.md` và báo cáo.
- [ ] Tạo commit riêng cho phần demo/tài liệu Agent Skill.

## 3. Bằng chứng thật bắt buộc của sinh viên

### Ảnh từng scenario

Hiện repository không có ảnh Load, Stress hoặc Spike. Vì ảnh phải khớp lần chạy thật, không được chụp lại màn hình từ log cũ rồi mô tả là ảnh lúc chạy.

- [ ] Chạy/capture Load với JMeter hoặc terminal và Activity Monitor hiển thị đúng tiến trình backend `node` trong cùng khung hình.
- [ ] Chạy/capture Stress với hai thành phần trên trong cùng khung hình.
- [ ] Chạy/capture Spike với hai thành phần trên trong cùng khung hình.
- [ ] Ảnh phải đọc được scenario, thời gian, backend PID/resource usage và hostname khi có thể.
- [ ] Đặt ảnh vào một thư mục evidence rõ ràng và dẫn chiếu chúng trong main report.

Nếu phải chạy lại vào ngày khác 2026-09-01, tên JMX/JTL/report chính phải dùng ngày chạy thật theo `{StudentID}_{ScenarioType}_{YYYYMMDD}`; sau đó phải cập nhật metrics, report, PDF và commit. Không sửa timestamp bên trong raw log.

### Hardware evidence

- [ ] Chụp hardware report thật bằng System Information/screenfetch hoặc công cụ tương đương.
- [ ] Ảnh phải hiển thị hostname `MacBook-Air-cua-KunDa.local` và khớp bằng chứng deployment ở homework trước.
- [x] Bảng spec dạng text đã có tại `evidence/hardware/hardware_spec.md`.
- [ ] Đặt screenshot phần cứng vào evidence và dẫn chiếu trong main report.

### Video demo chính

- [ ] Quay ít nhất 6 phút, có giọng thật của sinh viên thuyết minh bằng tiếng Việt.
- [ ] Cho thấy JMX Load/Stress/Spike, raw JTL, HTML dashboards, soak result và resource monitor.
- [ ] Công cụ test và resource monitor phải xuất hiện trong cùng khung hình.
- [ ] Upload YouTube ở chế độ Unlisted.
- [ ] Thêm URL thật vào `README.md` và `main_report.md`.

Có thể dùng `demo_video_script.md` làm dàn ý, nhưng phải tự nói và tự quay.

### Human review

- [ ] Đọc bốn JMX chính và xác nhận thread count, ramp-up, timer, CSV sharing, correlation, assertions và listener đúng ý định của mình.
- [ ] Đối chiếu tám correction trong `task2_analysis_review.md` với `analysis/task2_metrics.md` và raw JTL.
- [ ] Đối chiếu tám optimization judgments với source HW04 được trích dẫn.
- [ ] Tự approve hoặc sửa phần human review trong `main_report.md` và `task2_analysis_review.md`.
- [ ] Đọc và tự approve hoặc sửa đoạn 247 từ trong `AI_Critique.md`.
- [ ] Ghi rõ trong báo cáo nội dung mình đã kiểm tra và các sửa đổi của mình; AI không được ký thay bước này.

## 4. Nội dung báo cáo và audit cần cập nhật

- [ ] Chèn nội dung AI Critique 200-300 từ vào main report hoặc appendix của main report; hiện critique mới tồn tại ở file/PDF riêng trong khi đề yêu cầu main report bao gồm critique.
- [ ] Cập nhật `AI_Audit.md` với các interaction sau commit `4f1a70f`, gồm tên AI tool, thời gian, prompt và tóm tắt output cho từng interaction.
- [ ] Sau các thay đổi, xuất lại `main_report.pdf`, `AI_Audit.pdf`, `AI_Critique.pdf` và các PDF liên quan; render để kiểm tra không cắt bảng/chồng chữ.
- [ ] Cập nhật self-assessment trong `README.md` đủ cả 6 tiêu chí: Load, Stress, Spike, Task 2, Task 3 và Agent Skill. Không tự chấm Task 3/Skill khi evidence chưa hoàn thành.
- [ ] Trong README ghi đủ: scenarios, endpoint groups, endurance threshold bằng số, số bug/performance issue, link video chính, link demo skill và public GitHub URL.
- [ ] Kiểm tra main report dẫn tới đúng ảnh, URL, raw JTL, HTML report và issue thật.

## 5. GitHub và issue

- [ ] Tạo/publish public GitHub repository bằng tài khoản của sinh viên; local repo hiện chưa có remote.
- [ ] Push toàn bộ commit và kiểm tra public link mở được khi chưa đăng nhập.
- [ ] Thêm public repository URL vào README/main report.
- [ ] Nếu sau khi tự xác minh có bug thật, tạo GitHub Issue kèm screenshot và link từ `bug_report.md`.
- [ ] Nếu không có issue performance trong accepted runs, giữ số issue là 0 và nói rõ 0 failure; performance issue không bắt buộc khi không phát hiện.
- [ ] Các source observation như thiếu admin-role enforcement chỉ được báo thành issue sau khi sinh viên tái hiện và xác nhận; không dùng nhận định AI thay evidence.

## 6. Git history

- [ ] Tạo commit riêng cho từng bước lớn còn lại: Task 3, evidence/document links, human review, và final packaging metadata.
- [ ] Sau commit cuối, cập nhật `git_commit_log.txt` từ `git log` mà không tự sửa hash hoặc timestamp.
- [ ] Chạy `git status --short` và bảo đảm working tree sạch.
- [ ] Push các commit lên public repository.

## 7. Đóng gói và nộp Moodle

- [ ] Chọn SelfAssessedGrade ba chữ số trong `[000,100]` dựa trên evidence thật.
- [ ] Tạo ZIP đúng tên `23127035_HW05_AI_Performance_<SelfAssessedGrade>.zip`.
- [ ] Kiểm tra ZIP có main report Markdown + PDF, AI Critique Markdown + PDF, AI Audit Markdown + PDF, README, public GitHub link, ba JMX Load/Stress/Spike, ba raw JTL tương ứng, ba HTML report folders, CSV data, resource/hardware screenshots, video URL, git commit log, bug report và supporting materials.
- [ ] Mở thử file ZIP ở thư mục tạm và kiểm tra các PDF/JTL/HTML không hỏng.
- [ ] Đảm bảo không chỉ nộp summary: ba raw JTL phải có đầy đủ.
- [ ] Nộp ZIP lên đúng submission link trên Moodle trước deadline hiển thị ở đó.
- [ ] Giữ local repo, video và evidence để chuẩn bị oral defense 5-7 phút nếu nằm trong 30% được chọn.

## 8. Phần kỹ thuật đã có, không cần làm lại nếu scope được TA chấp nhận

- [x] CSV data-driven với 80 admin accounts.
- [x] Load, Stress và Spike JMX dùng cùng WF-04 và ba listener/report view khác nhau.
- [x] Raw JTL và HTML report cho Load, Stress, Spike; thêm Smoke và Soak hỗ trợ.
- [x] Assertions/correlation cho JWT, admin role, import result, product ID/name/price.
- [x] Resource CSV/log và database pre/post state cho các run.
- [x] Soak khoảng 10 phút: 30 VUs, 618.94 giây, 12,300 workflow hoàn chỉnh, p95 4 ms, 0 failure.
- [x] Task 2 AI first pass, tám metric corrections, threshold proposal và tám optimization judgments.
- [x] AI Critique 247 từ và AI Audit hiện có đến lần cập nhật workflow.
- [x] Agent Skill source đã có.
- [x] Local Git repository và commit log đã có.

## Thứ tự nên thực hiện

1. Xác nhận rủi ro transactional của WF-04 với TA.
2. Làm Task 3 và cập nhật main report.
3. Chạy/capture evidence thật, chụp hardware và quay hai phần demo cần thiết.
4. Tự human-review Task 1/Task 2/critique.
5. Publish GitHub, thêm các URL và hoàn thiện README/audit.
6. Dựng lại PDF, commit, cập nhật commit log, đóng gói ZIP và nộp Moodle.
