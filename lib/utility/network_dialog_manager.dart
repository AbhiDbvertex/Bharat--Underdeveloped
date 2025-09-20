// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
//
// import '../Emergency/utils/logger.dart';
// import '../main.dart';
//
// class AutomaticNoConnectionDialog {
//   static StreamSubscription<InternetStatus>? _listener;
//   static bool _isDialogShowing = false;
//   static BuildContext? _currentContext;
//   static InternetStatus? _pendingStatus;
//
//   static void startListening() {
//     // Cancel any existing listener
//     _listener?.cancel();
//     _listener = InternetConnection().onStatusChange.listen((InternetStatus status) {
//       bwDebug('Internet status: $status', tag: "InternetCheck");
//       _pendingStatus = status; // Store the latest status
//       _tryShowDialog();
//     });
//   }
//
//   static void _tryShowDialog() {
//     final context = getBwGlobalContext();
//     if (context == null || !context.mounted) {
//       bwDebug('No valid context available, queuing dialog', tag: "InternetCheck");
//       // Retry after a short delay if context is not available
//       Future.delayed(Duration(milliseconds: 500), () {
//         if (_pendingStatus != null) {
//           _tryShowDialog();
//         }
//       });
//       return;
//     }
//
//     switch (_pendingStatus) {
//       case InternetStatus.disconnected:
//         _showNoInternetDialog(context);
//         break;
//       case InternetStatus.connected:
//         if (_isDialogShowing) {
//           _dismissDialog();
//           _showInternetRestoredDialog(context);
//         }
//         break;
//       case null:
//         break;
//     }
//   }
//
//   static void dispose() {
//     bwDebug('Disposing AutomaticNoConnectionDialog', tag: "InternetCheck");
//     _listener?.cancel();
//     _dismissDialog();
//     _pendingStatus = null;
//   }
//
//   static void _showNoInternetDialog(BuildContext context) {
//     if (_isDialogShowing) return;
//     bwDebug("Showing no internet dialog", tag: "InternetCheck");
//     _isDialogShowing = true;
//     _currentContext = context;
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext dialogContext) {
//         return PopScope(
//           canPop: false,
//           child: AlertDialog(
//             backgroundColor: Colors.grey[900],
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15),
//             ),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CircularProgressIndicator(),
//                 const SizedBox(height: 20),
//                 Text(
//                   "No Internet Connection",
//                   style: TextStyle(color: Colors.white),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   "Waiting for connection...",
//                   style: TextStyle(color: Colors.white70),
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(dialogContext).pop();
//                   _tryShowDialog(); // Retry checking status
//                 },
//                 child: Text("Retry"),
//               ),
//             ],
//           ),
//         );
//       },
//     ).then((_) => _cleanupDialog());
//   }
//
//   static void _showInternetRestoredDialog(BuildContext context) {
//     _dismissDialog();
//
//     bwDebug("Showing internet restored dialog", tag: "InternetCheck");
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           backgroundColor: Colors.grey[900],
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: const [
//               CircularProgressIndicator(),
//               SizedBox(height: 20),
//               Text(
//                 "Internet Restored",
//                 style: TextStyle(color: Colors.white),
//               ),
//               SizedBox(height: 10),
//               Text(
//                 "Refreshing...",
//                 style: TextStyle(color: Colors.white70),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//
//     // Auto-dismiss after 3 seconds
//     Future.delayed(const Duration(seconds: 3), () {
//       if (_currentContext != null && _currentContext!.mounted) {
//         Navigator.of(_currentContext!).pop();
//         _cleanupDialog();
//       }
//     });
//   }
//
//   static void _dismissDialog() {
//     if (_isDialogShowing && _currentContext != null && _currentContext!.mounted) {
//       bwDebug("Dismissing dialog", tag: "InternetCheck");
//       Navigator.of(_currentContext!).pop();
//       _cleanupDialog();
//     }
//   }
//
//   static void _cleanupDialog() {
//     bwDebug("Cleaning up dialog", tag: "InternetCheck");
//     _isDialogShowing = false;
//     _currentContext = null;
//     _pendingStatus = null;
//   }
// }

//////////////
/*
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../Emergency/utils/logger.dart';
import '../main.dart';
import 'custom_snack_bar.dart'; // <-- import your snackbar

class AutomaticNoConnectionDialog {
  static StreamSubscription<InternetStatus>? _listener;
  static InternetStatus? _pendingStatus;

  static void startListening() {
    // Cancel any existing listener
    _listener?.cancel();
    _listener = InternetConnection().onStatusChange.listen((InternetStatus status) {
      bwDebug('Internet status: $status', tag: "InternetCheck");
      _pendingStatus = status;
      _tryShowSnackBar();
    });
  }

  static void _tryShowSnackBar() {
    final context = getBwGlobalContext();
    if (context == null || !context.mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_pendingStatus != null) {
          _tryShowSnackBar();
        }
      });
      return;
    }

    switch (_pendingStatus) {
      case InternetStatus.disconnected:
        _showNoInternetSnackBar(context);
        break;
      case InternetStatus.connected:
        _showInternetRestoredSnackBar(context);
        break;
      case null:
        break;
    }
  }

  static void dispose() {
    bwDebug('Disposing AutomaticNoConnectionDialog', tag: "InternetCheck");
    _listener?.cancel();
    _pendingStatus = null;
  }

  static void _showNoInternetSnackBar(BuildContext context) {
    bwDebug("Showing no internet snackbar", tag: "InternetCheck");
    CustomSnackBar.show(
      context,
      message: "No Internet Connection",
      type: SnackBarType.error,


    );
  }

  static void _showInternetRestoredSnackBar(BuildContext context) {
    bwDebug("Showing internet restored snackbar", tag: "InternetCheck");
    CustomSnackBar.show(
      context,
      message: "Internet Restored",
      type: SnackBarType.success,


    );
  }
}
*/
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../Emergency/utils/logger.dart';
import '../main.dart';

class AutomaticNoConnectionDialog {
  static StreamSubscription<InternetStatus>? _listener;
  static bool _isDialogShowing = false;
  static BuildContext? _currentContext;
  static InternetStatus? _pendingStatus;

  /// Start listening for internet changes
  static void startListening() {
    _listener?.cancel();
    _listener = InternetConnection().onStatusChange.listen((InternetStatus status) {
      bwDebug('Internet status: $status', tag: "InternetCheck");
      _pendingStatus = status; // store latest status
      _tryShowDialog();
    });
  }

  /// Stop listening and clean up
  static void dispose() {
    bwDebug('Disposing AutomaticNoConnectionDialog', tag: "InternetCheck");
    _listener?.cancel();
    _dismissDialog();
    _pendingStatus = null;
  }

  /// Decide what to show/hide based on current status
  static void _tryShowDialog() {
    final context = getBwGlobalContext();
    if (context == null || !context.mounted) return;

    switch (_pendingStatus) {
      case InternetStatus.disconnected:
        _showNoInternetDialog(context);
        break;
      case InternetStatus.connected:
        _dismissDialog(); // just hide any existing popup
        break;
      case null:
        break;
    }
  }

  /// Show No Internet dialog
  static void _showNoInternetDialog(BuildContext context) {
    if (_isDialogShowing) return; // already showing
    bwDebug("Showing no internet dialog", tag: "InternetCheck");

    _isDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        _currentContext = dialogContext; // store dialog context for dismiss
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                "No Internet Connection",
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              Text(
                "Waiting for connection...",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        );
      },
    ).then((_) => _cleanupDialog());
  }

  /// Dismiss any showing dialog
  static void _dismissDialog() {
    if (_isDialogShowing && _currentContext != null && _currentContext!.mounted) {
      bwDebug("Dismissing dialog", tag: "InternetCheck");
      Navigator.of(_currentContext!).pop();
      _cleanupDialog();
    }
  }

  /// Cleanup flags and context
  static void _cleanupDialog() {
    bwDebug("Cleaning up dialog", tag: "InternetCheck");
    _isDialogShowing = false;
    _currentContext = null;
    _pendingStatus = null;
  }
}
