package com.example.dummy_lat_long_app

import android.annotation.SuppressLint
import android.app.admin.DeviceAdminReceiver
import android.app.admin.DevicePolicyManager
import android.app.admin.DevicePolicyManager.LOCK_TASK_FEATURE_NONE
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val REQUEST_CODE_ENABLE_ADMIN = 1
    private val CHANNEL = "lockTaskMode"
    private val KIOSK_PACKAGE = "com.example.kiosk"
    private val PLAYER_PACKAGE = "com.example.player"
    private  val MyApp = " com.example.dummy_lat_long_app"
    private val APP_PACKAGES = arrayOf(KIOSK_PACKAGE, PLAYER_PACKAGE,MyApp)

    private lateinit var mAdminComponentName: ComponentName
    private lateinit var mDevicePolicyManager: DevicePolicyManager

  @RequiresApi(Build.VERSION_CODES.P)
  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
      call, result ->
      if (call.method == "enableLockTask") {
         /* activity.startLockTask();*/
          /* enableLockTask(activity)*/

         mAdminComponentName = MyDeviceAdminReceiver.getComponentName(this)
          mDevicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager

          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
              if( mDevicePolicyManager.isLockTaskPermitted(MyApp) ){
                  Log.d("Started","Is Enabled the app")
              }
              Log.d("Has Started","Is Unable the app")

              mDevicePolicyManager.setLockTaskPackages(mAdminComponentName, APP_PACKAGES);

              mDevicePolicyManager.setLockTaskFeatures(mAdminComponentName,LOCK_TASK_FEATURE_NONE)
print("List")
              mDevicePolicyManager.getLockTaskPackages(mAdminComponentName).forEach { print("List $it") }
                activity. startLockTask()



          }

          result.success(null)
    }else {
        result.notImplemented()
      }
  }


}

    @SuppressLint("NewApi")
    fun enableLockTask(context: Context) {
        // Allowlist two apps.


// ...

       if (mDevicePolicyManager.isDeviceOwnerApp(packageName)) {
            // You are the owner!
        } else {
          /// Please contact your system administrator
           }
        /*val context = context
        val dpm = context.getSystemService(Context.DEVICE_POLICY_SERVICE)
                as DevicePolicyManager
        val adminName = getComponentName(context)
        dpm.setLockTaskPackages(adminName, APP_PACKAGES)*/

// Set an option to turn on lock task mode when starting the activity.
     /*   val options = ActivityOptions.makeBasic()
        options.setLockTaskEnabled(true)*/

// Start our kiosk app's main activity with our lock task mode option.
     /*   val packageManager = context.packageManager
        val launchIntent = packageManager.getLaunchIntentForPackage(KIOSK_PACKAGE)
        if (launchIntent != null) {
            context.startActivity(launchIntent, options.toBundle())
        }*/

       /* val dpm = context.getSystemService(DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val mAdminComponent = ComponentName(context, MyDeviceAdminReceiver::class.java)*/
       /* val options = ActivityOptions.makeBasic()
        options.setLockTaskEnabled(true)*/


      /*  val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN).apply {
            putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, mAdminComponent)
            putExtra(DevicePolicyManager.EXTRA_ADD_EXPLANATION, "Additional text explaining why this app needs device admin privileges")
        }

        activity.startActivityForResult(intent, REQUEST_CODE_ENABLE_ADMIN)*/


         /*   if (1 == Activity.RESULT_OK) {
                print("granted");
                dpm.setLockTaskPackages(mAdminComponent, arrayOf(context.packageName))
                dpm.setLockTaskFeatures(mAdminComponent, DevicePolicyManager.LOCK_TASK_FEATURE_HOME)
                activity.startLockTask()
            } else {
               print("Not granted");
            }*/

        /*if (dpm.isDeviceOwnerApp(context.packageName)) {
            dpm.setLockTaskPackages(mAdminComponent, arrayOf(context.packageName))
            startLockTask()*/
        }



}


class MyDeviceAdminReceiver : DeviceAdminReceiver() {

    companion object {
        fun getComponentName(context: Context): ComponentName {
            return ComponentName(context.applicationContext, MyDeviceAdminReceiver::class.java)
        }

        private val TAG = MyDeviceAdminReceiver::class.java.simpleName
    }

    override fun onLockTaskModeEntering(context: Context, intent: Intent, pkg: String) {
        super.onLockTaskModeEntering(context, intent, pkg)
        Log.d(TAG, "onLockTaskModeEntering")
    }

    override fun onLockTaskModeExiting(context: Context, intent: Intent) {
        super.onLockTaskModeExiting(context, intent)
        Log.d(TAG, "onLockTaskModeExiting")
    }
    override fun onEnabled(context: Context, intent: Intent) {
        super.onEnabled(context, intent)
        // Perform any necessary actions when the device admin is enabled
        Log.d("DeviceAdmin", "Enabled")
    }
    override fun onDisabled(context: Context, intent: Intent) {
        super.onDisabled(context, intent)
        Log.d("DeviceAdmin", "Disabled")
    }
}

