package nuviapps.co.hilo

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF

/**
 * Lightweight native Canvas renderer for GitHub-style emerald heatmap grids
 * inside Android Home Screen widgets.
 */
object HeatmapBitmapRenderer {

    private val darkPalette = intArrayOf(
        Color.parseColor("#24272E"),
        Color.parseColor("#193D2D"),
        Color.parseColor("#216646"),
        Color.parseColor("#2B9462"),
        Color.parseColor("#3CD08B"),
    )

    private val lightPalette = intArrayOf(
        Color.parseColor("#ECEAE4"),
        Color.parseColor("#C7E8D5"),
        Color.parseColor("#7ED4A8"),
        Color.parseColor("#34B37A"),
        Color.parseColor("#158052"),
    )

    fun render(
        context: Context,
        levels: IntArray,
        columns: Int,
        rows: Int = 7,
        cellSizeDp: Float = 12f,
        gapDp: Float = 3f,
        isDark: Boolean = true,
    ): Bitmap {
        val density = context.resources.displayMetrics.density
        val cellPx = cellSizeDp * density
        val gapPx = gapDp * density
        val radiusPx = cellPx * 0.26f

        val width = (columns * cellPx + (columns - 1) * gapPx).toInt().coerceAtLeast(1)
        val height = (rows * cellPx + (rows - 1) * gapPx).toInt().coerceAtLeast(1)

        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.FILL
        }

        val palette = if (isDark) darkPalette else lightPalette
        val rect = RectF()

        for (col in 0 until columns) {
            for (row in 0 until rows) {
                val index = col * rows + row
                val level = if (index < levels.size) levels[index].coerceIn(0, 4) else 0
                paint.color = palette[level]

                val left = col * (cellPx + gapPx)
                val top = row * (cellPx + gapPx)
                rect.set(left, top, left + cellPx, top + cellPx)
                canvas.drawRoundRect(rect, radiusPx, radiusPx, paint)
            }
        }
        return bitmap
    }
}
