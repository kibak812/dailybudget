// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get common_save => '저장';

  @override
  String get common_cancel => '취소';

  @override
  String get common_confirm => '확인';

  @override
  String get common_delete => '삭제';

  @override
  String get common_add => '추가';

  @override
  String get common_edit => '수정';

  @override
  String get common_close => '닫기';

  @override
  String get common_yes => '예';

  @override
  String get common_no => '아니오';

  @override
  String get common_ok => '확인';

  @override
  String get common_search => '검색';

  @override
  String get common_reset => '초기화';

  @override
  String get nav_home => '홈';

  @override
  String get nav_transactions => '거래내역';

  @override
  String get nav_statistics => '통계';

  @override
  String get nav_settings => '설정';

  @override
  String get home_todayBudget => '오늘 사용할 수 있는 예산';

  @override
  String get home_setBudget => '예산을 설정해주세요';

  @override
  String get home_setBudgetDesc => '예산을 설정하면\n일별 사용 가능 금액을 확인할 수 있습니다';

  @override
  String get home_setBudgetButton => '예산 설정하기';

  @override
  String get home_previousMonth => '이전 달';

  @override
  String get home_nextMonth => '다음 달';

  @override
  String get home_addTransaction => '거래 추가';

  @override
  String get budget_monthlyBudget => '이달 예산';

  @override
  String budget_daysRemaining(int days) {
    return '$days일 남음';
  }

  @override
  String budget_budgetAmount(String amount) {
    return '예산 $amount';
  }

  @override
  String budget_monthBudget(int month) {
    return '$month월 예산';
  }

  @override
  String get budget_budgetSettings => '예산 설정';

  @override
  String get budget_periodSettings => '예산 기간 설정';

  @override
  String get budget_startDay => '예산 시작일';

  @override
  String budget_startDayDesc(int day) {
    return '매월 $day일';
  }

  @override
  String get budget_startDayHint => '매월 이 날짜에 예산이 초기화됩니다';

  @override
  String get budget_notSet => '미설정';

  @override
  String get budget_enterNewAmount => '새 예산 금액 입력';

  @override
  String get budget_monthlyStartDay => '매월 시작일';

  @override
  String budget_dayDefault(int day) {
    return '$day일 (기본)';
  }

  @override
  String budget_dayFormat(int day) {
    return '$day일';
  }

  @override
  String get budget_startDayExplain =>
      '월급날 등 예산 시작일을 설정하면 해당 날짜부터 다음 시작일 전날까지를 한 달 예산 기간으로 계산합니다.';

  @override
  String get budget_selectStartDay => '예산 시작일 선택';

  @override
  String get today_netIncome => '오늘 순수입';

  @override
  String get today_netExpense => '오늘 순지출';

  @override
  String get today_overBudget => '오늘 예산 초과';

  @override
  String get today_remaining => '오늘 남은 예산';

  @override
  String yesterday_summary(int month, int day) {
    return '$month월 $day일 결산';
  }

  @override
  String get yesterday_budget => '예산';

  @override
  String get yesterday_expense => '지출';

  @override
  String get yesterday_savingsRate => '절약률';

  @override
  String get trend_title => '일별 예산 추이';

  @override
  String get trend_1week => '1주';

  @override
  String get trend_2weeks => '2주';

  @override
  String get trend_1month => '1달';

  @override
  String get transaction_addTitle => '거래 추가';

  @override
  String get transaction_editTitle => '거래 수정';

  @override
  String get transaction_detailTitle => '거래 상세';

  @override
  String get transaction_expense => '지출';

  @override
  String get transaction_income => '수입';

  @override
  String get transaction_amount => '금액';

  @override
  String get transaction_amountHint => '0';

  @override
  String get transaction_category => '카테고리';

  @override
  String get transaction_categoryOptional => '카테고리 (선택)';

  @override
  String get transaction_categorySelect => '선택하세요';

  @override
  String get transaction_memo => '메모 (선택)';

  @override
  String get transaction_memoHint => '메모를 입력하세요';

  @override
  String get transaction_date => '날짜';

  @override
  String transaction_dateLabel(String date) {
    return '날짜: $date';
  }

  @override
  String get transaction_createdAt => '등록 시간';

  @override
  String get transaction_isRecurring => '반복 거래';

  @override
  String get transaction_addButton => '추가하기';

  @override
  String get transaction_editButton => '수정 완료';

  @override
  String get transaction_uncategorized => '미분류';

  @override
  String get transaction_deleteTitle => '거래 삭제';

  @override
  String get transaction_deleteMessage => '이 거래를 삭제하시겠습니까?';

  @override
  String get calculator_title => '계산기';

  @override
  String calculator_result(String result) {
    return '$result 원';
  }

  @override
  String get category_title => '카테고리';

  @override
  String get category_expense => '지출 카테고리';

  @override
  String get category_income => '수입 카테고리';

  @override
  String get category_add => '새 카테고리 추가';

  @override
  String get category_edit => '카테고리 수정';

  @override
  String get category_editTitle => '카테고리 수정';

  @override
  String get category_name => '카테고리 이름';

  @override
  String get category_empty => '카테고리가 없습니다';

  @override
  String get category_deleteTitle => '카테고리 삭제';

  @override
  String category_deleteMessage(String category) {
    return '\"$category\" 카테고리를 삭제하시겠습니까?';
  }

  @override
  String get category_food => '식비';

  @override
  String get category_transport => '교통';

  @override
  String get category_shopping => '쇼핑';

  @override
  String get category_living => '생활';

  @override
  String get category_hobby => '취미';

  @override
  String get category_medical => '의료';

  @override
  String get category_other => '기타';

  @override
  String get category_salary => '급여';

  @override
  String get category_allowance => '용돈';

  @override
  String get category_bonus => '보너스';

  @override
  String get statistics_title => '통계';

  @override
  String get statistics_totalExpense => '총 지출';

  @override
  String statistics_categoryDetail(String category) {
    return '$category 지출 내역';
  }

  @override
  String statistics_yearMonth(int year, int month) {
    return '$year년 $month월';
  }

  @override
  String get settings_title => '설정';

  @override
  String get notification_title => '알림 설정';

  @override
  String get notification_dailySummary => '하루 결산 알림';

  @override
  String get notification_dailySummaryDesc => '매일 설정한 시간에 어제의 지출 결산을 알려드려요';

  @override
  String get notification_time => '알림 시간';

  @override
  String get notification_timeSelect => '알림 시간 선택';

  @override
  String get notification_permissionRequired =>
      '알림 권한이 필요합니다. 설정에서 권한을 허용해주세요.';

  @override
  String get notification_requestAgain => '다시 요청';

  @override
  String get notification_am => '오전';

  @override
  String get notification_pm => '오후';

  @override
  String get notification_hour => '시';

  @override
  String get notification_minute => '분';

  @override
  String get notification_channelName => '하루 결산';

  @override
  String get notification_channelDesc => '매일 설정한 시간에 어제의 지출 결산을 알려드립니다';

  @override
  String get notification_pushTitle => '하루 결산';

  @override
  String get notification_pushBody => '어제의 지출을 확인해보세요';

  @override
  String get recurring_title => '반복 지출';

  @override
  String get recurring_addTitle => '반복 지출 추가';

  @override
  String get recurring_editTitle => '반복 지출 수정';

  @override
  String get recurring_add => '추가하기';

  @override
  String get recurring_empty => '등록된 반복 지출이 없습니다';

  @override
  String get recurring_regenerate => '현재 기간 반복 지출 다시 생성하기';

  @override
  String get recurring_type => '타입';

  @override
  String get recurring_amount => '금액';

  @override
  String get recurring_dayOfMonth => '매월 실행 날짜';

  @override
  String get recurring_dayOfMonthHint => '1~31';

  @override
  String get recurring_memo => '메모';

  @override
  String get recurring_enabled => '활성화';

  @override
  String get recurring_deleteTitle => '반복 지출 삭제';

  @override
  String get recurring_deleteMessage => '정말로 이 반복 지출을 삭제하시겠습니까?';

  @override
  String get recurring_example => '예: 월세';

  @override
  String get recurring_amountExample => '예: 500,000';

  @override
  String get recurring_monthly => '매월';

  @override
  String get recurring_active => '활성';

  @override
  String get recurring_inactive => '비활성';

  @override
  String get data_title => '데이터 관리';

  @override
  String get data_backup => '데이터 백업';

  @override
  String get data_backupDesc => '현재 데이터를 파일로 저장합니다';

  @override
  String get data_restore => '데이터 복원';

  @override
  String get data_restoreDesc => '백업 파일을 불러옵니다';

  @override
  String get data_deleteAll => '모든 데이터 삭제';

  @override
  String get data_deleteAllDesc => '이 작업은 되돌릴 수 없습니다';

  @override
  String get data_hint => '데이터는 기기에 안전하게 저장됩니다. 앱 삭제 시 데이터가 사라지므로 정기적으로 백업하세요.';

  @override
  String get data_exportSuccess => '데이터가 내보내졌습니다.';

  @override
  String data_exportError(String error) {
    return '데이터 내보내기에 실패했습니다: $error';
  }

  @override
  String data_importSuccess(int budgets, int transactions, int recurring) {
    return '데이터를 가져왔습니다!\n예산: $budgets개, 거래: $transactions개, 반복: $recurring개';
  }

  @override
  String data_importError(String error) {
    return '데이터 가져오기에 실패했습니다: $error';
  }

  @override
  String get data_deleteConfirm => '모든 데이터 삭제';

  @override
  String get data_deleteConfirmMessage =>
      '정말로 모든 데이터를 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.';

  @override
  String get data_deleteDoubleConfirm => '한 번 더 확인';

  @override
  String get data_deleteDoubleConfirmMessage => '한 번 더 확인합니다. 정말로 삭제하시겠습니까?';

  @override
  String get data_deleteSuccess => '모든 데이터가 삭제되었습니다.';

  @override
  String data_deleteError(String error) {
    return '데이터 삭제에 실패했습니다: $error';
  }

  @override
  String get data_backupSubject => 'Daily Pace 백업';

  @override
  String get data_backupText => '데이터 백업 파일';

  @override
  String get language_title => '언어';

  @override
  String get language_system => '시스템 설정';

  @override
  String get language_korean => '한국어';

  @override
  String get language_english => 'English';

  @override
  String get error_invalidAmount => '올바른 금액을 입력해주세요';

  @override
  String get error_enterAmount => '금액을 입력해주세요';

  @override
  String error_generic(String error) {
    return '오류가 발생했습니다: $error';
  }

  @override
  String get error_categoryExists => '이미 존재하는 카테고리입니다';

  @override
  String get error_categoryEmpty => '카테고리 이름을 입력해주세요.';

  @override
  String get error_selectCategory => '카테고리를 선택해주세요.';

  @override
  String get error_invalidDay => '날짜는 1~31 사이여야 합니다.';

  @override
  String transaction_dateTransactions(String date) {
    return '$date 거래';
  }

  @override
  String get transaction_viewAll => '전체 보기';

  @override
  String get transaction_noTransactionsDate => '이 날은 거래 내역이 없어요!';

  @override
  String get transaction_noSearchResults => '검색 결과가 없습니다.';

  @override
  String get transaction_noTransactions => '거래 내역 없음';

  @override
  String get mosaic_noBudget => '예산이 설정되지 않았습니다.';

  @override
  String mosaic_summary(int perfect, int overspent) {
    return '이번 기간: 퍼펙트 $perfect일, 과소비 $overspent일';
  }

  @override
  String mosaic_dateLabel(int month, int day, String weekday) {
    return '$month월 $day일 ($weekday)';
  }

  @override
  String get weekday_sun => '일';

  @override
  String get weekday_mon => '월';

  @override
  String get weekday_tue => '화';

  @override
  String get weekday_wed => '수';

  @override
  String get weekday_thu => '목';

  @override
  String get weekday_fri => '금';

  @override
  String get weekday_sat => '토';

  @override
  String get weekday_short_sun => '일';

  @override
  String get weekday_short_mon => '월';

  @override
  String get weekday_short_tue => '화';

  @override
  String get weekday_short_wed => '수';

  @override
  String get weekday_short_thu => '목';

  @override
  String get weekday_short_fri => '금';

  @override
  String get weekday_short_sat => '토';

  @override
  String date_yearMonthDay(int year, int month, int day) {
    return '$year년 $month월 $day일';
  }

  @override
  String date_monthDay(int month, int day) {
    return '$month월 $day일';
  }

  @override
  String date_yearMonth(int year, int month) {
    return '$year년 $month월';
  }

  @override
  String get unit_won => '원';

  @override
  String get unit_man => '만';

  @override
  String get unit_chun => '천';

  @override
  String format_currency(String amount) {
    return '$amount원';
  }

  @override
  String get status_perfect => '훌륭해요! 예산의 50% 이하로 지출했어요';

  @override
  String get status_safe => '잘했어요! 예산 내에서 지출했어요';

  @override
  String get status_warning => '조금 주의하세요. 예산을 약간 초과했어요';

  @override
  String get status_danger => '예산 관리가 필요해요. 크게 초과했어요';

  @override
  String diff_increased(String amount) {
    return '어제보다 $amount 늘었어요';
  }

  @override
  String diff_decreased(String amount) {
    return '어제보다 $amount 줄었어요';
  }

  @override
  String get diff_same => '어제와 같아요';

  @override
  String get statistics_currentPeriodBudget => '현재 기간 예산';

  @override
  String get statistics_netIncome => '순수입';

  @override
  String get statistics_netExpense => '순지출';

  @override
  String get statistics_remainingBudget => '남은 예산';

  @override
  String get statistics_totalIncome => '총 수입';

  @override
  String get statistics_noBudget => '예산을 먼저 설정해주세요.';

  @override
  String get statistics_noTransactions => '아직 거래 내역이 없습니다';

  @override
  String get statistics_budgetUsage => '예산 사용률';

  @override
  String get statistics_categoryExpense => '카테고리별 지출';

  @override
  String statistics_transactionCount(int count) {
    return '$count건';
  }

  @override
  String get statistics_categoryNoTransactions => '이 카테고리의 지출 내역이 없습니다';

  @override
  String get today_budgetDecreaseHint => '내일부터 일별 예산이 줄어듭니다';

  @override
  String get trend_noData => '예산 데이터가 없습니다';

  @override
  String get net_income => '순수입';

  @override
  String get net_expense => '순지출';

  @override
  String net_income_amount(String amount) {
    return '순수입 $amount';
  }

  @override
  String net_expense_amount(String amount) {
    return '순지출 $amount';
  }

  @override
  String remaining_budget_amount(String amount) {
    return '남은 예산 $amount';
  }
}
