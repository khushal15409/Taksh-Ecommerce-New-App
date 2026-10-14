import 'package:flutter/material.dart';
import 'package:taksh_e_commerce/core/widgets/app_toast.dart';

/// Shows an error message with the app-wide top toast.
class AppErrorToast {
  AppErrorToast._();

  static const String genericMessage = 'Something went wrong';

  static void show(BuildContext context, {String? message}) {
    final text = (message == null || message.trim().isEmpty)
        ? genericMessage
        : message.trim();

    if (text.length <= 48 && !text.contains('\n')) {
      AppToast.error(context, text);
    } else {
      AppToast.error(context, genericMessage, message: text);
    }
  }
}
