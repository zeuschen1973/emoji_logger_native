# ================================
# Firebase Test Lab run script
# ================================

$APP_APK  = "C:\Temp\tempzc\Flutter\Code\emoji_logger_native\example\build\app\outputs\apk\debug\app-debug.apk"
$TEST_APK = "C:\Temp\tempzc\Flutter\Code\emoji_logger_native\example\build\app\outputs\apk\androidTest\debug\app-debug-androidTest.apk"

# Pixel 8a: akita   Pixel 8: shiba   Pixel 8 Pro: husky   Pixel 9: tokay
$DEVICE = "model=akita,version=34,locale=en_US,orientation=portrait"

# 建议拉长一点，首次跑 integration_test + Firebase init 容易 >10m
$TIMEOUT = "30m"

# （可选但强烈建议）指定一个 GCS bucket 保存测试产物（logcat/截图/视频）
# 先在 GCP 控制台或 gsutil 创建：gsutil mb gs://<your-bucket-name>
#$RESULTS_BUCKET = "gs://<your-bucket-name>"
#$RESULTS_DIR = "emoji_logger_native_$(Get-Date -Format 'yyyyMMdd_HHmmss')"

Write-Host "Running Firebase Test Lab..."
Write-Host "App APK : $APP_APK"
Write-Host "Test APK: $TEST_APK"
Write-Host "Device  : $DEVICE"
Write-Host "Timeout : $TIMEOUT"
Write-Host "----------------------------------"

# ✅ 预检查：避免路径写错导致奇怪报错
if (-not (Test-Path $APP_APK))  { throw "App APK not found: $APP_APK" }
if (-not (Test-Path $TEST_APK)) { throw "Test APK not found: $TEST_APK" }

gcloud firebase test android run `
  --type instrumentation `
  --app "$APP_APK" `
  --test "$TEST_APK" `
  --device "$DEVICE" `
  --timeout $TIMEOUT `
  --use-orchestrator `
  --verbosity=debug  `
  --format=json
  #--results-bucket "$RESULTS_BUCKET" `
  #--results-dir "$RESULTS_DIR" `  
