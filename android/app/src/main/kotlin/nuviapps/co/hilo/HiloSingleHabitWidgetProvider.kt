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
 * 4x2 Wide Android Home Screen widget for a single highlighted habit
 * matching the full-width 16-week GitHub heatmap layout with streak badge
 * and one-tap check-in button.
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
            val weekly = firstHabit?.optString("weekly", "Crea un hábito") ?: "Crea un hábito"
            val streak = firstHabit?.optInt("streak", 0) ?: 0
            val done = firstHabit?.optBoolean("done", false) ?: false
            val habitId = firstHabit?.optString("id", "") ?: ""

            views.setTextViewText(R.id.compact_title, title)
            views.setTextViewText(R.id.compact_streak_badge, "${streak}d")
            views.setTextViewText(R.id.compact_weekly, weekly)
            views.setTextViewText(R.id.compact_status, if (done) "Completado hoy" else "Toca + para registrar")
            views.setTextViewText(R.id.compact_action_btn, if (done) "✓" else "+")

            val levels = parseLevels(firstHabit?.optJSONArray("miniGrid"), 112)
            val bitmap = HeatmapBitmapRenderer.render(
                context = context,
                levels = levels,
                columns = 16,
                rows = 7,
                cellSizeDp = 11f,
                gapDp = 2.5f,
                isDark = true,
            )
            views.setImageViewBitmap(R.id.compact_heatmap_image, bitmap)

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
