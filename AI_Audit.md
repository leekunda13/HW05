# AI Audit Report - HW05 Tasks 1-3

## Declaration

I use **OpenAI Codex** for assignment/SUT analysis, JMeter generation and review, run orchestration, raw JTL analysis, workflow correction, misinterpretation review preparation, optimization classification, continuous-performance proposal design, and report drafting. Apache JMeter 5.6.3 generated real traffic; SQLite and macOS process tools captured database and resource evidence.

AI did not create screenshots, narration, YouTube links, group records, or a student's approval statement.

## Student prompts

```text
tóm tắt chi tiết session này
```

tool: Codex
time: 31/8 - 3/9/2026

 # Tổng kết chi tiết session HW05

  ## 1. Phạm vi và workflow

  Workflow ban đầu dùng FR03–FR09–FR16 nhưng không tạo thành một hành trình nghiệp vụ thống nhất. Sau khi đối chiếu ba workflow của nhóm:

  - WF-01: Login → Product → Server Cart → Checkout
  - WF-02: Login → Product → Coupon → Checkout → Coupon Usage
  - WF-03: Login → Product → Checkout → Cancel Order

  Workflow được đổi thành:

  WF-04:
  Admin Login
  → Import Product
  → Search Imported Product
  → View Product Detail

  WF-04 có mục tiêu end-to-end rõ ràng: admin phát hành sản phẩm và xác nhận sản phẩm xuất hiện chính xác trong catalogue.

  ## 2. Task 1 – JMeter performance testing

  Đã hoàn thiện các test plan ngày 20260903:

  23127035_Smoke_20260903.jmx
  23127035_Load_20260903.jmx
  23127035_Stress_20260903.jmx
  23127035_Spike_20260903.jmx
  23127035_Soak_20260903.jmx

  Các JMX đều sử dụng:

  - CSV chứa 80 tài khoản admin.
  - JWT correlation từ FR02 Login.
  - Tên sản phẩm duy nhất theo iteration.
  - Product ID correlation từ FR05 Search.
  - FR06 kiểm tra đúng ID, tên và giá sản phẩm.
  - HTTP assertions và business assertions.
  - Think time 200–500 ms.
  - Backend cô lập trên port 3001.

  ### Kết quả được chấp nhận

   Scenario    Samples    Errors     p95     p99    Samples/s    Workflows/s
  ━━━━━━━━━━  ━━━━━━━━━  ━━━━━━━━  ━━━━━━  ━━━━━━  ━━━━━━━━━━━  ━━━━━━━━━━━━━
   Load          1,902         0    5 ms    6 ms        15.93           3.97
  ──────────  ─────────  ────────  ──────  ──────  ───────────  ─────────────
   Stress        6,489         0    5 ms    6 ms        36.19           8.96
  ──────────  ─────────  ────────  ──────  ──────  ───────────  ─────────────
   Spike         3,208         0    5 ms    6 ms        26.91           6.61
  ──────────  ─────────  ────────  ──────  ──────  ───────────  ─────────────
   Soak         49,200         0    4 ms    6 ms        80.15          20.04

  ### Stage metrics quan trọng

  Stress:

  - 6 VUs: 15.74 samples/s.
  - 12 VUs: 31.09 samples/s.
  - 24 VUs: 62.08 samples/s.

  Spike:

  - Baseline 3 VUs: 8.06 samples/s.
  - Burst 30 VUs: 83.04 samples/s.
  - Recovery 3 VUs: 8.66 samples/s.

  Soak:

  - 30 VUs.
  - 410 iterations/thread.
  - 613.82 giây.
  - 12,300 workflow hoàn tất.
  - Maximum response time 33 ms.
  - Không có assertion failure.

  Kết luận được giới hạn đúng: 30 VUs là mức ổn định cao nhất đã thử, không phải giới hạn tuyệt đối của hệ thống.

  ## 3. Resource monitoring

  scripts/run_official.sh được dùng để:

  - Khởi động backend Node cô lập.
  - Lấy đúng backend PID.
  - Chạy JMeter non-GUI.
  - Ghi raw JTL và HTML dashboard.
  - Lấy mẫu CPU/RAM backend mỗi giây.
  - Ghi database state trước và sau.
  - Dừng backend sau khi hoàn tất.
  - Ngăn ghi đè evidence cũ.

  Phân biệt:

  - JMeter là tiến trình Java tạo HTTP traffic.
  - node là backend EShop chịu tải.
  - JTL chứa response time, success/error, response code và bytes.
  - Resource CSV chứa CPU, RSS, VSZ của backend Node.

  Trong resource CSV:

  - rss_kb: lượng RAM vật lý Node đang thực dùng.
  - vsz_kb: không gian bộ nhớ ảo; không đại diện RAM thực tế.

  ### Resource peak

   Scenario    Backend PID    Peak CPU     Peak RSS
  ━━━━━━━━━━  ━━━━━━━━━━━━━  ━━━━━━━━━━  ━━━━━━━━━━━
   Load              24610        7.5%     72.55 MB
  ──────────  ─────────────  ──────────  ───────────
   Stress            27079       14.0%    118.81 MB
  ──────────  ─────────────  ──────────  ───────────
   Spike             31133       17.7%    101.23 MB
  ──────────  ─────────────  ──────────  ───────────
   Soak              33539       28.2%    138.95 MB

  Đã làm rõ rằng ảnh Activity Monitor chỉ phản ánh một thời điểm. Ví dụ, ảnh Load đang hiển thị CPU 3.70% và RAM 63.1 MB; giá trị peak 7.5%/72.55 MB được lấy từ
  toàn bộ resource CSV.

  ## 4. Evidence

  Đã có evidence thật ngày 20260903 cho:

  - Load
  - Stress
  - Spike
  - Soak

  Mỗi ảnh có Terminal/JMeter và Activity Monitor trong cùng khung hình, khớp backend PID.

  Đã giữ riêng những lần chạy không hợp lệ trong evidence/inconclusive, gồm:

  - Capture thiếu Activity Monitor.
  - Lần chạy bị gián đoạn.
  - Soak duration scheduler bị ảnh hưởng bởi clock jump.

  Evidence cũ không được đổi tên hoặc trộn vào baseline ngày 20260903.

  Report HTML chính ngày 20260901 đã được xóa theo yêu cầu.

  ## 5. Database consistency

  Mỗi accepted run bắt đầu với 5 sản phẩm.

   Scenario    Products trước    Products sau    Imports thành công
  ━━━━━━━━━━  ━━━━━━━━━━━━━━━━  ━━━━━━━━━━━━━━  ━━━━━━━━━━━━━━━━━━━━
   Load                     5             480                   475
  ──────────  ────────────────  ──────────────  ────────────────────
   Stress                   5           1,632                 1,627
  ──────────  ────────────────  ──────────────  ────────────────────
   Spike                    5             814                   809
  ──────────  ────────────────  ──────────────  ────────────────────
   Soak                     5          12,305                12,300

  Database delta khớp chính xác số lần workflow hoàn tất, chứng minh request import không chỉ trả HTTP 200 mà còn tạo thay đổi nghiệp vụ.

  ## 6. Task 2 – AI analysis review

  Đã tích hợp trực tiếp vào main_report.md:

  - 8 nhận định AI sai hoặc thiếu chính xác.
  - Giá trị đúng từ raw JTL.
  - Lý do từng nhận định sai.
  - Regression threshold proposal.
  - 8 đánh giá optimization theo source Express/SQLite.

  Các correction quan trọng:

  - 80.15 samples/s không phải 80.15 workflows/s.
  - Soak chỉ đạt 20.04 completed workflows/s.
  - Stress trung bình 36.19 samples/s không đại diện stage 24 VUs là 62.08 samples/s.
  - Spike trung bình 26.91 samples/s không đại diện burst là 83.04 samples/s.
  - Maximum 33 ms không phải p95; Soak p95 là 4 ms.
  - RSS peak giảm về gần mức ban đầu nên không chứng minh memory leak.
  - Regression gates không phải SLA.

  Optimization được phân loại:

  - FR16 transaction: feasible, nên benchmark.
  - WAL/busy_timeout: feasible experiment.
  - users(email) index: profile trước.
  - B-tree cho LIKE '%term%': không phải direct fix.
  - Coupon index bổ sung: redundant.
  - Conventional connection pool: không phù hợp SQLite hiện tại.
  - Search cache: không phù hợp workload unique read-after-write.
  - Clustered Node workers: chưa có evidence chứng minh cần thiết.

  Bạn đã xác nhận hoàn thành human review. task2_analysis_review.md, main_report.md và AI_Critique.md đã chuyển sang lời xác nhận của sinh viên.

  ## 7. Task 3 – Continuous performance testing

  Task 3 đã được viết và tích hợp vào main report, gồm:

  - Commit-aware trigger policy.
  - Smoke gate trước performance test.
  - Load cho pull request phù hợp.
  - Stress/Spike cho nightly hoặc thay đổi rủi ro cao.
  - Soak cho weekly/release candidate.
  - So sánh p95 với baseline.
  - Chạy xác nhận lại trước khi flag regression.
  - Baseline mới phải được con người duyệt.
  - Không so sánh trực tiếp giữa phần cứng khác nhau.
  - Lưu JTL, HTML, resource CSV, database state và metadata.

  Flowchart:

  assets/task3_continuous_performance_flow.svg

  Các trade-off về chi phí, false alarm, noisy neighbour, data drift, hardware drift và artifact retention đã được trình bày.

  ## 8. Main report

  Toàn bộ Task 1–3 đã được tích hợp vào:

  hw05/main_report.md

  Cấu trúc hiện tại:

  - Mục 1–8: Task 1.
  - Mục 9–11: Task 2.
  - Mục 12–14: Task 3.
  - Mục 15: Deliverables và kết luận.
  - Mục 16: AI Critique.

  Main report cũng đã có:

  - Link Task 1 video.
  - Link Agent Skill video.
  - Link GitHub.
  - Xác nhận human review.
  - Link hardware evidence.

  ## 9. Video

  ### Video Task 1

  https://youtu.be/ukf1sTUyVuY (https://youtu.be/ukf1sTUyVuY)

  Kịch bản video chính đã được rút xuống chỉ còn Task 1, khoảng 6 phút 30 giây:

  hw05/VIDEO_MAIN_DEMO_GUIDE.md

  Nội dung:

  - Môi trường.
  - Workflow/JMeter plan.
  - Load.
  - Stress.
  - Spike.
  - Soak.
  - Raw evidence và database consistency.
  - Kết luận Task 1.

  ### Video Agent Skill

  https://youtu.be/MxNkVFIW3Gk (https://youtu.be/MxNkVFIW3Gk)

  Kịch bản Agent Skill được rút xuống khoảng 3 phút 20 giây theo cấu trúc:

  - Mở gì.
  - Chỉ vào đâu.
  - Nói gì.
  - Prompt gọi skill.
  - Chạy analyser.
  - Giải thích output.

  File:

  hw05/VIDEO_AGENT_SKILL_DEMO_GUIDE.md

  ## 10. Agent Skill

  Skill nằm tại:

  skills/jmeter-performance-testing/

  Gồm:

  - SKILL.md
  - references/eshop-workflow.md
  - references/hw05-deliverables.md
  - scripts/analyze_jtl.py

  Agent Skill self-assessment đã được cập nhật từ 0/10 lên 10/10 vì đã có video end-to-end.

  Tổng technical self-assessment hiện là 100/100.

  ## 11. Hardware evidence

  Đã có:

  - evidence/hardware/hardware_spec.md
  - evidence/hardware/sysinfo.png

  Ảnh xác nhận:

  - Hostname MacBook-Air-cua-KunDa.local.
  - Apple M4.
  - RAM 16 GB.
  - macOS 26.5.1.

  ## 12. GitHub Issue

  Không tạo GitHub Issue vì:

  - Accepted runs đều có error rate 0%.
  - Không có backend crash.
  - Không có functional regression được tái hiện.
  - Chưa tìm thấy performance failure thật.

  bug_report.md đã giải thích rõ lý do issue count bằng 0. Không tạo issue giả chỉ để có link.

  ## 13. GitHub repository

  Remote:

  origin https://github.com/leekunda13/HW05.git

  Public repository:

  https://github.com/leekunda13/HW05 (https://github.com/leekunda13/HW05)

  Đã:

  - Gắn remote origin.
  - Push nhánh main.
  - Kiểm tra URL không dùng Git credential.
  - GitHub trả HTTP 200, xác nhận repo có thể truy cập công khai.
  - Thêm URL vào README và main report.

  ## 14. Các commit chính trong session

  846d999 confirm repository
  047e808 add submission links
  32cb6c5 record final reviews
  3520e51 clarify resource peaks
  2530d18 focus task1 demo
  fd99212 simplify main demo
  31dec27 add video guides
  3d6cb3a integrate report
  0e791a7 remove old reports
  074fa28 fix checklist
  19db220 update evidence

  ## 15. Kiểm tra tự động

  Đã chạy thành công:

  scripts/verify_task1.sh
  scripts/verify_task2.sh
  scripts/verify_task3.sh

  Kết quả:

  - Task 1 metrics/state/evidence: pass.
  - Task 2 raw metrics, corrections và optimization classifications: pass.
  - Task 3 proposal và flowchart: pass.
  - AI Critique: 281 từ, nằm trong yêu cầu 200–300 từ.
  - PDF verification được bỏ qua theo đúng yêu cầu chưa tạo PDF.
