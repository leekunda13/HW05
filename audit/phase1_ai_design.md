# HW05 Task 1 - Giai đoạn 1: Phân tích SUT và thiết kế performance workflow

> Historical AI output captured before execution. Statements such as "not yet run" below describe that earlier phase only; `../main_report.md` is the current final execution report. This file is retained for the mandatory chronological audit and is not a pending-work list.

## 1. Phạm vi và trạng thái

| Mục | Giá trị |
| --- | --- |
| Student ID | `23127035` |
| Ngày thiết kế | `2026-08-29` (Asia/Ho_Chi_Minh) |
| Ngày chạy chính thức | Chưa có; phải ghi ngày thật khi Giai đoạn 2 được thực thi |
| SUT | EShop, source `../hw04/eshop-sut-main` |
| Backend dự kiến | `http://127.0.0.1:3000` |
| Công cụ dự kiến | Apache JMeter |
| Feature đã chọn | FR03, FR09, FR16 |
| Giai đoạn hiện tại | Chỉ phân tích và thiết kế; chưa tạo JMX, chưa chạy smoke/performance test |

Workflow không trùng được ghi nhận theo xác nhận trực tiếp của sinh viên trong prompt. AI chưa xem bằng chứng nhóm (ảnh chụp, bảng phân công hoặc tin nhắn), vì vậy báo cáo cuối vẫn phải đính kèm hoặc dẫn tới bằng chứng này; không được diễn đạt như một xác minh độc lập của AI.

Trạng thái công cụ và môi trường tại thời điểm phân tích:

- `jmeter` không có trong `PATH`. Không cài đặt trong giai đoạn này. Sinh viên cần cài/khai báo đúng phiên bản và chạy `jmeter --version` trước Giai đoạn 2.
- Có process `node server.js` PID 38447 chạy từ `2026-08-21 18:29:25 +0700`, cwd là `../hw04/eshop-sut-main/backend`, đang listen cổng 3000. Không gửi request, không dừng process và không sửa database trong giai đoạn này.
- Kiểm tra SQLite chỉ đọc cho thấy database hiện có 15 users, 5 products, 4 coupons, 26 coupon-usage rows và 0 orders. Đây là state HW04 đang tồn tại, không phải baseline HW05.

## 2. Nguồn đã đọc và thứ tự ưu tiên

1. Đề bài `2026.HW05.Performance Testing_En.pdf`, đủ 9 trang, gồm yêu cầu Task 1 và anti-cheat constraints.
2. `skills/jmeter-performance-testing/SKILL.md`.
3. `skills/jmeter-performance-testing/references/eshop-workflow.md`.
4. `skills/jmeter-performance-testing/references/hw05-deliverables.md`.
5. Source backend: `backend/server.js`, `backend/database.js`, `backend/package.json`.
6. `api_specification.md` và các caller thật ở frontend web, admin và mobile.

Khi tài liệu API khác source thực thi, thiết kế này lấy `backend/server.js` và `backend/database.js` làm nguồn đúng. Ví dụ, API specification minh họa reset token 6 chữ số, nhưng source tạo đúng 4 chữ số và UI web cũng ghi 4 chữ số.

Các vị trí source chính:

- Login, forgot/reset và JWT middleware: `../hw04/eshop-sut-main/backend/server.js:32`, `:68`, `:87`, `:100`.
- Product search: `../hw04/eshop-sut-main/backend/server.js:141`.
- Import products: `../hw04/eshop-sut-main/backend/server.js:198`.
- Apply coupon và coupon usage: `../hw04/eshop-sut-main/backend/server.js:363`, `:444`.
- Schema/seed/reset database: `../hw04/eshop-sut-main/backend/database.js:13`.

## 3. Workflow được đề xuất sau khi xác minh source

Workflow giữ nguyên cho Load, Stress và Spike; về sau chỉ workload model và listener/report view được phép khác nhau.

1. FR03 - `POST /api/forgot-password` cho tài khoản riêng của VU.
2. Trích xuất `resetToken` từ JSON response.
3. FR03 - `POST /api/reset-password`, đặt lại về một mật khẩu test mạnh, cố định cho chính tài khoản đó.
4. `POST /api/login`; trích xuất JWT, user ID và role.
5. FR09 - `POST /api/apply-coupon`; dùng user ID đã correlation.
6. FR16 - `POST /api/admin/import-products`; dùng JWT của một tài khoản có `role=admin`.
7. `GET /api/products` với query parameter `search=${imported_product}`; kiểm tra chính xác sản phẩm vừa import.

### Quyết định thiết kế tạm thời về admin token

Để không thêm một lần admin login thứ hai vào journey 7 bước, phương án khuyến nghị là mỗi CSV row đại diện cho một tài khoản test độc lập đã được seed với `role=admin`. FR03 reset chính tài khoản đó, login trả về JWT có role admin, FR09 dùng cùng user ID, và FR16 dùng cùng JWT.

Phương án này cần human-review vì FR03 trên tài khoản admin không phải hành vi người dùng phổ biến. Phương án thay thế là tài khoản user riêng cho FR03/FR09 và một admin token lấy ở untimed setup; cách thay thế giữ vai trò thực tế hơn nhưng chia sẻ identity admin hoặc đòi hỏi thêm admin accounts/correlation ngoài journey hiện tại.

## 4. Contract request/response chính xác

Header chung cho các POST JSON:

```text
Content-Type: application/json
Accept: application/json
```

Chỉ request import cần `Authorization`. Product search là public. `apply-coupon` nhận `user_id` trong body nhưng không xác thực JWT.
Mọi URL đầy đủ bằng base `http://127.0.0.1:3000` cộng path trong bảng.

| Bước | Request | Auth | Body/parameter chính xác | Response/correlation bắt buộc |
| ---: | --- | --- | --- | --- |
| 1 | `POST /api/forgot-password` | Không | `{"email":"${email}"}` | 200; JSON `message`; trích `$.resetToken` thành `${reset_token}`; token phải khớp `^[0-9]{4}$` |
| 2 | `POST /api/reset-password` | Không | `{"email":"${email}","resetToken":"${reset_token}","newPassword":"${new_password}"}` | 200; `$.message == "Password reset successfully"` |
| 3 | `POST /api/login` | Không | `{"email":"${email}","password":"${new_password}"}` | 200; trích `$.token -> ${jwt}`, `$.user.id -> ${user_id}`, `$.user.role -> ${user_role}`; role phải là `admin` theo phương án khuyến nghị |
| 4 | `POST /api/apply-coupon` | Không | `{"code":"${coupon_code}","total_amount":${coupon_total},"user_id":${user_id}}` | 200; `$.success == true`; trích `coupon_id`, `discount_amount`, `final_amount`; kiểm tra số tiền theo fixture |
| 5 | `POST /api/admin/import-products` | `Authorization: Bearer ${jwt}` | `{"products":[{"name":"${imported_product}","price":${product_price},"description":"${product_description}","imageUrl":"${product_image_url}","category_id":${category_id}}]}` | 200; `$.inserted == 1`; `$.errors` là mảng rỗng; message báo `1/1` |
| 6 | `GET /api/products` | Không | Query parameter `search=${imported_product}` với URL encoding bật | 200; content type JSON; body là array; có ít nhất một object có `name` bằng chính xác `${imported_product}`; có thể trích ID của match để chẩn đoán |

Các failure status cần phân biệt trong smoke/debug: forgot email không tồn tại -> 404; reset token/email sai -> 400; login credential sai -> 401; account đang lock -> 403; coupon thiếu/invalid/expired/đã đạt usage/minimum không đạt -> 400 hoặc 404 theo branch; import thiếu token -> 401, token invalid -> 403, products array thiếu/rỗng -> 400; search SQL error -> 500 và body HTML. Không coi các response này là success của journey.

Lưu ý kỹ thuật:

- Không đặt `resetToken`, JWT hoặc user ID trong CSV; đây là các giá trị động phải correlation từ response.
- Login source trả cả object `user`; không dùng password/reset token bị lộ trong object đó làm dữ liệu đầu vào cho bước sau.
- Dùng bảng Parameters của HTTP Request cho `search`, không nối chuỗi chưa encode trực tiếp vào path.
- `${imported_product}` chỉ gồm chữ, số, gạch ngang/gạch dưới. Source ghép `search` trực tiếp vào SQL `LIKE`, nên dấu nháy hoặc wildcard có thể đổi semantics hoặc gây lỗi SQL.
- JSON fields kiểu số (`total_amount`, `price`, `category_id`, `user_id`) không đặt trong dấu nháy.

## 5. Ánh xạ endpoint group

| Nhóm yêu cầu | Endpoint chính | Cơ sở ánh xạ | Giới hạn phải ghi trong báo cáo |
| --- | --- | --- | --- |
| Auth-heavy | FR03 forgot + reset, sau đó login | Mỗi iteration có hai auth-state writes và một credential verification/JWT issue | Đây không chỉ là auth CPU; SQLite write và reset-token state có thể chi phối latency. Password đang lưu plaintext trong SUT. |
| Read-heavy | `GET /api/products?search=...` | SELECT/LIKE trên products và trả JSON array | Search là SQL string interpolation, chưa có index/query-plan evidence; database tăng theo từng import nên chi phí read thay đổi theo thời gian. |
| Transactional/write-heavy | FR16 `POST /api/admin/import-products` | Một business request thực hiện một hoặc nhiều INSERT product | Source không dùng SQLite transaction; batch có thể thành công một phần. Vì vậy gọi đây là transactional workflow ở mức nghiệp vụ, không tuyên bố atomic/ACID. |
| Business validation bổ sung | FR09 `POST /api/apply-coupon` | Lookup coupon + optional usage count + tính số tiền | Endpoint này chỉ đọc và tính toán. Nó không ghi coupon usage, nên không được dùng một mình làm bằng chứng transactional write. |

Workflow đáp ứng ba nhóm nếu báo cáo dùng FR16 làm transactional/write-heavy và product search làm read-heavy. Nếu giảng viên yêu cầu transactional phải là checkout/order creation, workflow FR03-FR09-FR16 cần được đổi trước khi tạo JMX.

## 6. Đánh giá tính hợp lý và hạn chế cần bảo vệ

### Điểm hợp lý

- Có một chain correlation thật: forgot response -> reset; login response -> coupon/import; import input -> search verification.
- Bao phủ auth state, business validation, SQLite writes và read-after-write trong cùng iteration.
- FR16 làm database lớn dần, tạo điều kiện quan sát read-after-write và write contention thật.
- Có thể giữ nguyên journey giữa Load, Stress và Spike, đúng đề bài.

### Hạn chế/defect source

1. `authenticateToken` chỉ kiểm tra JWT hợp lệ, không kiểm tra `req.user.role === "admin"`. API spec nói admin-only nhưng `/api/admin/import-products` chấp nhận token của user thường. Test vẫn phải dùng account role admin và assert role; không lợi dụng defect để làm dữ liệu dễ hơn.
2. Import không có transaction và không rollback. Nếu một row lỗi, các row khác vẫn có thể được insert và response vẫn là HTTP 200 với `errors` khác rỗng. Assertion phải kiểm tra cả `inserted` lẫn `errors`.
3. `apply-coupon` không đánh dấu đã dùng. Chỉ `POST /api/coupon-usage` sau checkout mới ghi usage, nhưng endpoint đó không thuộc workflow hiện tại.
4. Nhánh coupon phần trăm tính sai: source dùng `total_amount * (1 - discount_value)` trong khi seed `SAVE10` có `discount_value=10`. Không dùng coupon phần trăm cho performance success path. Dùng fixture fixed coupon `BIGBUY`, `total_amount=600000`, expected discount `50000`, expected final `550000`.
5. Điều kiện minimum là `total_amount > min_order_amount`, không phải `>=`; vì vậy không dùng đúng 500000 với `BIGBUY`.
6. Reset token chỉ có 4 chữ số, không expiry, và mỗi lần forgot ghi đè token trước. Dùng cùng account đồng thời sẽ tạo race chắc chắn.
7. Password reset không xóa `login_attempts` hoặc `locked_until`. Account đã khóa vẫn có thể reset password nhưng login tiếp theo vẫn trả 403 tới khi hết lock/reset DB.
8. Login thất bại tăng counter thêm 2, nên từ state 0 account bị khóa ở lần sai thứ hai, trong 180 giây. Điều này khác mô tả 3 failures/30 seconds và phải được ghi như functional defect.
9. Product search ghép trực tiếp input vào SQL. Chỉ dùng test data do mình kiểm soát; không dùng input có quote/wildcard và không tuyên bố index là giải pháp trước khi đo/query plan.
10. JWT không có expiry và secret hardcoded. Đây là security limitation, không phải kết quả performance.

Kết luận tạm thời: workflow hợp lý để tiếp tục sang smoke nếu human chấp thuận việc dùng admin-role account cho toàn journey và chấp thuận FR16 là đại diện transactional/write-heavy. Nếu không, phải sửa workflow trước khi tạo bất kỳ JMX nào.

## 7. State risk và biện pháp kiểm soát

| Risk | Cơ chế source | Hậu quả khi concurrent | Kiểm soát đề xuất |
| --- | --- | --- | --- |
| Reset password | Forgot ghi `reset_token`; reset đổi password và xóa token | Hai VU chung email sẽ ghi đè token; một reset làm token kia invalid; password có thể thay đổi giữa login | Một account/VU; password reset về cùng giá trị mạnh, ổn định; fail iteration nếu token/reset/login sai |
| Account lockout | Failed login tăng 2; khóa 180s khi counter >=3 | CSV sai hoặc password race làm các iteration sau trả 403 | Preflight credentials; unique account; dừng thread/iteration khi 401/403; reset bằng procedure thật, không chờ rồi trộn state |
| Coupon usage | Apply chỉ SELECT; usage chỉ tăng qua endpoint riêng `/api/coupon-usage` | State cũ có thể làm `usage_count` đạt max; workflow hiện tại không tự tăng usage | Baseline `coupon_usage=0`; fixed coupon; không gọi usage endpoint ngoài scope; ghi rõ FR09 ở đây là validate-only |
| Quyền admin FR16 | Middleware không enforce role | User token vẫn import được, che defect authorization | Seed role admin; extract/assert `$.user.role`; xem xét log bug riêng sau human review |
| Database tăng sau import | Mỗi iteration insert ít nhất một product, không cleanup nội bộ | Search payload/cost tăng; scenario chạy sau không còn comparable | Disposable DB; reset/reseed giữa smoke, Load, Stress, Spike; log row counts trước/sau |
| Shared account/token | User state nằm trong SQLite; token mang user ID/role | Reset-token race, lockout contamination, coupon-state coupling | Không share user account giữa active VUs. Nếu dùng shared setup admin token ở phương án thay thế, phải ghi rõ giới hạn và không dùng nó cho reset/login. |
| Duplicate product names | Import không unique constraint | Search trả nhiều matches; khó chứng minh read-after-write | Tạo tên unique theo run/VU/iteration; assert exact match; reset DB giữa runs |

## 8. CSV schema và provisioning account

### CSV khuyến nghị

```csv
vu_id,email,new_password,coupon_code,coupon_total,expected_discount,expected_final,product_name_prefix,product_price,product_description,product_image_url,category_id
001,perf-admin-001@example.invalid,PerfTest123!,BIGBUY,600000,50000,550000,HW05P-001,123456,perf-product-001,https://example.invalid/p.png,1
```

Quy tắc:

- Đây là schema, chưa tạo file dữ liệu thật ở Giai đoạn 1.
- Mỗi row là một account admin test độc lập; không dùng email/password thật.
- Số row/account tối thiểu bằng maximum threads/VUs có thể đồng thời hoạt động trong kịch bản lớn nhất. Có thể thêm một số row dự phòng được ghi rõ, nhưng không dùng reserve để che dataset thiếu. Thread count chưa được chọn nên chưa thể chốt số account.
- Cấu trúc JMX sau này phải đọc đúng một row khi thread bắt đầu và giữ row đó trong inner journey loop. Nếu CSV Data Set Config bị đặt để đọc lại mỗi iteration, phải cấp đủ row cho tổng iterations chứ không chỉ peak VUs.
- Dự kiến `Recycle on EOF=false`, `Stop thread on EOF=true`, `Sharing mode=All threads`; fail preflight nếu số row nhỏ hơn số threads. Không recycle một tập credential nhỏ.
- Bật quoted-data hoặc giới hạn field không chứa comma/newline/quote. Password CSV thật phải nằm ngoài Git; repository chỉ chứa sample/redacted data và `.gitignore` phù hợp.
- Tạo `${imported_product}` tại runtime theo mẫu `${product_name_prefix}-${run_id}-T${thread_num}-I${iteration}` để unique giữa iteration/scenario. `run_id` là metadata thực của lần chạy, không tạo giả timestamp quá khứ.

### Cách tạo đủ account

Khuyến nghị dùng một database disposable của HW05 và một bước provisioning untimed, được sinh viên phê duyệt và ghi log:

1. Chọn `N = max concurrent VUs` sau baseline/hardware review; tạo N email/password mạnh và unique.
2. Seed N users với `role=admin` trong fixture test có kiểm soát, hoặc dùng API setup nếu giảng viên cho phép. Không sửa production-like source chỉ để làm kết quả đẹp.
3. Xác minh bằng login một lần/account và kiểm tra `user.id`, `user.role=admin`, `login_attempts=0`, `locked_until=NULL`, `reset_token=NULL`.
4. Xuất CSV runtime tương ứng; không ghi JWT vào CSV. JWT phải được lấy từ login trong journey.
5. Trước mỗi scenario, reset/reseed rồi chạy lại provisioning, sau đó kiểm tra row count và uniqueness.

Hai cách provisioning cần human chọn:

- Fixture/SQL seed trên database disposable: deterministic nhất, nhưng là state mutation ngoài API và phải được ghi rõ.
- `POST /api/register`, login, rồi `PUT /api/users/me` với `role:"admin"`: source cho phép tự nâng role, nhưng đây là authorization defect. Chỉ dùng nếu sinh viên muốn chứng minh setup qua API và chấp nhận ghi defect; không được che giấu.

## 9. Extraction và assertions

### JSON extraction

| Response | JSONPath | Variable | Nếu thiếu |
| --- | --- | --- | --- |
| Forgot password | `$.resetToken` | `reset_token` | Fail ngay; không gửi reset request với default rỗng |
| Login | `$.token` | `jwt` | Fail iteration |
| Login | `$.user.id` | `user_id` | Fail iteration |
| Login | `$.user.role` | `user_role` | Fail nếu khác `admin` trong phương án chính |
| Coupon | `$.coupon_id` | `coupon_id` | Fail |
| Coupon | `$.discount_amount` | `discount_amount` | So với CSV expected |
| Coupon | `$.final_amount` | `final_amount` | So với CSV expected |
| Import | `$.inserted` | `inserted_count` | Phải bằng số products gửi (smoke là 1) |
| Search | filter theo exact `name` | `imported_product_id` (diagnostic) | Fail nếu không có match |

Mọi extractor đặt default sentinel như `__MISSING__`, sau đó assertion fail rõ tên biến. Không cho request sau chạy với sentinel nếu có thể dừng iteration.

### Assertion theo request

- Tất cả success sampler: response code đúng 200, response body parse được JSON, content type có `application/json`, không có top-level `error`.
- Forgot: message đúng và token 4 chữ số.
- Reset: message `Password reset successfully`.
- Login: message `Login successful`; token không rỗng; user ID là số dương; role đúng; response không phải lockout.
- Apply coupon: `success=true`, `coupon_id` dương, fixed discount/final amount đúng fixture. Không chỉ assert HTTP 200.
- Import: `inserted=1`, `errors` length 0, message chứa `1/1`. Vì source có partial success, bất kỳ error entry nào đều làm sampler fail.
- Search: JSON array; exact imported name xuất hiện ít nhất một lần; record match count. Nếu match count >1 trong cùng baseline/run, đánh dấu data-isolation issue.
- Transaction/iteration controller sau này phải fail khi child sampler/assertion fail để error rate phản ánh business failure.

Chưa đặt SLA, p95 target hoặc timeout performance. Các ngưỡng phải dựa trên smoke/baseline và hardware thật, được sinh viên phê duyệt; không lấy số tùy ý.

## 10. Cleanup/reset database

Đây là điểm nguy hiểm nhất của SUT hiện tại:

- `server.js` require `database.js`.
- `database.js` gọi `initDatabase()` ngay khi module được load.
- `initDatabase()` DROP toàn bộ bảng rồi seed lại 2 users, 5 products, 4 coupons, 3 categories; coupon usage/orders trở về 0.
- Vì vậy chỉ cần restart backend cũng reset database, dù setup guide mô tả `node database.js` là bước chỉ chạy khi cần reset.

Không được restart process đang chạy từ source HW04 trước khi bảo vệ state hiện tại. Quy trình đề xuất cho HW05:

1. Tạo bản copy/disposable riêng của SUT/database cho HW05; sinh viên xác nhận không cần giữ state trong bản đó.
2. Ghi checksum/row counts baseline, hostname và thời gian thực; đây là metadata thật, không bịa.
3. Trước mỗi smoke/official scenario: stop đúng backend HW05, start để source re-init, provision N accounts, kiểm tra expected counts (`categories=3`, `coupons=4`, `products=5`, `coupon_usage=0`, `orders=0`, `users=2+N`).
4. Chạy một scenario duy nhất.
5. Ghi row counts sau run; products dự kiến tăng bằng số import thành công. Không xóa riêng từng row trong timed run.
6. Trước scenario tiếp theo, lặp reset/reseed/provision. Giữ workflow, dataset semantics và fixture giống nhau.

Nếu sinh viên không dùng disposable copy, phải backup database hiện tại khi backend đã dừng và thử restore trước. Tuy nhiên backup file rồi start source hiện tại vẫn sẽ bị `initDatabase()` ghi đè, nên backup không thay thế việc tách môi trường.

## 11. Smoke test đề xuất - 1 user / 1 iteration

Chưa chạy smoke và chưa tạo JMX. Checklist cho bước kế tiếp:

### Precondition

- JMeter đã cài và `jmeter --version` được lưu vào AI/human audit.
- Backend HW05 disposable ở `127.0.0.1:3000`; không phải process HW04 hiện tại.
- Baseline/reseed và 1 admin test account đã provision/verified.
- Coupon `BIGBUY` active, expiry 2099-12-31, min 500000, fixed discount 50000.
- Product name runtime unique; baseline không có product đó.
- Thread/VU = 1, outer iteration = 1; chưa áp timer load phức tạp. Có thể dùng View Results Tree chỉ cho smoke/debug.

### Expected chain

1. Forgot 200, nhận reset token 4 chữ số.
2. Reset 200.
3. Login 200, JWT + user ID + role admin.
4. Coupon 200, discount 50000, final 550000.
5. Import 200, inserted 1, errors empty.
6. Search 200, array có exact product vừa import.

### Postcondition

- Toàn iteration success theo assertions, không chỉ HTTP status.
- User có `login_attempts=0`, `locked_until=NULL`, `reset_token=NULL`.
- Product count tăng đúng 1 và exact product tồn tại.
- `coupon_usage` không đổi vì workflow không gọi `/api/coupon-usage`.
- Sau khi lưu bằng chứng smoke thật, reset/reseed lại trước baseline hoặc official run.

Smoke failure phải được sửa ở contract/data/correlation; không được nới assertion chỉ để pass.

## 12. Những quyết định bắt buộc human-review trước Giai đoạn 2

- [ ] Đính kèm bằng chứng workflow FR03-FR09-FR16 không trùng trong nhóm. Hiện chỉ có xác nhận bằng lời trong prompt.
- [ ] Chấp thuận FR16 import là đại diện transactional/write-heavy dù source không atomic; nếu môn yêu cầu checkout/order creation, đổi workflow.
- [ ] Chọn account model: unique admin account/VU cho toàn journey (khuyến nghị hiện tại), hay unique user accounts + admin token/setup riêng.
- [ ] Chọn và ghi rõ cách provision admin accounts; cân nhắc defect self-role-escalation nếu dùng API.
- [ ] Chấp thuận reset password về cùng giá trị mạnh ở mỗi iteration để state ổn định.
- [ ] Chấp thuận coupon fixed `BIGBUY`, total 600000 và expected 50000/550000; không dùng nhánh percent đang sai.
- [ ] Xác nhận dùng SUT/database disposable riêng; tuyệt đối không restart backend HW04 hiện tại trước khi bảo vệ dữ liệu.
- [ ] Cài JMeter hoặc cung cấp path, rồi xác minh version. AI không tự cài khi chưa được phép.
- [ ] Sau smoke/baseline, quyết định peak VUs, số accounts, think-time, ramp-up, duration và stop conditions trên hardware thật.
- [ ] Quyết định có log GitHub issue cho missing admin-role enforcement, percent coupon formula, lockout increment/duration và destructive DB init hay không.
- [ ] Kiểm tra/correct toàn bộ tài liệu này và ghi corrections tách biệt như human output.

## 13. Ranh giới artifact của Giai đoạn 1

Đã tạo duy nhất tài liệu Markdown thiết kế này. Chưa tạo hoặc tuyên bố có:

- Load/Stress/Spike JMX;
- CSV credentials thật;
- smoke, load, stress, spike hay soak execution;
- JTL, HTML report, performance metrics hoặc thresholds;
- screenshot, hardware evidence, video;
- Git commit/log hoặc GitHub issue.

## 14. AI audit handoff cho interaction này

| Trường | Nội dung |
| --- | --- |
| AI tool | Codex |
| Thời gian bắt đầu ghi nhận | `2026-08-29T12:58:09+0700` |
| AI output | File Markdown này là output thiết kế Giai đoạn 1. Mọi correction sau đây phải được sinh viên ghi tách biệt, kèm source/raw evidence. |

Student prompt được lưu nguyên văn dưới đây (không lặp lại phần nội dung `SKILL.md` mà client đã đính kèm riêng):

```text
Sử dụng jmeter-performance-testing để thực hiện GIAI ĐOẠN 1
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

Bản export task Codex vẫn nên được giữ cùng AI Audit Report để chứng minh prompt/output đầy đủ và thứ tự thời gian.

---

Trạng thái cuối Giai đoạn 1: **DỪNG CHỜ HUMAN REVIEW**.
