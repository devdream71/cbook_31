class AppUrl {

  /////=====> Total Api 45 
  ///=======> category, sub category, unit, sales, auth, item, suppliers, customer, purchase 

  static String baseurl = "https://commercebook.site/api/v1/";

  //category
  static String categoriesGet = "${baseurl}item-categories";
  static String categoriesStore =
      "${baseurl}item-categories/store?name=Bata&status=1";
  static String categoriesGetById = "${baseurl}item-categories/edit/8";
  static String categoriesUpdate =
      "${baseurl}item-categories/update?id=8&name=Dove&status=1";
  static String categoriesDelete = "${baseurl}item-categories/remove/7";

  //subcategory
  static String subCategoriesGet = "${baseurl}item-subcategories";
  static String subCategoriesGtByID = "${baseurl}item/get/subcategories/3";
  static String subCategoriesStore =
      "${baseurl}item-subcategories/store?item_category=1&name=Bata&status=1";

  ///unit
  static String unitGetById = "${baseurl}unit/edit/8";
  static String unitGet = "${baseurl}units";
  static String unitStore =
      "${baseurl}unit/store?user_id=1&name=Bata&symbol=KG&status=1";
  static String unitUpdate =
      "${baseurl}unit/update?id=7&user_id=1&name=Bata&symbol=KG&status=1";
  static String unitDelete = "${baseurl}unit/remove/10";

  ///sale
  static String saleGet = "${baseurl}sales/";
  static String saleStore =
      "${baseurl}sales/store?user_id=1&customer_id=32&bill_number=521445&sale_date=2025-02-27&details_notes=notes&gross_total=190&discount=5&payment_out=1&payment_amount=190";
  static String saleEdit = "${baseurl}sales/edit/194";
  static String saleUpdate =
      "${baseurl}sales/update?id=194&user_id=1&customer_id=10&bill_number=521444&sale_date=2025-02-06&details_notes=notes&gross_total=800&discount=5&payment_out=1&payment_amount=800";
  static String saleDelete = "${baseurl}sales/remove?id=106";

  //sign up
  static String signUp = "${baseurl}register";
  static String userIdOtpCheck =
      "${baseurl}verification/code?user_id=77&code=617121";
  static String selectedRollLogin =
      "${baseurl}verification/login?email=tatenam368@kuandika.com";
  static String login =
      "${baseurl}login?email=citane1438@gufutu.com&password=123456";
  static String profile = "${baseurl}profile/90";
  static String profileUpdate =
      "${baseurl}general/info/update?opening_balance=100&user_id=10&date=2025-02-05&currency=BDT&tread_license_no=5678567&business_category_id=6&business_type_id=5";
  static String genInfo = "${baseurl}general/info/12";
  static String businessInfoUpdate =
      "${baseurl}business/info/update?opening_balance=100&user_id=10&date=2025-02-05&currency=BDT&tread_license_no=5678567&business_category_id=6&business_type_id=5";

  ///item
  static String item = "${baseurl}items";
  static String itemStore =
      "${baseurl}item/store?name=Dove&unit_id=10&unit_qty=12&secondary_unit_id=1&opening_stock=20&opening_price=20&value=400&opening_date=2025-02-04&status=1";
  static String itemEdit = "${baseurl}item/edit/72";
  static String itemUpdate =
      "${baseurl}item/update?id=73&name=time watch update&status=1";

  ///suppliers
  static String suppliersGet = "${baseurl}suppliers";
  static String suppliersDelete = "${baseurl}supplier/remove/9";
  static String supplierStore =
      "${baseurl}supplier/store?user_id=1&name=hasan&proprietor_name=jhon&email=cus@gmail.com&phone=9876544567&opening_balance=100&address=Dhaka&status=100";
  static String suppliersGetById = "${baseurl}supplier/edit/14";
  static String suppliersUpdate =
      "${baseurl}supplier/update?user_id=90&id=14&name=hasan update &proprietor_name=jhon&email=cus@gmail.com&phone=9876544567&address=Dhaka&status=1";

  ///customer  
  static String customerGet = "${baseurl}customers/list";
  static String customerStore =
      "${baseurl}customer/store?user_id=90&name=sumon&proprietor_name=jhon&email=cus@gmail.com&phone=9876544567&opening_balance=100&address=Dhaka&status=1";
  static String customerGetByid = "${baseurl}customer/edit/24";
  static String customerUpdate =
      "${baseurl}customer/update?user_id=90&id=32&name=hasan&proprietor_name=jhon&email=cus@gmail.com&phone=9876544567&address=Dhaka&status=0&opening_balance=";

  ///purchase //==> 5
  static String purchaseGet = "${baseurl}purchase/";
  static String purchaseStore = "${baseurl}purchase/store?user_id=1&customer_id=cash&bill_number=521444&pruchase_date=2025-02-06&details_notes=notes&gross_total=20&discount=5";
  static String purchaseGetById = "${baseurl}purchase/edit/13";
  static String purchaseUpdate = "${baseurl}purchase/update?id=84&user_id=1&customer_id=10&bill_number=521444&pruchase_date=2025-02-23&details_notes=notes&gross_total=400&discount=0";
  static String purchaseDelete = "${baseurl}purchase/remove?id=32";

  ///purchase //==> 5
  static String purchaseReturnGet = "${baseurl}purchase/return";
  static String purchaseReturnHistory = "${baseurl}item/purchase/history/206";
  static String purchaseReturnStore = "${baseurl}purchase/return/store?user_id=1&customer_id=52&bill_number=521444&return_date=2025-03-19&details_notes=notes&gross_total=100&discount=5&payment_out=1&payment_amount=100";
  
  ///sale return
  static String sellReturnGet = "${baseurl}sales/return";
  static String sellReturnHistory = "${baseurl}item/sales/history?customer_id=cash&item_id=25";
  static String sellReturnStore = "${baseurl}sales/return/store?user_id=1&customer_id=52&bill_number=521444&return_date=2025-03-20&details_notes=notes&gross_total=12&discount=5&payment_out=1&payment_amount=12";



  



}
