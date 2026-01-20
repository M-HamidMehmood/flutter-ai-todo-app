import 'export_service.dart';

// Stub for non-web platforms - this should never be called
// because we check kIsWeb before calling this
ExportResult exportForWeb(String csv) {
  return ExportResult(
    success: false,
    message: 'Web export not supported on this platform',
  );
}
