import 'package:flutter/material.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';

/// Festive (Diwali) confirmation popup: cream card, diya on top, lanterns in
/// the corners, close button and Cancel / Confirm buttons.
///
/// Pops `true` when the confirm button is tapped and `false` for cancel or the
/// close icon, so it is a drop-in replacement for an `AlertDialog` that
/// returns a bool.
class FestiveConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? note;
  final String cancelLabel;
  final String confirmLabel;

  const FestiveConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.note,
    required this.cancelLabel,
    required this.confirmLabel,
  });

  static const Color _accent = Color(0xFFFF8A1F);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF1DA), Color(0xFFFFFBF4)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: Image.asset(
                'assets/images/redesign/lantern_l.png',
                height: 84,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              right: 0,
              top: 24,
              child: Image.asset(
                'assets/images/redesign/lantern_r.png',
                height: 70,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/redesign/dialog_diya.png',
                    height: 62,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.grey900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.35,
                      color: AppColors.grey900,
                    ),
                  ),
                  if (note != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      note!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.35,
                        color: AppColors.grey900,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _accent,
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: _accent, width: 1.5),
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: Text(cancelLabel),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: Text(confirmLabel),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(),
                elevation: 2,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).pop(false),
                  child: const SizedBox(
                    width: 34,
                    height: 34,
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: AppColors.grey900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
