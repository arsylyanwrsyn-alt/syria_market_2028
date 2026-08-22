ng Android
2m 1s




WARNING: Your app uses the following plugins that apply Kotlin Gradle Plugin (KGP): flutter_image_compress_common
Future versions of Flutter will fail to build if your app uses plugins that apply KGP.

Please check the changelogs of these plugins and upgrade to a version that supports Built-in Kotlin.
If no such version exists, report the issue to the plugin. If necessary, here is a guide on filing
an issue against a plugin: https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers#report-incompatible-kotlin-gradle-plugin-usage-to-plugin-authors

If you are a plugin author, please migrate your plugin to Built-in Kotlin using this guide: https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-plugin-authors
Checking the license for package Android SDK Platform 36 in /usr/local/share/android-sdk/licenses
License for package Android SDK Platform 36 accepted.
Preparing "Install Android SDK Platform 36 (revision 2)".
"Install Android SDK Platform 36 (revision 2)" ready.
Installing Android SDK Platform 36 in /usr/local/share/android-sdk/platforms/android-36
"Install Android SDK Platform 36 (revision 2)" complete.
"Install Android SDK Platform 36 (revision 2)" finished.
lib/screens/home/views/home_main_content_view.dart:86:26: Error: The method 'BannerCarouselWidget' isn't defined for the type 'HomeMainContentView'.
 - 'HomeMainContentView' is from 'package:souq_syria/screens/home/views/home_main_content_view.dart' ('lib/screens/home/views/home_main_content_view.dart').
Try correcting the name to the name of an existing method, or defining a method named 'BannerCarouselWidget'.
                  return BannerCarouselWidget(banners: banners);
                         ^^^^^^^^^^^^^^^^^^^^
lib/widgets/banner_carousel_widget.dart:86:26: Error: The method 'BannerCarouselWidget' isn't defined for the type 'HomeMainContentView'.
 - 'HomeMainContentView' is from 'package:souq_syria/widgets/banner_carousel_widget.dart' ('lib/widgets/banner_carousel_widget.dart').
Try correcting the name to the name of an existing method, or defining a method named 'BannerCarouselWidget'.
                  return BannerCarouselWidget(banners: banners);
                         ^^^^^^^^^^^^^^^^^^^^
Target kernel_snapshot_program failed: Exception


FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:compileFlutterBuildDebug'.
> Process 'command '/Users/builder/programs/flutter/bin/flutter'' finished with non-zero exit value 1

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to generate a Build Scan (Powered by Develocity).
> Get more help at https://help.gradle.org.

BUILD FAILED in 1m 57s
[=========                              ] 25%                                   
Running Gradle task 'assembleDebug'...                            118.7s
Gradle task assembleDebug failed with exit code 1


Build failed :|
Failed to build for Android
