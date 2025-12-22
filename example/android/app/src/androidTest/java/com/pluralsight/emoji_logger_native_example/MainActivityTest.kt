package com.pluralsight.emoji_logger_native_example

import androidx.test.ext.junit.runners.AndroidJUnit4
import dev.flutter.plugins.integration_test.FlutterTestRunner
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class MainActivityTest : FlutterTestRunner(MainActivityTest::class.java) {

    @Test
    fun runFlutterIntegrationTests() {
        // 这个方法必须存在
        // Flutter integration_test 会在 Dart 层真正执行测试
    }
}
