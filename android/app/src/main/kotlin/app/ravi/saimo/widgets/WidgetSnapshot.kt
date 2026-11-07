package app.ravi.saimo.widgets

import android.content.Context
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/** A task's state on the widget, worked out for a given moment. */
enum class TaskStage { DONE, RUNNING, PAUSED, NOT_STARTED }

/**
 * One of today's tasks as the app last handed it over. A running task
 * carries when it started counting, so the widget counts on by itself.
 */
data class WidgetTask(
    val id: String,
    val title: String,
    val plannedSec: Int,
    val workedSec: Int,
    val runningSinceMs: Long?,
    val done: Boolean,
) {
    fun workedAt(nowMs: Long): Int {
        if (done) return plannedSec
        val since = runningSinceMs ?: return workedSec.coerceAtMost(plannedSec)
        val running = ((nowMs - since) / 1000).coerceAtLeast(0)
        return (workedSec + running).coerceAtMost(plannedSec.toLong()).toInt()
    }

    /** The timer ran out while the app was closed: the task is full. */
    private fun fullAt(nowMs: Long) = plannedSec > 0 && workedAt(nowMs) >= plannedSec

    fun stageAt(nowMs: Long): TaskStage = when {
        done || fullAt(nowMs) -> TaskStage.DONE
        runningSinceMs != null -> TaskStage.RUNNING
        workedSec > 0 -> TaskStage.PAUSED
        else -> TaskStage.NOT_STARTED
    }

    /** When a running timer fills the task. */
    fun endsAtMs(): Long? {
        val since = runningSinceMs ?: return null
        if (done) return null
        return since + (plannedSec - workedSec).coerceAtLeast(0) * 1000L
    }
}

/** The score multiplier as the server last counted it (see DashboardConsistency). */
data class WidgetStreak(
    val level: Int,
    val countedToday: Boolean,
    val hasPlan: Boolean,
    val remainingSec: Int,
    val fetchedAtMs: Long,
)

/** What the widgets show, read from the app's last snapshot. */
sealed class WidgetDay {
    /** Never synced, or signed out. */
    object SignedOut : WidgetDay()

    /** The snapshot is from an earlier day; the app has not been opened today. */
    object Stale : WidgetDay()

    /** [date] is today as the app writes it, «شنبه ۱۶ آبان». */
    data class Today(
        val tasks: List<WidgetTask>,
        val date: String = "",
        val streak: WidgetStreak? = null,
    ) : WidgetDay() {
        fun running(nowMs: Long) = tasks.firstOrNull { it.stageAt(nowMs) == TaskStage.RUNNING }

        /** Study still needed for today to count, less what a timer added since the server answered. */
        fun streakRemainingSec(nowMs: Long): Int {
            val streak = streak ?: return 0
            val since = tasks.sumOf { it.workedAt(nowMs) - it.workedAt(streak.fetchedAtMs) }
            return (streak.remainingSec - since).coerceAtLeast(0)
        }

        fun plannedSec() = tasks.sumOf { it.plannedSec }
        fun workedAt(nowMs: Long) = tasks.sumOf { it.workedAt(nowMs) }
        fun doneCount(nowMs: Long) = tasks.count { it.stageAt(nowMs) == TaskStage.DONE }
        fun hasRunning(nowMs: Long) = tasks.any { it.stageAt(nowMs) == TaskStage.RUNNING }
        fun nextEndMs(nowMs: Long) = tasks
            .filter { it.stageAt(nowMs) == TaskStage.RUNNING }
            .mapNotNull { it.endsAtMs() }
            .minOrNull()
    }
}

object WidgetStore {
    private const val PREFS = "saimo_home_widgets"
    private const val KEY = "snapshot"

    fun save(context: Context, json: String) {
        prefs(context).edit().putString(KEY, json).apply()
    }

    fun clear(context: Context) {
        prefs(context).edit().remove(KEY).apply()
    }

    fun read(context: Context, nowMs: Long): WidgetDay =
        parse(prefs(context).getString(KEY, null), nowMs)

    private fun prefs(context: Context) =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    fun parse(json: String?, nowMs: Long): WidgetDay {
        if (json.isNullOrBlank()) return WidgetDay.SignedOut
        return try {
            val root = JSONObject(json)
            if (root.optString("day") != dayKey(nowMs)) return WidgetDay.Stale
            val list = root.optJSONArray("tasks")
            val tasks = (0 until (list?.length() ?: 0)).map { i ->
                val t = list!!.getJSONObject(i)
                WidgetTask(
                    id = t.optString("id"),
                    title = t.optString("title"),
                    plannedSec = t.optInt("plannedSec"),
                    workedSec = t.optInt("workedSec"),
                    runningSinceMs = if (t.isNull("runningSinceMs")) null else t.optLong("runningSinceMs"),
                    done = t.optBoolean("done"),
                )
            }
            val streak = root.optJSONObject("streak")?.let {
                WidgetStreak(
                    level = it.optInt("level", 1),
                    countedToday = it.optBoolean("countedToday"),
                    hasPlan = it.optBoolean("hasPlan"),
                    remainingSec = it.optInt("remainingSec"),
                    fetchedAtMs = it.optLong("fetchedAtMs", nowMs),
                )
            }
            WidgetDay.Today(tasks, root.optString("date"), streak)
        } catch (_: Exception) {
            WidgetDay.SignedOut
        }
    }

    fun dayKey(nowMs: Long): String =
        SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date(nowMs))
}
