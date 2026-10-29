import 'package:flutter/material.dart';
import 'package:hydrate_mobile_flutter/src/utils/api.dart';
import 'package:hydrate_mobile_flutter/src/utils/auth.dart';
import 'package:hydrate_mobile_flutter/src/utils/stores.dart';
import 'package:hydrate_mobile_flutter/src/utils/toast.dart' as toast;

// Lets the user report a fob, picture or user for moderation.
// contentId is the fob ID, picture ID, or username.
Future<void> showReportDialog(BuildContext context,
    {required ReportContentType contentType, required String contentId, required String title}) async {
  final submitted = await showDialog<bool>(
    context: context,
    builder: (context) => _ReportDialog(contentType: contentType, contentId: contentId, title: title),
  );
  if (submitted == true && context.mounted) {
    toast.showToast(context, "Thanks, your report has been sent for review.");
  }
}

class _ReportDialog extends StatefulWidget {
  const _ReportDialog({required this.contentType, required this.contentId, required this.title});

  final ReportContentType contentType;
  final String contentId;
  final String title;

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  ReportReason? reason;
  String details = "";
  bool submitting = false;

  Future<void> submit() async {
    setState(() => submitting = true);
    try {
      final tokens = await AuthService.checkOrRefreshToken(useTokenStore().state);
      if (tokens == null) {
        throw Exception("Not signed in");
      }
      final response = await reportContent(tokens.accessToken, widget.contentType, widget.contentId, reason!,
          details: details.trim());
      if (response.statusCode != 201) {
        throw Exception(response.body);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      debugPrint("Error reporting content: $e");
      if (mounted) {
        setState(() => submitting = false);
        toast.showToast(context, "Couldn't send report, please try again.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioGroup<ReportReason>(
              groupValue: reason,
              onChanged: (value) => setState(() => reason = value),
              child: Column(
                children: ReportReason.values.map((value) => RadioListTile<ReportReason>(
                  title: Text(value.label),
                  value: value,
                  contentPadding: EdgeInsets.zero,
                )).toList(),
              ),
            ),
            TextField(
              maxLength: 1000,
              maxLines: 3,
              minLines: 1,
              onChanged: (value) => details = value,
              decoration: const InputDecoration(hintText: "Details (optional)"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: submitting ? null : () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: reason == null || submitting ? null : submit,
          child: const Text("Report"),
        ),
      ],
    );
  }
}
