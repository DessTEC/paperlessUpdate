class PaperlessRequest {
  const PaperlessRequest({
    required this.appName,
    required this.formId,
    required this.requesterInfo,
    required this.saveInPaperless,
  });

  final String appName;
  final String formId;
  final RequesterInfo requesterInfo;
  final bool saveInPaperless;
}

class RequesterInfo {
  const RequesterInfo({
    required this.userId,
    required this.userName,
    required this.userMail,
  });
  final String userId;
  final String userName;
  final String userMail;
}
