const Map<String, List<String>> categoryKeywords = {
  '업무': [
    '회의', '미팅', '보고서', '업무', '프로젝트', '발표', '출장', '계약',
    '이메일', '메일', '회사', '팀', '고객', '자료', '기획', '결재', '야근',
  ],
  '개인': [
    '운동', '병원', '약속', '쇼핑', '가족', '친구', '여행', '생일',
    '청소', '빨래', '취미', '약', '헬스', '데이트', '은행',
  ],
  '공부': [
    '공부', '시험', '과제', '숙제', '강의', '수업', '책', '독서',
    '스터디', '논문', '자격증', '토익', '학원', '복습', '예습',
  ],
};

String? suggestCategory(String text) {
  final normalized = text.trim().toLowerCase();
  if (normalized.isEmpty) return null;

  for (final entry in categoryKeywords.entries) {
    for (final keyword in entry.value) {
      if (normalized.contains(keyword.toLowerCase())) {
        return entry.key;
      }
    }
  }
  return null;
}
