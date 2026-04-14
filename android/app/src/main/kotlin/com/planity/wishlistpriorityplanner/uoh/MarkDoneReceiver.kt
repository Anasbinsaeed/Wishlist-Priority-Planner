package com.planity.wishlistpriorityplanner.uoh

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.database.sqlite.SQLiteDatabase
import android.util.Log

class MarkDoneReceiver : BroadcastReceiver() {

    companion object {
        const val ACTION = "com.planity.wishlistpriorityplanner.uoh.MARK_DONE"
        const val EXTRA_WISH_ID = "wish_id"
        private const val TAG = "MarkDoneReceiver"
        private const val STATUS_COMPLETED = 2
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION) return

        val wishId = intent.getStringExtra(EXTRA_WISH_ID) ?: return
        Log.d(TAG, "Marking wish done: $wishId")

        try {
            val dbPath = context.getDatabasePath("wishlist.db").absolutePath
            val db = SQLiteDatabase.openDatabase(dbPath, null, SQLiteDatabase.OPEN_READWRITE)
            db.execSQL("UPDATE wishes SET status = ? WHERE id = ?", arrayOf(STATUS_COMPLETED, wishId))
            db.close()
            Log.d(TAG, "Wish $wishId marked as completed")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to mark wish done: ${e.message}")
        }
    }
}
