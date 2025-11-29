# Debugging SmartGuardApp in Cursor/VS Code

## ⚠️ Important Limitation

**.NET MAUI Android breakpoints do NOT work in Cursor/VS Code** because Android apps run on the emulator/device as a remote process. The VS Code .NET debugger only supports local processes.

## ✅ Solutions

### Option 1: Use Windows Target for Breakpoints (Recommended)

1. Set breakpoints in your code (click left of line numbers)
2. Press `F5` or go to Run and Debug (Ctrl+Shift+D)
3. Select **".NET MAUI Windows Debug (Breakpoints Work!)"**
4. Breakpoints will work! ✅

### Option 2: For Android - Use Logging & ADB Logcat

Since breakpoints don't work for Android, use logging:

1. Add logging statements in your code:
   ```csharp
   #if DEBUG
   System.Diagnostics.Debug.WriteLine("Your debug message here");
   #endif
   ```

2. View logs using ADB logcat:
   ```powershell
   cd SmartGuardApp
   # View all logs
   adb logcat
   
   # View only your app's logs (filtered)
   adb logcat | Select-String "SmartGuardApp"
   ```

3. Or use the "Deploy Only" task to deploy to Android, then check the Debug Console in Cursor

### Option 3: Use Visual Studio (Full Android Debugging)

For full Android debugging support (breakpoints, stepping, etc.):
- Open the `.sln` file in Visual Studio
- Select Android as the target
- Press F5 - breakpoints will work! ✅

## Available Debug Configurations

- **".NET MAUI Windows Debug (Breakpoints Work!)"** - Use this for debugging with breakpoints
- **".NET MAUI Android (Deploy Only)"** - Deploys to Android emulator (no breakpoints)

## Tasks

- `build-android-debug` - Builds and deploys Android app
- `build-windows-debug` - Builds Windows app for debugging

