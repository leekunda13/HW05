# EShop Performance Workflow Reference

Read this reference when creating or auditing EShop requests. The source of truth is `hw04/eshop-sut-main/backend/server.js`, `backend/database.js`, and the repository SRS.

## Runtime

| Component | Technology | Default URL |
| --- | --- | --- |
| Backend | Node.js, Express, SQLite | `http://localhost:3000` |
| User frontend | React, Vite | `http://localhost:5173` |
| Admin frontend | React, Vite | `http://localhost:5174` |

JMeter targets the backend on port 3000, not the Vite frontend.

## Recommended End-to-End Journey

| Order | Endpoint | Group | Input/correlation | Minimum checks |
| ---: | --- | --- | --- | --- |
| 1 | `POST /api/login` | Auth-heavy | CSV `email,password`; extract `token` | 200, JSON token exists, response is not a lockout |
| 2 | `GET /api/products?search={search}` | Read-heavy | CSV `search` | 200, JSON array, expected item/ID is present |
| 3 | `GET /api/products/{product_id}` | Read-heavy | CSV or value correlated from listing | 200, non-empty product object, expected ID |
| 4 | `POST /api/cart` | Transactional | Bearer token; JSON item/quantity | 200, `Added to cart` message |
| 5 | `POST /api/checkout` | Transactional | Bearer token; `total_amount`, `shipping_address` | 200, `Checkout successful`, extract `orderId` |

Use `Content-Type: application/json`. Add `Authorization: Bearer ${token}` to cart and checkout. The cart is an in-memory object keyed by user ID; checkout writes an order row to SQLite.

Suggested CSV header:

```csv
email,password,search,product_id,quantity,total_amount,shipping_address
```

Create and verify performance accounts before timed runs. Do not assume the two default accounts are sufficient for concurrent traffic, and do not place sensitive real credentials in a committed CSV.

## Relevant Source Behaviors

- Default users are `admin@eshop.com / Admin123!` and `test@eshop.com / Test1234!`.
- The SRS says each failed login increments the counter by 1 and locks after three failures for 30 seconds. The implementation increments by 2 and locks for 180 seconds. This can contaminate later scenarios and is a functional defect, not a legitimate performance parameter.
- A successful login resets `login_attempts` and `locked_until` for that user.
- `GET /api/products` uses a string-interpolated SQL `LIKE` query when `search` is present. Treat input safety and query cost as source observations; do not claim an index benefit without measuring and examining the query plan.
- `POST /api/cart` uses process memory. Restarting the backend removes carts.
- `POST /api/checkout` trusts the client-supplied `total_amount` and writes to SQLite. Repeated performance runs grow the orders table unless the database is restored or cleaned using a documented procedure.
- The backend has no explicit connection-pool configuration. SQLite is accessed through the `sqlite3` package. Recommendations about PostgreSQL/MySQL pools are not current-code fixes.
- The backend does not expose built-in CPU or memory metrics. Capture the actual Node process in Activity Monitor/htop/Task Manager and align evidence timestamps with the run.

## State and Isolation

Preserve the original database before testing. Prefer a documented seed/restore procedure and verify row counts after restoration. Avoid sharing one account across concurrent virtual users because cart and lockout state are user-scoped. When registering test accounts, use an untimed setup step and verify that the dataset size covers peak concurrent users without recycling.

Do not modify the SUT merely to make a result cleaner. If a source defect affects performance testing, document it, control it when possible, and retain evidence.
