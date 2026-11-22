package nuviapps.co.hilo

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import org.json.JSONObject
import java.util.Calendar

/**
 * 2x2 Expressive Android Home Screen widget inspired by Duolingo's dynamic
 * streak widget: automatically adapts its background artwork, motivational
 * message, accent color, and CTA button across 4 states:
 *   1. CELEBRATE   — Habit completed today (emerald + gold sparkles)
 *   2. URGENT      — Pending with <= 3 hours left before midnight (amber fire)
 *   3. ACTIVE      — Pending earlier in the day with active streak (obsidian sage)
 *   4. FRESH_START — Pending with 0d streak (calm twilight teal)
 */
class HiloSingleHabitWidgetProvider : HomeWidgetProvider() {

    private enum class WidgetMood {
        CELEBRATE,
        URGENT,
        ACTIVE,
        FRESH_START,
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val rawJson = widgetData.getString("hilo_widget_snapshot_json", null)
        val snapshot = rawJson?.let { runCatching { JSONObject(it) }.getOrNull() }
        val firstHabit = snapshot?.optJSONArray("habits")?.optJSONObject(0)

        val now = Calendar.getInstance()
        val currentHour = now.get(Calendar.HOUR_OF_DAY)
        val hoursLeftToday = (24 - currentHour).coerceIn(1, 24)

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

            val mood = when {
                done -> WidgetMood.CELEBRATE
                hoursLeftToday <= 3 -> WidgetMood.URGENT
                streak > 0 -> WidgetMood.ACTIVE
                else -> WidgetMood.FRESH_START
            }

            views.setTextViewText(R.id.compact_title, title)
            views.setTextViewText(R.id.compact_streak_big, "${streak}d")

            when (mood) {
                WidgetMood.CELEBRATE -> {
                    views.setImageViewResource(R.id.compact_bg_image, R.drawable.widget_bg_celebrate)
                    views.setTextColor(R.id.compact_streak_big, Color.parseColor("#48E29A"))
                    views.setTextViewText(R.id.compact_status_msg, "¡Hilo intacto! 🎉")
                    views.setTextViewText(R.id.compact_action_btn, "✓ ¡Hecho hoy!")
                    views.setInt(
                        R.id.compact_action_btn,
                        "setBackgroundResource",
                        R.drawable.hilo_widget_pill_btn_done_bg,
                    )
                }

                WidgetMood.URGENT -> {
                    views.setImageViewResource(R.id.compact_bg_image, R.drawable.widget_bg_urgent)
                    views.setTextColor(R.id.compact_streak_big, Color.parseColor("#FBBF24"))
                    views.setTextViewText(
                        R.id.compact_status_msg,
                        "⏳ ¡Quedan ${hoursLeftToday}h! Salva tu hilo",
                    )
                    views.setTextViewText(R.id.compact_action_btn, "⚡ ¡Completar ya!")
                    views.setInt(
                        R.id.compact_action_btn,
                        "setBackgroundResource",
                        R.drawable.hilo_widget_pill_btn_urgent_bg,
                    )
                }

                WidgetMood.ACTIVE -> {
                    views.setImageViewResource(R.id.compact_bg_image, R.drawable.widget_bg_active)
                    views.setTextColor(R.id.compact_streak_big, Color.parseColor("#3CD08B"))
                    views.setTextViewText(R.id.compact_status_msg, weekly)
                    views.setTextViewText(R.id.compact_action_btn, "+ Registrar")
                    views.setInt(
                        R.id.compact_action_btn,
                        "setBackgroundResource",
                        R.drawable.hilo_widget_pill_btn_bg,
                    )
                }

                WidgetMood.FRESH_START -> {
                    views.setImageViewResource(R.id.compact_bg_image, R.drawable.widget_bg_fresh)
                    views.setTextColor(R.id.compact_streak_big, Color.parseColor("#5EEAD4"))
                    views.setTextViewText(R.id.compact_status_msg, "Empieza hoy tu hilo ✨")
                    views.setTextViewText(R.id.compact_action_btn, "+ Empezar hoy")
                    views.setInt(
                        R.id.compact_action_btn,
                        "setBackgroundResource",
                        R.drawable.hilo_widget_pill_btn_bg,
                    )
                }
            }

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
