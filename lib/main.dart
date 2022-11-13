import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/localization/l10n.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:repair_station/screens/admin/car_lines/car_line_form.dart';
import 'package:repair_station/screens/admin/cranes/crane_form.dart';
import 'package:repair_station/screens/admin/inventory/new_product_form.dart';
import 'package:repair_station/screens/admin/inventory/product_form.dart';
import 'package:repair_station/screens/admin/menu.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:repair_station/screens/admin/orders/order_delivery_form.dart';
import 'package:repair_station/screens/admin/sales/new_sales_form.dart';
import 'package:repair_station/screens/admin/sales/update_sales_form.dart';

import 'package:repair_station/models/car_line.dart';
import 'package:repair_station/models/product.dart';
import 'package:repair_station/models/sale.dart';

import 'firebase_options.dart';
import 'models/crane.dart';
import 'models/order.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Repair Station Ines',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          headline1: GoogleFonts.vollkorn(
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
          headline2: GoogleFonts.vollkorn(
            textStyle: TextStyle(
              color: Colors.white.withOpacity(0.90),
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
          subtitle1: GoogleFonts.robotoSlab(
            textStyle: const TextStyle(
              fontSize: 18,
            ),
          ),
          subtitle2: GoogleFonts.robotoSlab(
            textStyle: TextStyle(
              color: Colors.white.withOpacity(0.90),
              fontSize: 18,
            ),
          ),
          bodyText1: GoogleFonts.fenix(
            textStyle: const TextStyle(
              fontSize: 16,
            ),
          ),
          bodyText2: GoogleFonts.fenix(
            textStyle: TextStyle(
              color: Colors.white.withOpacity(0.90),
              fontSize: 16,
            ),
          ),
        ),
      ),
      localizationsDelegates: const [
        FormBuilderLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: FormBuilderLocalizations.supportedLocales,
      initialRoute: "/",
      routes: {
        "/": (context) => const AdminMenuScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case "/newproductform":
            final arguments = settings.arguments! as RepairProductsCatalog;
            return PageTransition(
              child: NewProductFormScreen(
                catalog: arguments,
              ),
              type: PageTransitionType.fade,
              settings: settings,
              reverseDuration: const Duration(seconds: 1),
            );
          case "/productform":
            final arguments = settings.arguments! as RepairProduct;
            return PageTransition(
              child: ProductFormScreen(
                product: arguments,
              ),
              type: PageTransitionType.fade,
              settings: settings,
              reverseDuration: const Duration(seconds: 1),
            );
/*         case "/newsaleform":
           final arguments = settings.arguments! as SalesCatalog;
           return PageTransition(
             child: NewSaleFormScreen(
               salesCatalog: arguments,
             ),
             type: PageTransitionType.fade,
             settings: settings,
             reverseDuration: const Duration(seconds: 1),
           );
         case "/updatesaleform":
           final arguments = settings.arguments! as Sale;
           return PageTransition(
             child: UpdateSaleFormScreen(
               sale: arguments,
             ),
             type: PageTransitionType.fade,
             settings: settings,
             reverseDuration: const Duration(seconds: 1),
           );*/
          case "/craneform":
            final arguments = settings.arguments! as List<dynamic>;
            return PageTransition(
              child: CraneFormScreen(
                crane: arguments[0] as Crane?,
                cranes: arguments[1] as Cranes,
              ),
              type: PageTransitionType.fade,
              settings: settings,
              reverseDuration: const Duration(seconds: 1),
            );
          case "/carlineform":
            final arguments = settings.arguments! as List<dynamic>;
            return PageTransition(
              child: CarLineFormScreen(
                carLine: arguments[0] as CarLine?,
                automobilesLines: arguments[1] as AutomobileLines,
              ),
              type: PageTransitionType.fade,
              settings: settings,
              reverseDuration: const Duration(seconds: 1),
            );
          case "/deliveryform":
            final arguments = settings.arguments as Order;
            return PageTransition(
              child: DeliveryFormScreen(
                order: arguments,
              ),
              type: PageTransitionType.fade,
              settings: settings,
              reverseDuration: const Duration(seconds: 1),
            );
          default:
            return null;
        }
      },
    );
  }
}
