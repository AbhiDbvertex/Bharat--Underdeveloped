class ApiEndpoint {
  static const String accountScreen = '/user/getUserProfileData';
  static const String workerScreen = '/api/worker/add';
  static const String bankScreen = '/user/updateBankDetails';
  static const String customerCare = '/CompanyDetails/contact/email';
  static const String loginScreen = '/user/register';
  static const String otpVerificationScreen = '/user/userProfile';
  static const String galleryScreen = '/user/updateHisWork';
  static const String serviceDirectViewScreen = '/user/getServiceProviders';
  static const String serviceWorkDetails = '/direct-order/accept-offer';
  // static const String workerMyHireScreen =
  //     '/direct-order/apiGetAllDirectOrders';
  static const String workerMyHireScreen =
      '/direct-order/getOrdersByUser';
  static const String WorkerScreen = '/worker/all';
  static const String hireScreen = '/direct-order/create';

  // static const String MyHireScreen = '/direct-order/apiGetAllDirectOrders';

  static const String MyHireScreen = '/direct-order/getOrdersByUser';
  static const String SubCategories = '/user/getServiceProviders';
  static const String workerCategories = '/work-category';
  static const String getworker = '/worker/all';
  static const String darectCanceloffer = '/direct-order/cancelOrderByUser';
  static const String darectMarkComplete = '/direct-order/completeOrderUser';
  static const String biddingMarkComplete = '/bidding-order/completeOrderUser';
  static const String postRatingDarect = '/user/add-review';
}

// pet grooming, pet boarding(overnight),pet walking, vet visit coordination, pet nutrition plans