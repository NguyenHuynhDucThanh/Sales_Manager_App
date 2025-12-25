import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/repositories/order_repository.dart';
import '../logic/report_logic.dart';

// Provider lấy báo cáo hôm nay
final todayReportProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.read(orderRepositoryProvider);
  final logic = ReportLogic(repo);
  return await logic.getTodayReport();
});

// Provider lấy báo cáo tất cả thời gian
final allTimeReportProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.read(orderRepositoryProvider);
  final logic = ReportLogic(repo);
  return await logic.getAllTimeReport();
});

// Provider lấy báo cáo theo ngày được chọn (Family provider)
// ✅ DELEGATE to ReportLogic - NO business logic here!
final reportByDateProvider = FutureProvider.family<Map<String, dynamic>, DateTime>((ref, date) async {
  final repo = ref.read(orderRepositoryProvider);
  final logic = ReportLogic(repo);
  return await logic.getReportByDate(date); // ✅ Delegate to logic
});
