#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const runDate = "20260831";
const studentId = "23127035";
const csvRelative = "../data/performance_users.csv";

for (const directory of ["data", "test-plans", "results", "reports", "evidence/resource", "evidence/database", "output/pdf"]) {
  fs.mkdirSync(path.join(root, directory), { recursive: true });
}

const csvHeader = [
  "email",
  "password",
  "new_password",
  "coupon_code",
  "coupon_total",
  "expected_discount",
  "expected_final",
  "product_prefix",
  "product_price",
  "product_description",
  "product_image_url",
  "category_id",
].join(",");

const csvRows = [csvHeader];
for (let index = 1; index <= 80; index += 1) {
  csvRows.push([
    `perf${String(index).padStart(3, "0")}@eshop.local`,
    "Perf1234!",
    "Perf1234!",
    "BIGBUY",
    "600000",
    "50000",
    "550000",
    `HW05-P${String(index).padStart(3, "0")}`,
    "750000",
    "HW05 performance product",
    "https://placehold.co/300x300/png?text=HW05",
    "1",
  ].join(","));
}
fs.writeFileSync(path.join(root, "data/performance_users.csv"), `${csvRows.join("\n")}\n`);

const sql = [
  "BEGIN TRANSACTION;",
  "DELETE FROM users WHERE email LIKE 'perf%@eshop.local';",
];
for (let index = 1; index <= 80; index += 1) {
  const email = `perf${String(index).padStart(3, "0")}@eshop.local`;
  sql.push(`INSERT INTO users (name, email, password, role, login_attempts, locked_until) VALUES ('HW05 Perf ${String(index).padStart(3, "0")}', '${email}', 'Perf1234!', 'admin', 0, NULL);`);
}
sql.push("COMMIT;");
fs.writeFileSync(path.join(root, "scripts/seed_performance_data.sql"), `${sql.join("\n")}\n`);

function escapeXml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&apos;");
}

function responseCodeAssertion() {
  return `
            <ResponseAssertion guiclass="AssertionGui" testclass="ResponseAssertion" testname="HTTP 200" enabled="true">
              <collectionProp name="Asserion.test_strings"><stringProp name="49586">200</stringProp></collectionProp>
              <stringProp name="Assertion.custom_message">Expected HTTP 200</stringProp>
              <stringProp name="Assertion.test_field">Assertion.response_code</stringProp>
              <boolProp name="Assertion.assume_success">false</boolProp>
              <intProp name="Assertion.test_type">8</intProp>
            </ResponseAssertion>
            <hashTree/>`;
}

function jsonExtractor(referenceNames, paths, defaults) {
  return `
            <JSONPostProcessor guiclass="JSONPostProcessorGui" testclass="JSONPostProcessor" testname="Correlate JSON fields" enabled="true">
              <stringProp name="JSONPostProcessor.referenceNames">${escapeXml(referenceNames)}</stringProp>
              <stringProp name="JSONPostProcessor.jsonPathExprs">${escapeXml(paths)}</stringProp>
              <stringProp name="JSONPostProcessor.match_numbers">${referenceNames.split(";").map(() => "1").join(";")}</stringProp>
              <stringProp name="JSONPostProcessor.defaultValues">${escapeXml(defaults)}</stringProp>
            </JSONPostProcessor>
            <hashTree/>`;
}

function jsr223Assertion(name, script) {
  return `
            <JSR223Assertion guiclass="TestBeanGUI" testclass="JSR223Assertion" testname="${escapeXml(name)}" enabled="true">
              <stringProp name="cacheKey">true</stringProp>
              <stringProp name="filename"></stringProp>
              <stringProp name="parameters"></stringProp>
              <stringProp name="script">${escapeXml(script)}</stringProp>
              <stringProp name="scriptLanguage">groovy</stringProp>
            </JSR223Assertion>
            <hashTree/>`;
}

function rawBodyArgument(body) {
  return `
          <elementProp name="" elementType="HTTPArgument">
            <boolProp name="HTTPArgument.always_encode">false</boolProp>
            <stringProp name="Argument.value">${escapeXml(body)}</stringProp>
            <stringProp name="Argument.metadata">=</stringProp>
          </elementProp>`;
}

function queryArgument(name, value) {
  return `
          <elementProp name="${escapeXml(name)}" elementType="HTTPArgument">
            <boolProp name="HTTPArgument.always_encode">true</boolProp>
            <stringProp name="Argument.name">${escapeXml(name)}</stringProp>
            <stringProp name="Argument.value">${escapeXml(value)}</stringProp>
            <stringProp name="Argument.metadata">=</stringProp>
            <boolProp name="HTTPArgument.use_equals">true</boolProp>
          </elementProp>`;
}

function httpSampler({ name, method, endpoint, body = null, query = null, children = "" }) {
  const args = body !== null ? rawBodyArgument(body) : query ? queryArgument(query.name, query.value) : "";
  return `
        <HTTPSamplerProxy guiclass="HttpTestSampleGui" testclass="HTTPSamplerProxy" testname="${escapeXml(name)}" enabled="true">
          <elementProp name="HTTPsampler.Arguments" elementType="Arguments" guiclass="HTTPArgumentsPanel" testclass="Arguments" testname="User Defined Variables" enabled="true">
            <collectionProp name="Arguments.arguments">${args}
            </collectionProp>
          </elementProp>
          <stringProp name="HTTPSampler.domain">\${__P(host,127.0.0.1)}</stringProp>
          <stringProp name="HTTPSampler.port">\${__P(port,3000)}</stringProp>
          <stringProp name="HTTPSampler.protocol">http</stringProp>
          <stringProp name="HTTPSampler.contentEncoding">UTF-8</stringProp>
          <stringProp name="HTTPSampler.path">${escapeXml(endpoint)}</stringProp>
          <stringProp name="HTTPSampler.method">${method}</stringProp>
          <boolProp name="HTTPSampler.follow_redirects">true</boolProp>
          <boolProp name="HTTPSampler.auto_redirects">false</boolProp>
          <boolProp name="HTTPSampler.use_keepalive">true</boolProp>
          <boolProp name="HTTPSampler.DO_MULTIPART_POST">false</boolProp>
          <boolProp name="HTTPSampler.postBodyRaw">${body !== null}</boolProp>
          <stringProp name="HTTPSampler.connect_timeout">5000</stringProp>
          <stringProp name="HTTPSampler.response_timeout">10000</stringProp>
        </HTTPSamplerProxy>
        <hashTree>${children}
        </hashTree>`;
}

function authHeader() {
  return `
            <HeaderManager guiclass="HeaderPanel" testclass="HeaderManager" testname="Bearer token" enabled="true">
              <collectionProp name="HeaderManager.headers">
                <elementProp name="Authorization" elementType="Header">
                  <stringProp name="Header.name">Authorization</stringProp>
                  <stringProp name="Header.value">Bearer \${jwt}</stringProp>
                </elementProp>
              </collectionProp>
            </HeaderManager>
            <hashTree/>`;
}

function workflow() {
  const prepareScript = `def suffix = ctx.getThreadNum() + '-' + vars.getIteration() + '-' + System.currentTimeMillis()\nvars.put('unique_product', vars.get('product_prefix') + '-' + suffix)`;
  const resetAssert = `def token = vars.get('reset_token')\nif (token == null || !(token ==~ /[0-9]{4}/)) { AssertionResult.setFailure(true); AssertionResult.setFailureMessage('resetToken was not a dynamic four-digit value: ' + token) }`;
  const resetBodyAssert = `def body = new groovy.json.JsonSlurper().parseText(prev.getResponseDataAsString())\nif (body.message != 'Password reset successfully') { AssertionResult.setFailure(true); AssertionResult.setFailureMessage('Unexpected reset response: ' + body) }`;
  const loginAssert = `def token = vars.get('jwt')\ndef userId = vars.get('user_id')\ndef role = vars.get('user_role')\nif (!token || token == 'NOT_FOUND' || !userId || userId == 'NOT_FOUND' || role != 'admin') { AssertionResult.setFailure(true); AssertionResult.setFailureMessage('Login correlation failed: user_id=' + userId + ', role=' + role) }`;
  const couponAssert = `def body = new groovy.json.JsonSlurper().parseText(prev.getResponseDataAsString())\ndef expectedDiscount = vars.get('expected_discount') as BigDecimal\ndef expectedFinal = vars.get('expected_final') as BigDecimal\nif (body.success != true || body.discount_amount as BigDecimal != expectedDiscount || body.final_amount as BigDecimal != expectedFinal) { AssertionResult.setFailure(true); AssertionResult.setFailureMessage('Coupon business result mismatch: ' + body) }`;
  const importAssert = `def body = new groovy.json.JsonSlurper().parseText(prev.getResponseDataAsString())\nif (body.inserted != 1 || !(body.errors instanceof List) || !body.errors.isEmpty() || !body.message.contains('1/1')) { AssertionResult.setFailure(true); AssertionResult.setFailureMessage('Import business result mismatch: ' + body) }`;
  const searchAssert = `def body = new groovy.json.JsonSlurper().parseText(prev.getResponseDataAsString())\ndef expected = vars.get('unique_product')\nif (!(body instanceof List) || !body.any { it.name == expected }) { AssertionResult.setFailure(true); AssertionResult.setFailureMessage('Imported product not found by exact name: ' + expected) }`;

  return [
    httpSampler({
      name: "FR03-1 Forgot password",
      method: "POST",
      endpoint: "/api/forgot-password",
      body: '{"email":"${email}"}',
      children: `
            <JSR223PreProcessor guiclass="TestBeanGUI" testclass="JSR223PreProcessor" testname="Create unique iteration data" enabled="true">
              <stringProp name="cacheKey">true</stringProp><stringProp name="filename"></stringProp><stringProp name="parameters"></stringProp>
              <stringProp name="script">${escapeXml(prepareScript)}</stringProp><stringProp name="scriptLanguage">groovy</stringProp>
            </JSR223PreProcessor><hashTree/>${responseCodeAssertion()}${jsonExtractor("reset_token", "$.resetToken", "NOT_FOUND")}${jsr223Assertion("Validate resetToken", resetAssert)}`,
    }),
    httpSampler({
      name: "FR03-2 Reset password",
      method: "POST",
      endpoint: "/api/reset-password",
      body: '{"email":"${email}","resetToken":"${reset_token}","newPassword":"${new_password}"}',
      children: `${responseCodeAssertion()}${jsr223Assertion("Validate reset response", resetBodyAssert)}`,
    }),
    httpSampler({
      name: "FR03-3 Login and correlate JWT",
      method: "POST",
      endpoint: "/api/login",
      body: '{"email":"${email}","password":"${new_password}"}',
      children: `${responseCodeAssertion()}${jsonExtractor("jwt;user_id;user_role", "$.token;$.user.id;$.user.role", "NOT_FOUND;NOT_FOUND;NOT_FOUND")}${jsr223Assertion("Validate login correlation", loginAssert)}`,
    }),
    httpSampler({
      name: "FR09 Apply BIGBUY coupon",
      method: "POST",
      endpoint: "/api/apply-coupon",
      body: '{"code":"${coupon_code}","total_amount":${coupon_total},"user_id":${user_id}}',
      children: `${responseCodeAssertion()}${jsr223Assertion("Validate coupon amounts", couponAssert)}`,
    }),
    httpSampler({
      name: "FR16 Import one product",
      method: "POST",
      endpoint: "/api/admin/import-products",
      body: '{"products":[{"name":"${unique_product}","price":${product_price},"description":"${product_description}","imageUrl":"${product_image_url}","category_id":${category_id}}]}',
      children: `${authHeader()}${responseCodeAssertion()}${jsr223Assertion("Validate import result", importAssert)}`,
    }),
    httpSampler({
      name: "READ Verify imported product",
      method: "GET",
      endpoint: "/api/products",
      query: { name: "search", value: "${unique_product}" },
      children: `${responseCodeAssertion()}${jsr223Assertion("Validate exact imported product", searchAssert)}`,
    }),
  ].join("");
}

function csvConfig() {
  return `
        <CSVDataSet guiclass="TestBeanGUI" testclass="CSVDataSet" testname="CSV Data Set - 80 independent accounts" enabled="true">
          <stringProp name="delimiter">,</stringProp><stringProp name="fileEncoding">UTF-8</stringProp>
          <stringProp name="filename">${csvRelative}</stringProp><boolProp name="ignoreFirstLine">true</boolProp>
          <boolProp name="quotedData">true</boolProp><boolProp name="recycle">true</boolProp>
          <stringProp name="shareMode">shareMode.all</stringProp><boolProp name="stopThread">false</boolProp>
          <stringProp name="variableNames">email,password,new_password,coupon_code,coupon_total,expected_discount,expected_final,product_prefix,product_price,product_description,product_image_url,category_id</stringProp>
        </CSVDataSet><hashTree/>`;
}

function globalHeaders() {
  return `
        <HeaderManager guiclass="HeaderPanel" testclass="HeaderManager" testname="JSON headers" enabled="true">
          <collectionProp name="HeaderManager.headers">
            <elementProp name="Accept" elementType="Header"><stringProp name="Header.name">Accept</stringProp><stringProp name="Header.value">application/json</stringProp></elementProp>
            <elementProp name="Content-Type" elementType="Header"><stringProp name="Header.name">Content-Type</stringProp><stringProp name="Header.value">application/json</stringProp></elementProp>
          </collectionProp>
        </HeaderManager><hashTree/>`;
}

function timer() {
  return `
        <UniformRandomTimer guiclass="UniformRandomTimerGui" testclass="UniformRandomTimer" testname="Think time 200-500 ms" enabled="true">
          <stringProp name="ConstantTimer.delay">200</stringProp><stringProp name="RandomTimer.range">300</stringProp>
        </UniformRandomTimer><hashTree/>`;
}

function threadGroup({ name, threads, ramp, duration = "", delay = "", loops = -1, scheduler = true }) {
  return `
      <ThreadGroup guiclass="ThreadGroupGui" testclass="ThreadGroup" testname="${escapeXml(name)}" enabled="true">
        <stringProp name="ThreadGroup.on_sample_error">continue</stringProp>
        <elementProp name="ThreadGroup.main_controller" elementType="LoopController" guiclass="LoopControlPanel" testclass="LoopController" testname="Loop Controller" enabled="true">
          <boolProp name="LoopController.continue_forever">${loops === -1}</boolProp><intProp name="LoopController.loops">${loops}</intProp>
        </elementProp>
        <stringProp name="ThreadGroup.num_threads">${threads}</stringProp><stringProp name="ThreadGroup.ramp_time">${ramp}</stringProp>
        <boolProp name="ThreadGroup.scheduler">${scheduler}</boolProp><stringProp name="ThreadGroup.duration">${duration}</stringProp><stringProp name="ThreadGroup.delay">${delay}</stringProp>
        <boolProp name="ThreadGroup.same_user_on_next_iteration">true</boolProp>
      </ThreadGroup>
      <hashTree>${workflow()}
      </hashTree>`;
}

function listener(type, enabled = true) {
  const mapping = {
    Load: ["SummaryReport", "Summary Report"],
    Stress: ["StatVisualizer", "Aggregate Report"],
    Spike: ["ViewResultsFullVisualizer", "View Results Tree (load JTL after run)"],
  };
  const [guiClass, name] = mapping[type];
  return `
      <ResultCollector guiclass="${guiClass}" testclass="ResultCollector" testname="${name}" enabled="${enabled}">
        <boolProp name="ResultCollector.error_logging">false</boolProp>
        <objProp><name>saveConfig</name><value class="SampleSaveConfiguration"/></objProp>
        <stringProp name="filename"></stringProp>
      </ResultCollector><hashTree/>`;
}

function testPlan({ title, comments, groups, listenerType = null, listenerEnabled = true }) {
  return `<?xml version="1.0" encoding="UTF-8"?>
<jmeterTestPlan version="1.2" properties="5.0" jmeter="5.6.3">
  <hashTree>
    <TestPlan guiclass="TestPlanGui" testclass="TestPlan" testname="${escapeXml(title)}" enabled="true">
      <stringProp name="TestPlan.comments">${escapeXml(comments)}</stringProp>
      <boolProp name="TestPlan.functional_mode">false</boolProp><boolProp name="TestPlan.serialize_threadgroups">false</boolProp>
      <elementProp name="TestPlan.user_defined_variables" elementType="Arguments" guiclass="ArgumentsPanel" testclass="Arguments" testname="User Defined Variables" enabled="true"><collectionProp name="Arguments.arguments"/></elementProp>
      <stringProp name="TestPlan.user_define_classpath"></stringProp>
    </TestPlan>
    <hashTree>${csvConfig()}${globalHeaders()}${timer()}${groups.map((group) => threadGroup(group)).join("")}${listenerType ? listener(listenerType, listenerEnabled) : ""}
    </hashTree>
  </hashTree>
</jmeterTestPlan>
`;
}

const plans = [
  {
    filename: `${studentId}_Smoke_${runDate}.jmx`,
    title: "HW05 FR03-FR09-FR16 Smoke",
    comments: "One user, one iteration. Validates correlation and business assertions before official runs.",
    groups: [{ name: "Smoke - 1 VU x 1 iteration", threads: 1, ramp: 1, loops: 1, scheduler: false }],
  },
  {
    filename: `${studentId}_Load_${runDate}.jmx`,
    title: "HW05 FR03-FR09-FR16 Load",
    comments: "Steady realistic load: 6 VUs, 15-second ramp-up, 120-second duration, shared 200-500 ms think time.",
    groups: [{ name: "Load - 6 VUs steady", threads: 6, ramp: 15, duration: 120, delay: 0 }],
    listenerType: "Load",
  },
  {
    filename: `${studentId}_Stress_${runDate}.jmx`,
    title: "HW05 FR03-FR09-FR16 Stress",
    comments: "Three one-minute stages at 6, 12, and 24 VUs. Each stage starts after the prior stage to expose degradation by concurrency level.",
    groups: [
      { name: "Stress stage 1 - 6 VUs", threads: 6, ramp: 10, duration: 60, delay: 0 },
      { name: "Stress stage 2 - 12 VUs", threads: 12, ramp: 10, duration: 60, delay: 60 },
      { name: "Stress stage 3 - 24 VUs", threads: 24, ramp: 10, duration: 60, delay: 120 },
    ],
    listenerType: "Stress",
  },
  {
    filename: `${studentId}_Spike_${runDate}.jmx`,
    title: "HW05 FR03-FR09-FR16 Spike",
    comments: "3-VU baseline for 45 seconds, abrupt 30-VU spike for 30 seconds, then 3-VU recovery for 45 seconds.",
    groups: [
      { name: "Spike baseline - 3 VUs", threads: 3, ramp: 5, duration: 45, delay: 0 },
      { name: "Spike burst - 30 VUs", threads: 30, ramp: 1, duration: 30, delay: 45 },
      { name: "Spike recovery - 3 VUs", threads: 3, ramp: 1, duration: 45, delay: 75 },
    ],
    listenerType: "Spike",
    listenerEnabled: false,
  },
  {
    filename: `${studentId}_Soak_${runDate}.jmx`,
    title: "HW05 FR03-FR09-FR16 Soak",
    comments: "Ten-minute sustained run at 30 VUs, selected after the valid 30-VU spike completed with zero errors. Uses the same workflow, assertions, CSV data, and think time.",
    groups: [{ name: "Soak - 30 VUs sustained", threads: 30, ramp: 30, duration: 600, delay: 0 }],
  },
];

for (const plan of plans) {
  const target = path.join(root, "test-plans", plan.filename);
  fs.writeFileSync(target, testPlan(plan));
}

console.log(`Generated ${plans.length} JMX plans, ${csvRows.length - 1} CSV rows, and the seed SQL file.`);
