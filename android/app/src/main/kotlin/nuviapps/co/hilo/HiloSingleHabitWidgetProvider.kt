package nuviapps.co.hilo

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import org.json.JSONObject

/**
 * 2x2 Compact Android Home Screen widget redesigned specifically for a square
 * footprint: big streak counter, crisp full-width 7-day (Mon..Sun) emerald bar,
 * and a full-width one-tap check-in pill button.
 */
class HiloSingleHabitWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val rawJson = widgetData.getString("hilo_widget_snapshot_json", null)
        val snapshot = rawJson?.let { runCatching { JSONObject(it) }.getOrNull() }
        val firstHabit = snapshot?.optJSONArray("habits")?.optJSONObject(0)

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.hilo_widget_compact)

            val launchIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
            )
            views.setOnClickPendingIntent(R.id.compact_header, launchIntent)

            val title = firstHabit?.optString("title", "Hilo") ?: "Hilo"
            val weekly = firstHabit?.optString("weekly", "0/7 esta semana") ?: "0/7 esta semana"
            val streak = firstHabit?.optInt("streak", 0) ?: 0
            val done = firstHabit?.optBoolean("done", false) ?: false
            val habitId = firstHabit?.optString("id", "") ?: ""

            views.setTextViewText(R.id.compact_title, title)
            views.setTextViewText(R.id.compact_streak_big, "${streak}d")
            views.setTextViewText(R.id.compact_weekly, weekly)
            views.setTextViewText(
                R.id.compact_action_btn,
                if (done) "✓ Completado" else "+ Registrar",
            )

            // Crisp single-row 7-day (Mon..Sun) emerald bar spanning 100% width
            val weekLevels = parseLevels(firstHabit?.optJSONArray("miniGrid"), 7)
            val bitmap = HeatmapBitmapRenderer.render(
                context = context,
                levels = weekLevels,
                columns = 7,
                rows = 1,
                cellSizeDp = 16f,
                gapDp = 4f,
                isDark = true,
            )
            views.setImageViewBitmap(R.id.compact_week_bar, bitmap)

            if (habitId.isNotEmpty()) {
                val uri = Uri.Builder()
                    .scheme("hilo")
                    .authority("widget")
                    .appendPath("toggle")
                    .appendQueryParameter("id", habitId)
                    .build()
                val pendingIntent = HomeWidgetBackgroundIntent.getBroadcast(context, uri)
                views.setOnClickPendingIntent(R.id.compact_action_btn, pendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun parseLevels(array: JSONArray?, expectedSize: Int): IntArray {
        val result = IntArray(expectedSize)
        if (array == null) return result
        val count = minOf(array.length(), expectedSize)
        for (i in 0 until count) {
            result[i] = array.optInt(i, 0).coerceIn(0, 4)
        }
        return result
    }
}
