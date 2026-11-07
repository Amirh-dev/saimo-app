package app.ravi.saimo.widgets

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.SizeF
import android.view.View
import android.widget.RemoteViews
import app.ravi.saimo.R
import java.util.Calendar

/** «امروز»: today's study against the plan, the multiplier, the task being studied. */
class TodayWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        HomeWidgets.updateAll(context)
    }

    override fun onAppWidgetOptionsChanged(
        context: Context, manager: AppWidgetManager, id: Int, options: Bundle,
    ) = HomeWidgets.updateAll(context)

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == HomeWidgets.ACTION_REFRESH) HomeWidgets.updateAll(context)
        else super.onReceive(context, intent)
    }

    override fun onDisabled(context: Context) = HomeWidgets.scheduleRefresh(context)
}

/**
 * «کارهای امروز»: today's tasks with their progress. Stretched tall, the
 * «امروز» summary, capsules and multiplier join it on top.
 */
class TasksWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        HomeWidgets.updateAll(context)
    }

    // Resized: the titles are cut to the new width, and the tall layout
    // comes or goes.
    override fun onAppWidgetOptionsChanged(
        context: Context, manager: AppWidgetManager, id: Int, options: Bundle,
    ) = HomeWidgets.updateAll(context)

    override fun onDisabled(context: Context) = HomeWidgets.scheduleRefresh(context)
}

object HomeWidgets {
    const val ACTION_REFRESH = "app.ravi.saimo.widgets.REFRESH"

    private const val LIVE_REFRESH_MS = 60_000L
    private const val TASK_ROWS = 3

    /** From this height (dp) «کارهای امروز» shows the «امروز» summary on top. */
    private const val TALL_DP = 220f

    private const val LINK_HOME = "saimo://widget/home"
    private const val LINK_ADD = "saimo://widget/add"

    private val rowIds = intArrayOf(R.id.row_1, R.id.row_2, R.id.row_3)
    private val dotIds = intArrayOf(R.id.row_1_dot, R.id.row_2_dot, R.id.row_3_dot)
    private val checkIds = intArrayOf(R.id.row_1_check, R.id.row_2_check, R.id.row_3_check)
    private val titleIds = intArrayOf(R.id.row_1_title, R.id.row_2_title, R.id.row_3_title)
    private val trailIds = intArrayOf(R.id.row_1_trail, R.id.row_2_trail, R.id.row_3_trail)
    private val barIds = arrayOf(
        intArrayOf(R.id.row_1_bar_orange, R.id.row_1_bar_blue, R.id.row_1_bar_green),
        intArrayOf(R.id.row_2_bar_orange, R.id.row_2_bar_blue, R.id.row_2_bar_green),
        intArrayOf(R.id.row_3_bar_orange, R.id.row_3_bar_blue, R.id.row_3_bar_green),
    )

    /** Redraws every placed widget from the stored snapshot. */
    fun updateAll(context: Context) {
        val manager = AppWidgetManager.getInstance(context)
        val now = System.currentTimeMillis()
        val day = WidgetStore.read(context, now)

        for (id in manager.getAppWidgetIds(ComponentName(context, TodayWidgetProvider::class.java))) {
            val (width, height) = sizeDp(manager, id, 150f, 170f)
            manager.updateAppWidget(id, today(context, day, now, width, height))
        }
        for (id in manager.getAppWidgetIds(ComponentName(context, TasksWidgetProvider::class.java))) {
            val (width, height) = sizeDp(manager, id, 320f, 150f)
            val views = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                // The launcher picks the layout that fits as the user resizes.
                RemoteViews(
                    mapOf(
                        SizeF(180f, 100f) to tasks(context, day, now, width, tall = false),
                        SizeF(180f, TALL_DP) to tasks(context, day, now, width, tall = true),
                    ),
                )
            } else {
                tasks(context, day, now, width, tall = height >= TALL_DP)
            }
            manager.updateAppWidget(id, views)
        }
        scheduleRefresh(context)
    }

    /** The widget's size on the home screen in portrait, in dp. */
    private fun sizeDp(manager: AppWidgetManager, id: Int, width: Float, height: Float): Pair<Float, Float> {
        val options = manager.getAppWidgetOptions(id)
        val w = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
        val h = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT)
        return (if (w > 0) w.toFloat() else width) to (if (h > 0) h.toFloat() else height)
    }

    // ------------------------------------------------------------- «امروز»

    private fun today(
        context: Context, day: WidgetDay, now: Long, widthDp: Float, heightDp: Float,
    ): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_today)
        views.setOnClickPendingIntent(R.id.widget_root, open(context, LINK_HOME, 0))
        val inner = widthDp - 28f
        text(context, views, R.id.today_title, "امروز", 13f, 700, R.color.widget_text)

        val today = day as? WidgetDay.Today
        if (today == null || today.tasks.isEmpty()) {
            views.setViewVisibility(R.id.today_content, View.GONE)
            views.setViewVisibility(R.id.today_empty, View.VISIBLE)
            views.setViewVisibility(R.id.streak_pill, View.GONE)
            views.setViewVisibility(R.id.today_mark, View.VISIBLE)
            text(
                context, views, R.id.today_empty, emptyMessage(day), 12f, 400, R.color.widget_muted,
                maxWidthDp = inner, maxLines = 3, centered = true,
            )
            return views
        }
        views.setViewVisibility(R.id.today_content, View.VISIBLE)
        views.setViewVisibility(R.id.today_empty, View.GONE)

        // The multiplier takes the logo's place once the app has sent it.
        val hasStreak = bindStreakPill(context, views, today)
        views.setViewVisibility(R.id.today_mark, if (hasStreak) View.GONE else View.VISIBLE)
        // What is left of the height after the padding, the title, the
        // minutes, the gaps and the bottom line; the view only shrinks it.
        bindSummary(
            context, views, today, now,
            capsWidthDp = inner, capsHeightDp = (heightDp - 132f).coerceIn(28f, 110f),
            maxCapsuleDp = 20f, minutesSp = 26f,
        )

        // Studying now: the task as a capsule that opens its timer.
        // Otherwise what keeps the multiplier, or how far the plan is.
        val running = today.running(now)
        if (running != null) {
            views.setViewVisibility(R.id.today_footer, View.GONE)
            views.setViewVisibility(R.id.today_capsule, View.VISIBLE)
            text(
                context, views, R.id.today_capsule_text, running.title, 11f, 700,
                R.color.widget_streak_text, maxWidthDp = inner - 20f - 12f,
            )
            views.setOnClickPendingIntent(R.id.today_capsule, open(context, taskLink(running), 10))
        } else {
            views.setViewVisibility(R.id.today_capsule, View.GONE)
            views.setViewVisibility(R.id.today_footer, View.VISIBLE)
            val (line, color) = streakLine(today, now) ?: (countLine(today, now) to R.color.widget_text)
            text(
                context, views, R.id.today_footer, line, 11.5f, 700, color,
                maxWidthDp = inner, centered = true,
            )
        }
        return views
    }

    /** «×۳» with the flame; false when the app has not sent the multiplier. */
    private fun bindStreakPill(context: Context, views: RemoteViews, today: WidgetDay.Today): Boolean {
        val streak = today.streak
        if (streak == null) {
            views.setViewVisibility(R.id.streak_pill, View.GONE)
            return false
        }
        views.setViewVisibility(R.id.streak_pill, View.VISIBLE)
        text(context, views, R.id.streak_text, "${fa(streak.level)}×", 11f, 800, R.color.widget_streak_text)
        return true
    }

    /**
     * «۱۰۲ از ۲۰۰ دقیقه» and a capsule per task in [capsWidthDp] ×
     * [capsHeightDp]; returns the width the capsules took, in dp.
     */
    private fun bindSummary(
        context: Context, views: RemoteViews, today: WidgetDay.Today, now: Long,
        capsWidthDp: Float, capsHeightDp: Float, maxCapsuleDp: Float, minutesSp: Float,
    ): Float {
        val planned = today.plannedSec()
        val worked = today.workedAt(now)
        text(context, views, R.id.today_minutes, fa(worked / 60), minutesSp, 800, R.color.widget_text)
        text(
            context, views, R.id.today_planned, "از ${fa(planned / 60)} دقیقه", 10.5f, 400,
            R.color.widget_muted,
        )

        val caps = Capsules.render(context, today.tasks, now, capsWidthDp, capsHeightDp, maxCapsuleDp)
        for ((id, bitmap, color) in listOf(
            Triple(R.id.caps_track, caps.track, R.color.widget_track),
            Triple(R.id.caps_green, caps.green, R.color.widget_green),
            Triple(R.id.caps_orange, caps.orange, R.color.widget_orange),
            Triple(R.id.caps_blue, caps.blue, R.color.widget_blue),
            Triple(R.id.caps_more, caps.more, R.color.widget_text),
        )) {
            views.setImageViewBitmap(id, bitmap)
            tint(context, views, id, "setColorFilter", color)
        }
        views.setContentDescription(R.id.caps_track, countLine(today, now))
        return TextImages.widthDp(context, caps.track)
    }

    /** «۲ از ۵ کار انجام شد» */
    private fun countLine(today: WidgetDay.Today, now: Long): String {
        val done = today.doneCount(now)
        val total = today.tasks.size
        return if (done == total) "همه‌ی کارها انجام شد" else "${fa(done)} از ${fa(total)} کار انجام شد"
    }

    /** What keeps today's multiplier, or null without a timed plan. */
    private fun streakLine(today: WidgetDay.Today, now: Long): Pair<String, Int>? {
        val streak = today.streak ?: return null
        if (!streak.hasPlan) return null
        val remaining = today.streakRemainingSec(now)
        if (streak.countedToday || remaining <= 0) return "امروز حساب شد" to R.color.widget_green
        val minutes = (remaining + 59) / 60
        return "${fa(minutes)} دقیقه تا حفظ ضریب" to R.color.widget_streak_text
    }


    // ------------------------------------------------------- «کارهای امروز»

    private fun tasks(
        context: Context, day: WidgetDay, now: Long, widthDp: Float, tall: Boolean,
    ): RemoteViews {
        val layout = if (tall) R.layout.widget_tasks_large else R.layout.widget_tasks
        val views = RemoteViews(context.packageName, layout)
        views.setOnClickPendingIntent(R.id.widget_root, open(context, LINK_HOME, 0))
        views.setOnClickPendingIntent(R.id.tasks_add, open(context, LINK_ADD, 20))

        val today = day as? WidgetDay.Today
        val empty = today == null || today.tasks.isEmpty()
        if (tall) {
            text(context, views, R.id.today_title, "امروز", 14f, 700, R.color.widget_text)
        } else {
            text(context, views, R.id.tasks_title, "کارهای امروز", 13f, 700, R.color.widget_text)
            val date = today?.date.orEmpty()
            if (date.isNotEmpty()) text(context, views, R.id.tasks_date, date, 10.5f, 400, R.color.widget_muted)
        }

        if (empty) {
            views.setViewVisibility(R.id.tasks_rows, View.GONE)
            views.setViewVisibility(R.id.tasks_empty, View.VISIBLE)
            if (tall) {
                views.setViewVisibility(R.id.summary, View.GONE)
            } else {
                views.setViewVisibility(R.id.tasks_count, View.GONE)
            }
            text(
                context, views, R.id.tasks_empty, emptyMessage(day), 12f, 400, R.color.widget_muted,
                maxWidthDp = widthDp - 28f, maxLines = 2, centered = true,
            )
            return views
        }
        today!!
        views.setViewVisibility(R.id.tasks_rows, View.VISIBLE)
        views.setViewVisibility(R.id.tasks_empty, View.GONE)

        if (tall) {
            // The «امروز» widget folded into the top.
            bindStreakPill(context, views, today)
            // Capsules take up to about half the width; the count and the
            // multiplier line beside them get the rest.
            val capsWidth = bindSummary(
                context, views, today, now,
                capsWidthDp = (widthDp - 28f) * 0.55f, capsHeightDp = 54f,
                maxCapsuleDp = 18f, minutesSp = 20f,
            )
            val summaryWidth = widthDp - 28f - capsWidth - 14f
            text(
                context, views, R.id.summary_count, countLine(today, now), 12f, 700,
                R.color.widget_text, maxWidthDp = summaryWidth,
            )
            val streak = streakLine(today, now)
            if (streak != null) {
                views.setViewVisibility(R.id.summary_hint, View.VISIBLE)
                text(
                    context, views, R.id.summary_hint, streak.first, 11f, 700, streak.second,
                    maxWidthDp = summaryWidth,
                )
            } else {
                views.setViewVisibility(R.id.summary_hint, View.GONE)
            }
        } else {
            views.setViewVisibility(R.id.tasks_count, View.VISIBLE)
            text(
                context, views, R.id.tasks_count,
                "${fa(today.doneCount(now))} از ${fa(today.tasks.size)}", 11f, 700, R.color.widget_text,
            )
        }

        // What needs the user first: the running task, then paused ones,
        // then the rest of the plan; finished tasks last.
        val order = listOf(TaskStage.RUNNING, TaskStage.PAUSED, TaskStage.NOT_STARTED, TaskStage.DONE)
        val shown = today.tasks
            .sortedBy { order.indexOf(it.stageAt(now)) }
            .take(TASK_ROWS)

        for (i in 0 until TASK_ROWS) {
            val task = shown.getOrNull(i)
            if (task == null) {
                views.setViewVisibility(rowIds[i], View.INVISIBLE)
                continue
            }
            views.setViewVisibility(rowIds[i], View.VISIBLE)
            bindRow(context, views, i, task, now, widthDp)
        }
        return views
    }

    private fun bindRow(
        context: Context, views: RemoteViews, i: Int, task: WidgetTask, now: Long, widthDp: Float,
    ) {
        val stage = task.stageAt(now)
        val planned = task.plannedSec / 60
        // Rounded up, so a task never reads «۰ دقیقه مانده» before it ends.
        val left = (task.plannedSec - task.workedAt(now) + 59) / 60
        views.setInt(
            rowIds[i], "setBackgroundResource",
            if (stage == TaskStage.RUNNING) R.drawable.widget_row_running else R.drawable.widget_row,
        )

        // A finished task gets a green check; the rest a dot in its stage colour.
        val done = stage == TaskStage.DONE
        views.setViewVisibility(checkIds[i], if (done) View.VISIBLE else View.GONE)
        views.setViewVisibility(dotIds[i], if (done) View.GONE else View.VISIBLE)
        if (!done) {
            val dot = when (stage) {
                TaskStage.RUNNING -> R.color.widget_orange
                TaskStage.PAUSED -> R.color.widget_blue
                else -> R.color.widget_idle
            }
            tint(context, views, dotIds[i], "setColorFilter", dot)
        }

        // The bar in the stage's colour; a task not started shows its
        // empty track.
        val bar = when (stage) {
            TaskStage.RUNNING -> 0
            TaskStage.DONE -> 2
            else -> 1
        }
        val progress = if (task.plannedSec > 0) task.workedAt(now) * 1000 / task.plannedSec else 0
        for ((index, id) in barIds[i].withIndex()) {
            views.setViewVisibility(id, if (index == bar) View.VISIBLE else View.GONE)
        }
        views.setProgressBar(barIds[i][bar], 1000, if (done) 1000 else progress, false)

        // One number per row: the time left once a task has started
        // («۱۸ دقیقه مانده»), its plan before that, «انجام شد» after.
        val (trail, trailColor) = when (stage) {
            TaskStage.RUNNING -> "${fa(left)} دقیقه مانده" to R.color.widget_orange
            TaskStage.PAUSED -> "${fa(left)} دقیقه مانده" to R.color.widget_blue
            TaskStage.DONE -> "انجام شد" to R.color.widget_green
            TaskStage.NOT_STARTED -> "${fa(planned)} دقیقه" to R.color.widget_muted
        }
        val trailImage = TextImages.render(context, trail, 11f, 700)
        views.setImageViewBitmap(trailIds[i], trailImage)
        tint(context, views, trailIds[i], "setColorFilter", trailColor)

        // Widget padding, row padding, the dot and the gaps around the title.
        val titleRoom = widthDp - 28f - 20f - 14f - 8f - 10f - TextImages.widthDp(context, trailImage)
        text(
            context, views, titleIds[i], task.title, 12.5f,
            if (stage == TaskStage.RUNNING) 700 else 400,
            if (done) R.color.widget_muted else R.color.widget_text,
            maxWidthDp = titleRoom,
        )

        // A finished task opens the home; any other its timer.
        views.setOnClickPendingIntent(rowIds[i], open(context, if (done) LINK_HOME else taskLink(task), i + 1))
    }

    // ------------------------------------------------------------- shared

    private fun taskLink(task: WidgetTask) = "saimo://widget/task?id=${Uri.encode(task.id)}"

    /** [value] drawn in IRANSans into the ImageView [id], tinted [color]. */
    private fun text(
        context: Context, views: RemoteViews, id: Int, value: String,
        sizeSp: Float, weight: Int, color: Int,
        maxWidthDp: Float = 1000f, maxLines: Int = 1, centered: Boolean = false,
    ) {
        views.setImageViewBitmap(
            id, TextImages.render(context, value, sizeSp, weight, maxWidthDp, maxLines, centered),
        )
        views.setContentDescription(id, value)
        tint(context, views, id, "setColorFilter", color)
    }

    /**
     * Sets a colour by resource, so that from Android 12 the launcher picks
     * the light or dark one itself when the theme switches. Older versions
     * get the colour for the theme at the time of the update.
     */
    private fun tint(context: Context, views: RemoteViews, id: Int, method: String, color: Int) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) views.setColor(id, method, color)
        else views.setInt(id, method, context.getColor(color))
    }

    private fun emptyMessage(day: WidgetDay) = when (day) {
        WidgetDay.SignedOut -> "برای دیدن برنامه‌ی امروز وارد سایمو شوید"
        WidgetDay.Stale -> "برنامه‌ی امروز را در سایمو ببینید"
        is WidgetDay.Today -> "برای امروز کاری نچیده‌اید"
    }

    private fun open(context: Context, link: String, requestCode: Int): PendingIntent {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(link)).apply {
            setPackage(context.packageName)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }
        return PendingIntent.getActivity(
            context, requestCode, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    /**
     * Wakes the widgets again: every minute while a timer runs (and when it
     * fills its task), otherwise at midnight for the new day. The alarm does
     * not wake the phone; it waits until the screen is on.
     */
    fun scheduleRefresh(context: Context) {
        val alarms = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, TodayWidgetProvider::class.java).setAction(ACTION_REFRESH)
        val pending = PendingIntent.getBroadcast(
            context, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val manager = AppWidgetManager.getInstance(context)
        val placed = manager.getAppWidgetIds(ComponentName(context, TodayWidgetProvider::class.java)).isNotEmpty() ||
            manager.getAppWidgetIds(ComponentName(context, TasksWidgetProvider::class.java)).isNotEmpty()
        if (!placed) {
            alarms.cancel(pending)
            return
        }

        val now = System.currentTimeMillis()
        var next = nextMidnight(now)
        val today = WidgetStore.read(context, now) as? WidgetDay.Today
        if (today != null && today.hasRunning(now)) {
            next = minOf(next, now + LIVE_REFRESH_MS)
            today.nextEndMs(now)?.let { next = minOf(next, it + 1000) }
        }
        alarms.set(AlarmManager.RTC, next, pending)
    }

    private fun nextMidnight(now: Long): Long = Calendar.getInstance().apply {
        timeInMillis = now
        add(Calendar.DAY_OF_YEAR, 1)
        set(Calendar.HOUR_OF_DAY, 0)
        set(Calendar.MINUTE, 0)
        set(Calendar.SECOND, 5)
        set(Calendar.MILLISECOND, 0)
    }.timeInMillis

    /** Persian digits, as everywhere in the app. */
    fun fa(number: Int): String = number.toString().map { c ->
        if (c in '0'..'9') '۰' + (c - '0') else c
    }.joinToString("")
}
