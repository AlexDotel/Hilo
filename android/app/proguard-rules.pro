# Keep Hilo Android Home Screen widgets and home_widget callbacks
-keep class nuviapps.co.hilo.HiloWidgetProvider { *; }
-keep class nuviapps.co.hilo.HiloExpandedWidgetProvider { *; }
-keep class nuviapps.co.hilo.HiloSingleHabitWidgetProvider { *; }
-keep class nuviapps.co.hilo.HeatmapBitmapRenderer { *; }
-keep class es.antonborri.home_widget.** { *; }

# Keep SQLCipher native bindings
-keep class net.sqlcipher.** { *; }
-keep class net.sqlcipher.database.** { *; }
