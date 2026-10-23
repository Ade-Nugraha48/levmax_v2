import 'package:hive/hive.dart';
import 'package:levmax_v2/utils/constants.dart';

/// Service untuk seluruh operasi penyimpanan lokal Hive (Session, Blockchain, Quest) (Boilerplate)
class HiveService {
  static Box get sessionBox => Hive.box(AppConstants.sessionBox);
  static Box get blockchainBox => Hive.box(AppConstants.blockchainBox);
  static Box get questBox => Hive.box(AppConstants.questBox);

  // Helper fungsi sesi login & blockchain nantinya diimplementasikan di sini
}
