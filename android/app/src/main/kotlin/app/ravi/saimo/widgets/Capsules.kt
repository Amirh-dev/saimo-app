package app.ravi.saimo.widgets

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import kotlin.math.floor
import kotlin.math.max
import kotlin.math.min

/**
 * Today's tasks as capsules, one per task, filling in its stage's colour
 * like «خلاصه فعالیت امروز» on the app's home: green done, orange running,
 * blue partly done, an empty track not started.
 *
 * Each colour is its own white mask, all the same size, that the layout
 * stacks and tints by colour resource; so from Android 12 they follow a
 * light/dark switch like the text does.
 */
object Capsules {
    class Layers(
        val track: Bitmap,
        val green: Bitmap,
        val orange: Bitmap,
        val blue: Bitmap,
        /** «+۷» on the last capsule when not every task fits. */
        val more: Bitmap,
    )

    private const val GAP_DP = 5f
    private const val MIN_WIDTH_DP = 11f

    /**
     * Capsules for [tasks] in at most [widthDp] × [heightDp], each no wider
     * than [maxWidthDp]. Past what fits, the last capsule counts the rest;
     * the running task always keeps its place.
     */
    fun render(
        context: Context,
        tasks: List<WidgetTask>,
        now: Long,
        widthDp: Float,
        heightDp: Float,
        maxWidthDp: Float,
    ): Layers {
        val density = context.resources.displayMetrics.density
        val fits = max(1, floor((widthDp + GAP_DP) / (MIN_WIDTH_DP + GAP_DP)).toInt())
        val (shown, rest) = pick(tasks, now, fits)
        val count = shown.size + if (rest > 0) 1 else 0

        val capW = min(maxWidthDp, (widthDp - GAP_DP * (count - 1)) / count)
        val totalW = capW * count + GAP_DP * (count - 1)
        val w = max(1, (totalW * density).toInt())
        val h = max(1, (heightDp * density).toInt())
        val cap = capW * density
        val gap = GAP_DP * density

        fun mask() = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888).apply {
            this.density = context.resources.displayMetrics.densityDpi
        }
        val layers = Layers(mask(), mask(), mask(), mask(), mask())
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.WHITE }

        // Right to left, as the day reads: the first task on the right.
        fun slot(i: Int): RectF {
            val right = w - i * (cap + gap)
            return RectF(right - cap, 0f, right, h.toFloat())
        }

        for ((i, task) in shown.withIndex()) {
            val r = slot(i)
            Canvas(layers.track).drawRoundRect(r, cap / 2, cap / 2, paint)
            val stage = task.stageAt(now)
            val fraction = when (stage) {
                TaskStage.DONE -> 1f
                TaskStage.NOT_STARTED -> 0f
                else -> if (task.plannedSec > 0) task.workedAt(now).toFloat() / task.plannedSec else 0f
            }
            if (fraction <= 0f) continue
            val layer = when (stage) {
                TaskStage.DONE -> layers.green
                TaskStage.RUNNING -> layers.orange
                else -> layers.blue
            }
            // Never shorter than round: a little progress is a dot.
            val fill = max(cap, r.height() * fraction.coerceAtMost(1f))
            Canvas(layer).drawRoundRect(RectF(r.left, r.bottom - fill, r.right, r.bottom), cap / 2, cap / 2, paint)
        }

        if (rest > 0) {
            val r = slot(shown.size)
            Canvas(layers.track).drawRoundRect(r, cap / 2, cap / 2, paint)
            // «۷+» in a right-to-left line reads «+۷».
            val text = TextImages.render(context, "${HomeWidgets.fa(rest)}+", 10.5f, 900)
            Canvas(layers.more).drawBitmap(
                text,
                r.centerX() - text.width / 2f,
                r.centerY() - text.height / 2f,
                null,
            )
        }
        return layers
    }

    /** The tasks that get a capsule of their own, and how many are left over. */
    private fun pick(tasks: List<WidgetTask>, now: Long, fits: Int): Pair<List<WidgetTask>, Int> {
        if (tasks.size <= fits) return tasks to 0
        val room = max(1, fits - 1)
        val shown = tasks.take(room).toMutableList()
        val running = tasks.firstOrNull { it.stageAt(now) == TaskStage.RUNNING }
        if (running != null && running !in shown) shown[room - 1] = running
        return shown to tasks.size - shown.size
    }
}
