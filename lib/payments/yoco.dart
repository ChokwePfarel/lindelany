

class YocoPaymentService {

  static DateTime getExpiryDate(int planDuration) {
    return DateTime.now().add(Duration(days: planDuration * 30));
  }
}
