/// Platform roles (maps to Supabase `roles.id`).

enum AppRole {

  superAdmin('super_admin'),

  storeOwner('store_owner'),

  admin('admin'),

  manager('manager'),

  cashier('cashier'),

  sales('sales'),

  accountant('accountant'),

  inventoryStaff('inventory_staff'),

  reports('reports');



  const AppRole(this.id);

  final String id;



  static AppRole fromId(String? value) {

    return AppRole.values.firstWhere(

      (r) => r.id == value,

      orElse: () => AppRole.cashier,

    );

  }



  /// Roles assignable when creating store staff (never owner / super admin).

  static List<AppRole> assignableRoles = [

    AppRole.admin,

    AppRole.manager,

    AppRole.cashier,

    AppRole.sales,

    AppRole.accountant,

    AppRole.inventoryStaff,

    AppRole.reports,

  ];



  String get label => switch (this) {

        AppRole.superAdmin => 'Super Admin',

        AppRole.storeOwner => 'Owner',

        AppRole.admin => 'Admin',

        AppRole.manager => 'Manager',

        AppRole.cashier => 'Cashier',

        AppRole.sales => 'Sales',

        AppRole.accountant => 'Accounting',

        AppRole.inventoryStaff => 'Inventory',

        AppRole.reports => 'Reports',

      };



  bool get isPlatformRole => this == AppRole.superAdmin;

  bool get isOwner => this == AppRole.storeOwner;

}


