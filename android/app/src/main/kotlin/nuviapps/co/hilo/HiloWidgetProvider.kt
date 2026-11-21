package nuviapps.co.hilo

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import org.json.JSONObject

/**
 * 4x2 Standard Android Home Screen widget displaying the 16-week GitHub-style
 * contribution heatmap, flexible streak badge, and interactive quick check-in rows.
 */
class HiloWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val rawJson = widgetData.getString("hilo_widget_snapshot_json", null)
        val snapshot = rawJson?.let { runCatching { JSONObject(it) }.getOrNull() }

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.hilo_widget_standard)

            val launchIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
            )
            views.setOnClickPendingIntent(R.id.widget_header, launchIntent)

            val streak = snapshot?.optInt("streak", 0) ?: 0
            views.setTextViewText(R.id.widget_streak_badge, "${streak}d")

            val levels = parseLevels(snapshot?.optJSONArray("heatmap"), 112)
            val bitmap = HeatmapBitmapRenderer.render(
                context = context,
                levels = levels,
                columns = 16,
                rows = 7,
                cellSizeDp = 11f,
                gapDp = 2.5f,
                isDark = true,
            )
            views.setImageViewBitmap(R.id.widget_heatmap_image, bitmap)

            val habits = snapshot?.optJSONArray("habits") ?: JSONArray()
            bindHabitRow(
                context = context,
                views = views,
                habit = habits.optJSONObject(0),
                rowId = R.id.habit_row_1,
                checkId = R.id.habit_check_1,
                titleId = R.id.habit_title_1,
                progressId = R.id.habit_progress_1,
            )
            bindHabitRow(
                context = context,
                views = views,
                habit = habits.optJSONObject(1),
                rowId = R.id.habit_row_2,
                checkId = R.id.habit_check_2,
                titleId = R.id.habit_title_2,
                progressId = R.id.habit_progress_2,
            )

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun bindHabitRow(
        context: Context,
        views: RemoteViews,
        habit: JSONObject?,
        rowId: Int,
        checkId: Int,
        titleId: Int,
        progressId: Int,
    ) {
        if (habit == null) {
            views.setViewVisibility(rowId, View.GONE)
            return
        }
        views.setViewVisibility(rowId, View.VISIBLE)
        val id = habit.optString("id", "")
        val title = habit.optString("title", "Hábito")
        val done = habit.optBoolean("done", false)
        val progress = habit.optString("progress", "")

        views.setTextViewText(titleId, title)
        views.setTextViewText(progressId, progress)
        views.setTextViewText(checkId, if (done) "●" else "○")

        if (id.isNotEmpty()) {
            val uri = Uri.parse("hilo://widget/toggle?id=$id")
            val pendingIntent = HomeWidgetBackgroundIntent.getBroadcast(context, uri)
            views.setOnClickPendingIntent(rowId, pendingIntent)
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
