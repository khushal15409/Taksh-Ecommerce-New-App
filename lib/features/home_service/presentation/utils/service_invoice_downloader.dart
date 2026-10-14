import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:taksh_e_commerce/core/di/injector.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';
import 'package:taksh_e_commerce/core/widgets/app_toast.dart';
import 'package:taksh_e_commerce/features/home_service/domain/usecases/courier_usecases.dart';

/// Downloads the invoice PDF of a paid booking and opens it.
///
/// [path] is the API path (see `ApiConstants.courierBookingInvoice` /
/// `ApiConstants.serviceBookInvoice`), so the invoice always belongs to the
/// booking that was tapped.
Future<void> downloadServiceInvoice(
  BuildContext context, {
  required String path,
  required String bookingNumber,
}) async {
  final progress = ValueNotifier<double>(0);
  final navigator = Navigator.of(context, rootNavigator: true);
  final messenger = AppToastMessenger.of(context);

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (_) => PopScope(
      canPop: false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Downloading invoice'),
        content: ValueListenableBuilder<double>(
          valueListenable: progress,
          builder: (_, value, __) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.receipt_long,
                size: 48,
                color: AppColors.primaryOrange,
              ),
              const SizedBox(height: 16),
              Text(
                'Booking #$bookingNumber',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: value > 0 ? value : null,
                minHeight: 6,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryOrange,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  final result = await getIt<DownloadServiceInvoice>()(
    DownloadServiceInvoiceParams(
      path: path,
      fileName: 'invoice_$bookingNumber.pdf',
      onProgress: (p) => progress.value = p,
    ),
  );
  progress.dispose();

  if (navigator.mounted && navigator.canPop()) navigator.pop();

  await result.fold(
    (failure) async {
      messenger.showSnackBar(
        SnackBar(
          content: Text(failure.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    },
    (filePath) async {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Invoice for booking #$bookingNumber downloaded'),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'OPEN',
            textColor: Colors.white,
            onPressed: () => OpenFilex.open(filePath),
          ),
        ),
      );
      await OpenFilex.open(filePath);
    },
  );
}
