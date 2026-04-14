package com.planity.wishlistpriorityplanner.uoh

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.database.sqlite.SQLiteDatabase
import android.util.Log
import androidx.core.app.NotificationManagerCompat

class NotificationActionReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "NotificationActionRcvr"
        private const val ACTION_MARK_DONE = "mark_done"
        private const val STATUS_COMPLETED = 2
    }

    override fun onReceive(context: Context, intent: Intent) {
        val actionId = intent.getStringExtra("action_id") ?: return
        val payload = intent.getStringExtra("payload") ?: return
        val notificationId = intent.getIntExtra("notification_id", -1)

        Log.d(TAG, "Action received: $actionId, payload: $payload")

        if (actionId == ACTION_MARK_DONE) {
            markWishDone(context, payload)
            if (notificationId != -1) {
                NotificationManagerCompat.from(context).cancel(notificationId)
            }
        }
    }

    private fun markWishDone(context: Context, wishId: String) {
        try {
            val dbFile = context.getDatabasePath("wishlist.db")
            if (!dbFile.exists()) {
                Log.w(TAG, "Database not found at ${dbFile.absolutePath}")
                return
            }
            val db = SQLiteDatabase.openDatabase(dbFile.absolutePath, null, SQLiteDatabase.OPEN_READWRITE)
            val rows = db.compileStatement("UPDATE wishes SET status = $STATUS_COMPLETED WHERE id = ?")
                .apply { bindString(1, wishId) }.executeUpdateDelete()
            db.close()
            Log.d(TAG, "Marked wish $wishId as done ($rows rows updated)")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to mark wish done: ${e.message}", e)
        }
    }
}
