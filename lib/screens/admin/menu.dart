import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:repair_station/screens/admin/car_lines/car_lines.dart';
import 'package:repair_station/screens/admin/cranes/cranes.dart';
import 'package:repair_station/screens/admin/sales/sales.dart';

import 'Payments/payments.dart';
import 'inventory/inventory.dart';
import 'orders/orders.dart';

class AdminMenuScreen extends StatelessWidget {
  const AdminMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Página Administrativa",
          style: Theme.of(context).textTheme.headline2,
        ),
        centerTitle: true,
        // leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
      ),
      body: const AdminMenu(),
    );
  }
}

class AdminMenu extends StatefulWidget {
  const AdminMenu({super.key});

  @override
  AdminMenuState createState() => AdminMenuState();
}

class AdminMenuState extends State<AdminMenu> {
  late final PageController page;

  @override
  void initState() {
    super.initState();
    page = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SideMenu(
          controller: page,
          style: SideMenuStyle(
            showTooltip: false,
            displayMode: SideMenuDisplayMode.auto,
            hoverColor: Colors.blue[100],
            selectedColor: Colors.lightBlue,
            selectedTitleTextStyle: const TextStyle(color: Colors.white),
            selectedIconColor: Colors.white,
            // decoration: BoxDecoration(
            //   borderRadius: BorderRadius.all(Radius.circular(10)),
            // ),
            // backgroundColor: Colors.blueGrey[700]
          ),
          title: Column(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 150,
                  maxWidth: 150,
                ),
                child: Image.asset(
                  'assets/easy_sidemenu.png',
                ),
              ),
              const Divider(
                indent: 8.0,
                endIndent: 8.0,
              ),
            ],
          ),
          footer: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Tienda de Repuestos',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          items: [
            SideMenuItem(
              priority: 0,
              title: 'Grúas',
              onTap: () {
                page.jumpToPage(0);
              },
              icon: const Icon(Icons.car_crash),
              tooltipContent: "This is a tooltip for Dashboard item",
            ),
            SideMenuItem(
              priority: 1,
              title: 'Líneas de Carros',
              onTap: () {
                page.jumpToPage(1);
              },
              icon: const Icon(Icons.car_rental),
              tooltipContent: "This is a tooltip for Dashboard item",
            ),
            SideMenuItem(
              priority: 2,
              title: 'Inventario',
              onTap: () {
                page.jumpToPage(2);
              },
              icon: const Icon(Icons.inventory),
              tooltipContent: "This is a tooltip for Dashboard item",
            ),
            SideMenuItem(
              priority: 3,
              title: 'Órdenes',
              onTap: () {
                page.jumpToPage(3);
              },
              icon: const Icon(Icons.file_copy_rounded),
            ),
             SideMenuItem(
               priority: 4,
               title: 'Pagos',
               onTap: () {
                 page.jumpToPage(4);
               },
               icon: const Icon(Icons.point_of_sale),
             ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: PageView(
              controller: page,
              children: const [
                CraneScreen(),
                CarLineScreen(),
                InventoryScreen(),
                OrdersScreen(),
                // SaleScreen(),
                PaymentsScreen(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
