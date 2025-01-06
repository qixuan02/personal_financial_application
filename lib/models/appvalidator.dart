class AppValidator {

String? isEmptyCheck(value) {
  if (value!.isEmpty) {
    return 'Please fill detail';
  }
  return null;
}

 String? validatePhoneNumber(value) {
    if (value!.isEmpty) {
      return 'Please enter a phone number';
    }
    if (value.length !> 12) {
      return 'Please enter a 10-digit phone number';
    }
    return null;
  }

}