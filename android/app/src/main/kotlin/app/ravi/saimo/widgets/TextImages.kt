package app.ravi.saimo.widgets

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Typeface
import android.os.Build
import android.text.Layout
import android.text.StaticLayout
import android.text.TextDirectionHeuristics
import android.text.TextPaint
import android.text.TextUtils
import kotlin.math.ceil
import kotlin.math.max
import kotlin.math.min

/**
 * Widget text drawn as images in IRANSans, the app's font: a launcher only
 * draws widget text in the phone's system font.
 *
 * The glyphs are drawn white; the ImageView tints them with a colour
 * resource, so from Android 12 they still follow a light/dark switch.
 */
object TextImages {
    /** The font Flutter bundles in the APK (pubspec.yaml, IRANSansVar). */
    private const val FONT = "flutter_assets/assets/fonts/IRANSansXVF.ttf"

    private val faces = HashMap<Int, Typeface>()

    private fun face(context: Context, weight: Int): Typeface = faces.getOrPut(weight) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Typeface.Builder(context.assets, FONT)
                    .setFontVariationSettings("'wght' $weight")
                    .build()
            } else {
                Typeface.create(
                    Typeface.createFromAsset(context.assets, FONT),
                    if (weight >= 600) Typeface.BOLD else Typeface.NORMAL,
                )
            }
        } catch (_: Exception) {
            Typeface.create(Typeface.DEFAULT, if (weight >= 600) Typeface.BOLD else Typeface.NORMAL)
        }
    }

    /**
     * [text] at [sizeSp] and [weight], right to left, at most [maxLines]
     * lines and [maxWidthDp] wide (cut with «…» past that), right-aligned
     * or centred.
     */
    fun render(
        context: Context,
        text: String,
        sizeSp: Float,
        weight: Int = 400,
        maxWidthDp: Float = 1000f,
        maxLines: Int = 1,
        centered: Boolean = false,
    ): Bitmap {
        val metrics = context.resources.displayMetrics
        val paint = TextPaint(TextPaint.ANTI_ALIAS_FLAG or TextPaint.SUBPIXEL_TEXT_FLAG).apply {
            typeface = face(context, weight)
            textSize = sizeSp * metrics.scaledDensity
            color = Color.WHITE
        }
        val maxWidth = max(1, (maxWidthDp * metrics.density).toInt())
        val natural = ceil(Layout.getDesiredWidth(text, paint)).toInt() + 2
        val width = max(1, min(natural, maxWidth))
        val layout = StaticLayout.Builder.obtain(text, 0, text.length, paint, width)
            .setTextDirection(TextDirectionHeuristics.RTL)
            .setAlignment(if (centered) Layout.Alignment.ALIGN_CENTER else Layout.Alignment.ALIGN_NORMAL)
            .setMaxLines(maxLines)
            .setEllipsize(TextUtils.TruncateAt.END)
            .setIncludePad(false)
            .setLineSpacing(0f, 1.1f)
            .build()

        // Room for the font's tall Persian ascenders and descenders.
        val pad = (paint.textSize * 0.12f).toInt()
        val bitmap = Bitmap.createBitmap(width, layout.height + pad * 2, Bitmap.Config.ARGB_8888)
        bitmap.density = metrics.densityDpi
        val canvas = Canvas(bitmap)
        canvas.translate(0f, pad.toFloat())
        layout.draw(canvas)
        return bitmap
    }

    fun widthDp(context: Context, bitmap: Bitmap): Float =
        bitmap.width / context.resources.displayMetrics.density
}
