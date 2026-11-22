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
 * 4x4 Expanded Dashboard Android Home Screen widget displaying the 16-week
 * emerald GitHub heatmap, consistency & streak pills, and up to 5 interactive
 * habit check-in rows.
 */
class HiloExpandedWidgetProvider : HomeWidgetProvider() {

    private data class RowIds(
        val rowId: Int,
        val checkId: Int,
        val titleId: Int,
        val progressId: Int,
    )

    private val rowSlots = listOf(
        RowIds(R.id.exp_row_1, R.id.exp_check_1, R.id.exp_title_1, R.id.exp_progress_1),
        RowIds(R.id.exp_row_2, R.id.exp_check_2, R.id.exp_title_2, R.id.exp_progress_2),
        RowIds(R.id.exp_row_3, R.id.exp_check_3, R.id.exp_title_3, R.id.exp_progress_3),
        RowIds(R.id.exp_row_4, R.id.exp_check_4, R.id.exp_title_4, R.id.exp_progress_4),
        RowIds(R.id.exp_row_5, R.id.exp_check_5, R.id.exp_title_5, R.id.exp_progress_5),
    )

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val rawJson = widgetData.getString("hilo_widget_snapshot_json", null)
        val snapshot = rawJson?.let { runCatching { JSONObject(it) }.getOrNull() }

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.hilo_widget_expanded)

            val launchIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
            )
            views.setOnClickPendingIntent(R.id.exp_header, launchIntent)

            val streak = snapshot?.optInt("streak", 0) ?: 0
            val consistency = snapshot?.optInt("consistency", 0) ?: 0
            val completedToday = snapshot?.optInt("completedToday", 0) ?: 0
            val totalToday = snapshot?.optInt("totalToday", 0) ?: 0

            views.setTextViewText(R.id.exp_subtitle, "Hoy $completedToday/$totalToday · $consistency% (30d)")
            views.setTextViewText(R.id.exp_streak_badge, "${streak}d")

            val levels = parseLevels(snapshot?.optJSONArray("heatmap"), 112)
            val bitmap = HeatmapBitmapRenderer.render(
                context = context,
                levels = levels,
                columns = 16,
                rows = 7,
                cellSizeDp = 11.5f,
                gapDp = 2.6f,
                isDark = true,
            )
            views.setImageViewBitmap(R.id.exp_heatmap_image, bitmap)

            val habits = snapshot?.optJSONArray("habits") ?: JSONArray()
            for (index in rowSlots.indices) {
                bindHabitRow(
                    context = context,
                    views = views,
                    habit = habits.optJSONObject(index),
                    slot = rowSlots[index],
                )
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun bindHabitRow(
        context: Context,
        views: RemoteViews,
        habit: JSONObject?,
        slot: RowIds,
    ) {
        if (habit == null) {
            views.setViewVisibility(slot.rowId, View.GONE)
            return
        }
        views.setViewVisibility(slot.rowId, View.VISIBLE)
        val id = habit.optString("id", "")
        val title = habit.optString("title", "Hábito")
        val done = habit.optBoolean("done", false)
        val progress = habit.optString("progress", "")

        views.setTextViewText(slot.titleId, title)
        views.setTextViewText(slot.progressId, progress)
        views.setTextViewText(slot.checkId, if (done) "●" else "○")

        if (id.isNotEmpty()) {
            val uri = Uri.Builder()
                .scheme("hilo")
                .authority("widget")
                .appendPath("toggle")
                .appendQueryParameter("id", id)
                .build()
            val pendingIntent = HomeWidgetBackgroundIntent.getBroadcast(context, uri)
            views.setOnClickPendingIntent(slot.rowId, pendingIntent)
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
